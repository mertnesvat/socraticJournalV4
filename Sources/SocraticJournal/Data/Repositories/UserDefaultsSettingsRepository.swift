// UserDefaultsSettingsRepository.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

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

    public func getSettings() async throws -> UserSettings {
        guard let data = defaults.data(forKey: settingsKey) else {
            return .default
        }
        do {
            return try decoder.decode(UserSettings.self, from: data)
        } catch {
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
        defaults.removeObject(forKey: settingsKey)
        defaults.removeObject(forKey: "com.breathe.sessions")
    }
}
