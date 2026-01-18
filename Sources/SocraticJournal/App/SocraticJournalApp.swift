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
            .task {
                await themeManager.loadTheme()
                await checkOnboardingStatus()
                await rescheduleNotifications()
                await clearBadge()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await clearBadge()
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(
                    settingsRepository: settingsRepository,
                    onDismiss: { showOnboarding = false }
                )
            }
        }
    }

    /// Check if user has completed onboarding and show it if not
    private func checkOnboardingStatus() async {
        do {
            let settings = try await settingsRepository.getSettings()
            if !settings.hasCompletedOnboarding {
                await MainActor.run {
                    showOnboarding = true
                }
            }
        } catch {
            // On error, assume new user and show onboarding
            await MainActor.run {
                showOnboarding = true
            }
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
