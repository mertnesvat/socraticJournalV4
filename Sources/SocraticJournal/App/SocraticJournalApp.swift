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
    @State private var themeMode: ThemeMode = .system

    public init() {
        // Configure Firebase Messaging
        FirebaseNotificationService.shared.configure()
    }

    public var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeViewModel(repository: repository),
                repository: repository,
                settingsRepository: settingsRepository,
                notificationService: notificationService
            )
            .preferredColorScheme(colorScheme)
            .task {
                await loadTheme()
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

    private var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    private func loadTheme() async {
        do {
            let settings = try await settingsRepository.getSettings()
            themeMode = settings.themeMode
        } catch {
            themeMode = .system
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
