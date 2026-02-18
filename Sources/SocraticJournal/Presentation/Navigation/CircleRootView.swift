// CircleRootView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Root navigation view for the Circle app.
/// Shows onboarding when first launched, ProfileSetupView when not authenticated,
/// and CircleListView when signed in.
public struct CircleRootView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSettings = false
    @State private var hasCompletedOnboarding: Bool?
    @State private var onboardingViewModel: OnboardingViewModel?

    public var body: some View {
        Group {
            if let completed = hasCompletedOnboarding {
                if !completed {
                    onboardingContent
                } else if services.authService.isAuthenticated {
                    authenticatedContent
                } else {
                    ProfileSetupView(
                        viewModel: ProfileSetupViewModel(
                            authService: services.authService
                        )
                    )
                }
            } else {
                // Loading state while checking onboarding status
                ZStack {
                    CircleTheme.backgroundGradient.ignoresSafeArea()
                    ProgressView()
                        .tint(CircleTheme.warmAmber)
                }
            }
        }
        .task {
            await loadOnboardingState()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await services.notificationService.clearBadge()
                }
            }
        }
    }

    // MARK: - Onboarding

    @ViewBuilder
    private var onboardingContent: some View {
        if let vm = onboardingViewModel {
            OnboardingView(viewModel: vm)
                .onChange(of: vm.isCompleted) { _, completed in
                    if completed {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            hasCompletedOnboarding = true
                        }
                    }
                }
        }
    }

    private func loadOnboardingState() async {
        do {
            let settings = try await services.settingsRepository.getSettings()
            let completed = settings.hasCompletedOnboarding

            // Prepare onboarding VM if needed
            if !completed {
                onboardingViewModel = OnboardingViewModel(
                    settingsRepository: services.settingsRepository,
                    analyticsService: services.analyticsService
                )
            }

            withAnimation(.easeInOut(duration: 0.3)) {
                hasCompletedOnboarding = completed
            }
        } catch {
            // On error, skip onboarding to avoid blocking the user
            hasCompletedOnboarding = true
        }
    }

    // MARK: - Authenticated Content

    private var authenticatedContent: some View {
        NavigationStack {
            CircleListView(
                viewModel: CircleListViewModel(circleService: services.circleService, promptService: services.promptService),
                circleService: services.circleService
            )
            .navigationTitle("Circle")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    profileButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.body.weight(.medium))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    viewModel: SettingsViewModel(
                        settingsRepository: services.settingsRepository,
                        notificationService: services.notificationService,
                        subscriptionService: services.subscriptionService,
                        analyticsService: services.analyticsService
                    ),
                    circleNotificationViewModel: CircleNotificationSettingsViewModel(
                        circleService: services.circleService,
                        notificationService: services.notificationService,
                        settingsRepository: services.settingsRepository
                    )
                )
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }

    @ViewBuilder
    private var profileButton: some View {
        if let user = services.authService.currentUser {
            HStack(spacing: 8) {
                InitialsAvatarView(user: user, size: 28)

                Text(user.displayName.split(separator: " ").first.map(String.init) ?? user.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview("Authenticated") {
    CircleRootView()
        .environment(ServiceContainer(
            authService: MockAuthService(isSignedIn: true),
            circleService: MockCircleService()
        ))
        .environment(ThemeManager.shared)
}

#Preview("Not Authenticated") {
    CircleRootView()
        .environment(ServiceContainer(
            authService: MockAuthService(isSignedIn: false),
            circleService: MockCircleService(withSampleData: false)
        ))
        .environment(ThemeManager.shared)
}
#endif
