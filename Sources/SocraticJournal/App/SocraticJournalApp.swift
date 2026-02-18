// SocraticJournalApp.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftData
import SwiftUI

@main
public struct SocraticJournalApp: App {
    @State private var services = ServiceContainer()
    @State private var themeManager = ThemeManager.shared

    public init() {
        AppEnvironment.logConfiguration()
        ThemeManager.shared.configure(settingsRepository: UserDefaultsSettingsRepository())
    }

    public var body: some Scene {
        WindowGroup {
            CircleRootView()
                .environment(services)
                .environment(themeManager)
                .modelContainer(services.modelContainer)
                .preferredColorScheme(themeManager.colorScheme)
                .task {
                    await themeManager.loadTheme()
                }
        }
    }
}
#endif
