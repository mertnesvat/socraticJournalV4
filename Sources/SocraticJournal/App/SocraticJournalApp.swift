// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UserNotifications

/// Main entry point for the Socratic Journal app
@main
public struct SocraticJournalApp: App {
    private let repository: JournalRepositoryProtocol = InMemoryJournalRepository()
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let notificationService: NotificationServiceProtocol = LocalNotificationService()
    @State private var themeManager = ThemeManager.shared
    @State private var showOnboarding = false
    @State private var hasCheckedOnboarding = false

    public init() {
        // Configure Firebase Messaging
        FirebaseNotificationService.shared.configure()
        // Configure ThemeManager with settings repository
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
    }

    public var body: some Scene {
        WindowGroup {
            Group {
                if hasCheckedOnboarding {
                    MainTabView(
                        repository: repository,
                        settingsRepository: settingsRepository,
                        notificationService: notificationService
                    )
                } else {
                    // Show splash/loading state while checking onboarding status
                    splashView
                }
            }
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingContainerView(onComplete: {
                    Task {
                        await completeOnboarding()
                    }
                })
            }
            .task {
                await checkOnboardingStatus()
                await themeManager.loadTheme()
                await rescheduleNotifications()
                await clearBadge()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await clearBadge()
                }
            }
        }
    }

    /// Splash view shown while checking onboarding status
    private var splashView: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "book.pages")
                    .font(.system(size: 60))
                    .foregroundStyle(.accent)
                Text("Socratic Journal")
                    .font(.title)
                    .fontWeight(.semibold)
            }
        }
    }

    /// Check onboarding status on app launch
    private func checkOnboardingStatus() async {
        do {
            let hasCompleted = try await settingsRepository.hasCompletedOnboarding()
            if !hasCompleted {
                showOnboarding = true
            }
        } catch {
            // If we can't check onboarding status, assume user needs onboarding
            print("Failed to check onboarding status: \(error)")
            showOnboarding = true
        }
        hasCheckedOnboarding = true
    }

    /// Complete onboarding and dismiss the onboarding flow
    private func completeOnboarding() async {
        do {
            try await settingsRepository.markOnboardingComplete()
        } catch {
            print("Failed to mark onboarding complete: \(error)")
        }
        showOnboarding = false
    }

    /// Reschedule notifications on app launch to ensure they're still valid
    private func rescheduleNotifications() async {
        do {
            let settings = try await settingsRepository.getSettings()
            let letters = try await repository.getAllLetters()
            await notificationService.rescheduleAllNotifications(letters: letters, settings: settings)
        } catch {
            print("Failed to reschedule notifications: \(error)")
        }
    }

    /// Clear badge when app comes to foreground
    private func clearBadge() async {
        if let localService = notificationService as? LocalNotificationService {
            await localService.clearBadge()
        }
    }
}
#endif
