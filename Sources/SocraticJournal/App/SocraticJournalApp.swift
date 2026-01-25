// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UserNotifications
import FirebaseCore

/// Main entry point for the Socratic Journal app
@main
public struct SocraticJournalApp: App {
    private let repository: JournalRepositoryProtocol = InMemoryJournalRepository()
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let notificationService: NotificationServiceProtocol = LocalNotificationService()
    private let analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    private let appReviewService: AppReviewService = AppReviewService.shared
    @State private var themeManager = ThemeManager.shared
    @State private var showOnboarding: Bool = false
    @State private var hasRequestedATT: Bool = false

    public init() {
        // Configure Firebase (must be called before using any Firebase services)
        FirebaseApp.configure()

        // Configure Firebase Messaging
        FirebaseNotificationService.shared.configure()

        // Configure AppsFlyer (for attribution tracking)
        AppsFlyerService.shared.configure()

        // Configure ThemeManager with settings repository
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())

        // Start network monitoring for offline support
        NetworkMonitor.shared.startMonitoring()

        // Configure offline sync queue (listens for connectivity changes)
        OfflineSyncQueue.shared.configure()

        // Start backend health monitoring for AI feature availability
        BackendHealthService.shared.startMonitoring()
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
                configureOfflineSyncHandler()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Request ATT when app becomes active (works reliably on both iPhone and iPad)
                if !hasRequestedATT {
                    hasRequestedATT = true
                    AppsFlyerService.shared.requestTrackingAuthorization()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await clearBadge()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .replayOnboarding)) { _ in
                // Small delay to allow settings sheet to dismiss first
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    await MainActor.run {
                        showOnboarding = true
                    }
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

    /// Configure offline sync handler with repository for session updates
    private func configureOfflineSyncHandler() {
        OfflineSyncHandler.shared.configure(repository: repository)

        // Try to process any pending offline requests now that we're configured
        Task {
            await OfflineSyncQueue.shared.processQueue()
        }
    }
}
#endif
