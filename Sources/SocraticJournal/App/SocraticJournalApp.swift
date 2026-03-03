// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import FirebaseCore

/// Main entry point for the Breath Pacer app
@main
public struct SocraticJournalApp: App {
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let notificationService: NotificationServiceProtocol = LocalNotificationService()
    private let analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    @State private var themeManager = ThemeManager.shared
    @State private var showOnboarding: Bool = false

    public init() {
        // Configure Firebase (must be called before using any Firebase services)
        FirebaseApp.configure()

        // Configure AppsFlyer (for attribution tracking)
        AppsFlyerService.shared.configure()

        // Configure ThemeManager with settings repository
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
    }

    @State private var deepLinkTab: MainTab?

    public var body: some Scene {
        WindowGroup {
            MainTabView(
                settingsRepository: settingsRepository,
                notificationService: notificationService,
                analyticsService: analyticsService,
                deepLinkTab: $deepLinkTab
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .task {
                await themeManager.loadTheme()
                await checkOnboardingStatus()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                NewOnboardingView(
                    settingsRepository: settingsRepository,
                    notificationService: notificationService,
                    onDismiss: {
                        showOnboarding = false
                    }
                )
            }
        }
    }

    /// Handle deep-link URLs (e.g., breathe://start from notification actions)
    private func handleDeepLink(_ url: URL) {
        if url.scheme == "breathe" || url.host == "start" {
            deepLinkTab = .breathe
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
