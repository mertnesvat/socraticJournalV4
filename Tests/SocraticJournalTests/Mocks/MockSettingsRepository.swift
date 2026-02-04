// MockSettingsRepository.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock implementation of SettingsRepositoryProtocol for testing
public final class MockSettingsRepository: SettingsRepositoryProtocol {
    // MARK: - Configuration

    /// Settings to return
    public var settings: UserSettings = .default

    /// Error to throw from operations
    public var errorToThrow: Error?

    // MARK: - Call Tracking

    public private(set) var getSettingsCallCount = 0
    public private(set) var saveSettingsCallCount = 0
    public private(set) var resetSettingsCallCount = 0
    public private(set) var clearAllDataCallCount = 0
    public private(set) var savedSettings: [UserSettings] = []

    // MARK: - Initialization

    public init(settings: UserSettings = .default) {
        self.settings = settings
    }

    // MARK: - SettingsRepositoryProtocol

    public func getSettings() async throws -> UserSettings {
        getSettingsCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        return settings
    }

    public func saveSettings(_ settings: UserSettings) async throws {
        saveSettingsCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        savedSettings.append(settings)
        self.settings = settings
    }

    public func resetSettings() async throws {
        resetSettingsCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        settings = .default
    }

    public func clearAllData() async throws {
        clearAllDataCallCount += 1

        if let error = errorToThrow {
            throw error
        }

        settings = .default
    }

    // MARK: - Test Helpers

    public func reset() {
        settings = .default
        errorToThrow = nil
        getSettingsCallCount = 0
        saveSettingsCallCount = 0
        resetSettingsCallCount = 0
        clearAllDataCallCount = 0
        savedSettings = []
    }
}
