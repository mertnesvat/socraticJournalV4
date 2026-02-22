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
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let notificationService: NotificationServiceProtocol = LocalNotificationService()
    private let subscriptionService: SubscriptionServiceProtocol = StoreKitSubscriptionService()
    private let analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    @State private var themeManager = ThemeManager.shared
    @State private var showOnboarding: Bool = false
    @State private var hasRequestedATT: Bool = false

    public init() {
        // Log environment configuration at startup
        AppEnvironment.logConfiguration()

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
                settingsRepository: settingsRepository,
                notificationService: notificationService,
                subscriptionService: subscriptionService,
                analyticsService: analyticsService
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .task {
                await themeManager.loadTheme()
                await checkOnboardingStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Request ATT when app becomes active (works reliably on both iPhone and iPad)
                if !hasRequestedATT {
                    hasRequestedATT = true
                    AppsFlyerService.shared.requestTrackingAuthorization()
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                NewOnboardingView(
                    settingsRepository: settingsRepository,
                    onDismiss: {
                        showOnboarding = false
                    }
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
}
#endif
