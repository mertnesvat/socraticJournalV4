// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import FirebaseCore

/// Main entry point for the Breathe app
@main
public struct SocraticJournalApp: App {
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let notificationService: NotificationServiceProtocol = LocalNotificationService()
    private let sessionRepository: BreathSessionRepositoryProtocol = UserDefaultsBreathSessionRepository()
    private let analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    @State private var themeManager = ThemeManager.shared
    @State private var showOnboarding: Bool = false

    public init() {
        AppEnvironment.logConfiguration()
        FirebaseApp.configure()
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
        NetworkMonitor.shared.startMonitoring()
        migrateToAppGroupIfNeeded()
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView(
                settingsRepository: settingsRepository,
                notificationService: notificationService,
                sessionRepository: sessionRepository,
                analyticsService: analyticsService
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .task {
                await themeManager.loadTheme()
                await checkOnboardingStatus()
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                NewOnboardingView(
                    settingsRepository: settingsRepository,
                    onDismiss: {
                        showOnboarding = false
                    }
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .replayOnboarding)) { _ in
                showOnboarding = true
            }
        }
    }

    private func checkOnboardingStatus() async {
        do {
            let settings = try await settingsRepository.getSettings()
            if !settings.hasCompletedOnboarding {
                await MainActor.run {
                    showOnboarding = true
                }
            }
        } catch {
            await MainActor.run {
                showOnboarding = true
            }
        }
    }

    /// One-time migration of UserDefaults data from `.standard` to the App Group shared suite.
    /// Runs synchronously at launch before any repository reads occur.
    /// Skips silently if the shared suite already contains data (migration already done),
    /// or if the App Group is not available (simulator without entitlements).
    private func migrateToAppGroupIfNeeded() {
        guard let sharedSuite = UserDefaults(suiteName: UserDefaults.appGroupIdentifier) else { return }

        // Keys we need to migrate
        let keysToMigrate = [
            "com.socraticjournal.settings",
            "com.breathe.sessions",
            "com.breathe.bolt"
        ]

        var migratedAny = false
        for key in keysToMigrate {
            // Only copy if the shared suite doesn't already have this key
            guard sharedSuite.object(forKey: key) == nil else { continue }
            if let value = UserDefaults.standard.object(forKey: key) {
                sharedSuite.set(value, forKey: key)
                migratedAny = true
            }
        }

        if migratedAny {
            sharedSuite.synchronize()
        }
    }
}
#endif
