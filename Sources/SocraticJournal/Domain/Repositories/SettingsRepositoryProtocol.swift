// SettingsRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining settings data operations
public protocol SettingsRepositoryProtocol: Sendable {
    /// Fetches current user settings
    func getSettings() async throws -> UserSettings

    /// Saves user settings
    func saveSettings(_ settings: UserSettings) async throws

    /// Resets settings to defaults
    func resetSettings() async throws

    /// Clears all app data (sessions, letters, settings)
    func clearAllData() async throws
}
