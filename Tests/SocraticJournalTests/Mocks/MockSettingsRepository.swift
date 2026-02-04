// MockSettingsRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock settings repository for testing
/// Allows configuring settings and tracking method calls
public final class MockSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    // MARK: - Configuration

    /// The settings to return/store
    public var settings: UserSettings = .default

    /// Error to throw from getSettings
    public var getSettingsError: Error?

    /// Error to throw from saveSettings
    public var saveSettingsError: Error?

    /// Error to throw from resetSettings
    public var resetSettingsError: Error?

    /// Error to throw from clearAllData
    public var clearAllDataError: Error?

    // MARK: - Call Tracking

    public private(set) var getSettingsCalled = false
    public private(set) var saveSettingsCalled = false
    public private(set) var savedSettings: UserSettings?
    public private(set) var resetSettingsCalled = false
    public private(set) var clearAllDataCalled = false

    // MARK: - Initialization

    public init(settings: UserSettings = .default) {
        self.settings = settings
    }

    // MARK: - SettingsRepositoryProtocol

    public func getSettings() async throws -> UserSettings {
        getSettingsCalled = true
        if let error = getSettingsError {
            throw error
        }
        return settings
    }

    public func saveSettings(_ settings: UserSettings) async throws {
        saveSettingsCalled = true
        savedSettings = settings
        if let error = saveSettingsError {
            throw error
        }
        self.settings = settings
    }

    public func resetSettings() async throws {
        resetSettingsCalled = true
        if let error = resetSettingsError {
            throw error
        }
        settings = .default
    }

    public func clearAllData() async throws {
        clearAllDataCalled = true
        if let error = clearAllDataError {
            throw error
        }
        settings = .default
    }

    // MARK: - Test Helpers

    /// Resets all tracking state
    public func reset() {
        getSettingsCalled = false
        saveSettingsCalled = false
        savedSettings = nil
        resetSettingsCalled = false
        clearAllDataCalled = false
    }
}
