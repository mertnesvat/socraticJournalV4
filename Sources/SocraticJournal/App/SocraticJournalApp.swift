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

    // MARK: - Auth

    @State private var authState = AuthState(service: LocalAuthService())

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
            rootView
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .task {
                    await themeManager.loadTheme()
                    await authState.loadCurrentUser()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Request ATT when app becomes active
                    AppsFlyerService.shared.requestTrackingAuthorization()
                }
        }
    }

    // MARK: - Root Routing

    @ViewBuilder
    private var rootView: some View {
        if authState.isAuthenticated {
            MainTabView(
                settingsRepository: settingsRepository,
                subscriptionService: subscriptionService,
                analyticsService: analyticsService,
                authState: authState
            )
        } else {
            CreateProfileView(authState: authState)
        }
    }
}
#endif
