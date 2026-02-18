// SocraticJournalApp.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import FirebaseCore

/// Main entry point for the Circle app
@main
public struct SocraticJournalApp: App {
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    private let subscriptionService: SubscriptionServiceProtocol = StoreKitSubscriptionService()
    @State private var themeManager = ThemeManager.shared

    public init() {
        AppEnvironment.logConfiguration()
        FirebaseApp.configure()
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
    }

    public var body: some Scene {
        WindowGroup {
            CircleRootView()
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .task {
                    await themeManager.loadTheme()
                }
        }
    }
}
#endif
