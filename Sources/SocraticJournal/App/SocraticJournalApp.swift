// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UserNotifications
import FirebaseCore

/// Main entry point for the Circle app
@main
public struct SocraticJournalApp: App {
    // MARK: - Kept Infrastructure
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let subscriptionService: SubscriptionServiceProtocol = StoreKitSubscriptionService()
    private let analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    private let appReviewService: AppReviewService = AppReviewService.shared
    @State private var themeManager = ThemeManager.shared

    public init() {
        // Log environment configuration at startup
        AppEnvironment.logConfiguration()

        // Configure Firebase (for analytics and existing infrastructure)
        FirebaseApp.configure()

        // Configure AppsFlyer (for attribution tracking)
        AppsFlyerService.shared.configure()

        // Configure ThemeManager with settings repository
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())

        // Start network monitoring for offline support
        NetworkMonitor.shared.startMonitoring()
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView(
                settingsRepository: settingsRepository,
                subscriptionService: subscriptionService,
                analyticsService: analyticsService
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .task {
                await themeManager.loadTheme()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Request ATT when app becomes active
                AppsFlyerService.shared.requestTrackingAuthorization()
            }
        }
    }
}
#endif
