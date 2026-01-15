// SocraticJournalApp.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main entry point for the Socratic Journal app
/// Note: @main is used only when building the iOS app directly
public struct SocraticJournalApp: App {
    private let repository: JournalRepositoryProtocol = InMemoryJournalRepository()
    private let settingsRepository: SettingsRepositoryProtocol = UserDefaultsSettingsRepository()
    @State private var themeMode: ThemeMode = .system

    public init() {}

    public var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeViewModel(repository: repository),
                repository: repository,
                settingsRepository: settingsRepository
            )
            .preferredColorScheme(colorScheme)
            .task {
                await loadTheme()
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
}
#endif
