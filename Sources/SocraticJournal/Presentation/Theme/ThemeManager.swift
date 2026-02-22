// ThemeManager.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Global theme manager that provides reactive theme state across the app
/// Use with .environment() to propagate theme changes to all views including full-screen covers
@Observable
@MainActor
public final class ThemeManager {
    // MARK: - Singleton

    public static let shared = ThemeManager()

    // MARK: - State

    public private(set) var themeMode: ThemeMode = .dark

    // MARK: - Computed Properties

    /// The ColorScheme to apply via .preferredColorScheme()
    public var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    // MARK: - Dependencies

    private var settingsRepository: SettingsRepositoryProtocol?

    // MARK: - Init

    private init() {}

    // MARK: - Configuration

    /// Configure the theme manager with a settings repository
    /// Call this at app launch
    public func configure(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    // MARK: - Actions

    /// Load the theme from persistent storage
    public func loadTheme() async {
        guard let settingsRepository else { return }
        do {
            let settings = try await settingsRepository.getSettings()
            themeMode = settings.themeMode
        } catch {
            themeMode = .system
        }
    }

    /// Update the theme and persist to storage
    public func setTheme(_ mode: ThemeMode) async {
        themeMode = mode
        guard let settingsRepository else { return }
        do {
            var settings = try await settingsRepository.getSettings()
            settings.themeMode = mode
            try await settingsRepository.saveSettings(settings)
        } catch {
            // Theme change is still applied in memory even if persistence fails
        }
    }

    /// Update theme from external source (e.g., SettingsViewModel)
    /// This updates the in-memory state without saving (caller handles persistence)
    public func updateTheme(_ mode: ThemeMode) {
        themeMode = mode
    }
}

// MARK: - Environment Key

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager.shared
}

extension EnvironmentValues {
    public var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Apply the current theme's color scheme from ThemeManager
    /// Use this on full-screen covers and sheets that don't inherit from parent
    public func applyTheme(from themeManager: ThemeManager) -> some View {
        self.preferredColorScheme(themeManager.colorScheme)
    }
}
#endif
