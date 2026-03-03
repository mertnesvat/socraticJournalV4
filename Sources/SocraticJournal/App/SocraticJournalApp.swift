// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import FirebaseCore

@main
public struct SocraticJournalApp: App {
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let breathSessionRepository: BreathSessionRepositoryProtocol = UserDefaultsBreathSessionRepository()
    private let notificationService: NotificationServiceProtocol = LocalNotificationService()
    private let analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    @State private var themeManager = ThemeManager.shared
    @State private var showOnboarding: Bool = false

    public init() {
        AppEnvironment.logConfiguration()
        FirebaseApp.configure()
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
        NetworkMonitor.shared.startMonitoring()
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView(
                settingsRepository: settingsRepository,
                breathSessionRepository: breathSessionRepository,
                notificationService: notificationService,
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
}
#endif
