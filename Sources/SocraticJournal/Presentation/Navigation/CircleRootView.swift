// CircleRootView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Root navigation view for the Circle app.
/// Shows ProfileSetupView when not authenticated, CircleListView when signed in.
public struct CircleRootView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(ThemeManager.self) private var themeManager
    @State private var showSettings = false

    public var body: some View {
        Group {
            if services.authService.isAuthenticated {
                authenticatedContent
            } else {
                ProfileSetupView(
                    viewModel: ProfileSetupViewModel(
                        authService: services.authService
                    )
                )
            }
        }
    }

    // MARK: - Authenticated Content

    private var authenticatedContent: some View {
        NavigationStack {
            CircleListView(
                viewModel: CircleListViewModel(circleService: services.circleService),
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
