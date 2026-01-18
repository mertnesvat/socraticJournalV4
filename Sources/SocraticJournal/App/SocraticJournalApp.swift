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
    @State private var showOnboarding: Bool = false

    public init() {
        // Configure Firebase Messaging
        FirebaseNotificationService.shared.configure()
        // Configure ThemeManager with settings repository
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView(
                repository: repository,
                settingsRepository: settingsRepository,
                notificationService: notificationService
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingContainerView {
                    // Mark onboarding complete and dismiss
                    Task { @MainActor in
                        do {
                            var settings = try await settingsRepository.getSettings()
                            settings.hasCompletedOnboarding = true
                            try await settingsRepository.saveSettings(settings)
                            showOnboarding = false
                        } catch {
                            // Even if saving fails, dismiss onboarding to not block the user
                            print("Failed to save onboarding completion: \(error)")
                            showOnboarding = false
                        }
                    }
                }
            }
            .task {
                await themeManager.loadTheme()
                await rescheduleNotifications()
                await clearBadge()
                await checkOnboardingStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await clearBadge()
                }
            }
        }
    }

    /// Check if onboarding has been completed and show it if not
    private func checkOnboardingStatus() async {
        do {
            let settings = try await settingsRepository.getSettings()
            if !settings.hasCompletedOnboarding {
                showOnboarding = true
            }
        } catch {
            // If we can't read settings, assume onboarding hasn't been completed
            print("Failed to check onboarding status: \(error)")
            showOnboarding = true
        }
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
