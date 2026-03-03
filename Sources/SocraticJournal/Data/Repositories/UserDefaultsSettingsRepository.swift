// UserDefaultsSettingsRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-based implementation of SettingsRepositoryProtocol
public final class UserDefaultsSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let settingsKey = "com.breathe.settings"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - SettingsRepositoryProtocol

    public func getSettings() async throws -> UserSettings {
        guard let data = defaults.data(forKey: settingsKey) else {
            return .default
        }
        do {
            return try decoder.decode(UserSettings.self, from: data)
        } catch {
            // If decoding fails, return default settings
            return .default
        }
    }

    public func saveSettings(_ settings: UserSettings) async throws {
        let data = try encoder.encode(settings)
        defaults.set(data, forKey: settingsKey)
    }

    public func resetSettings() async throws {
        defaults.removeObject(forKey: settingsKey)
    }

    public func clearAllData() async throws {
        // Clear settings
        defaults.removeObject(forKey: settingsKey)

        // Clear any other persisted data from UserDefaults
        let bundleId = Bundle.main.bundleIdentifier ?? "com.breathe"
        defaults.removePersistentDomain(forName: bundleId)
        defaults.synchronize()

        // Note: In-memory data will be cleared when the app restarts
        // In a production app with persistent storage, you would clear
        // the database/files here as well
    }
}
