// MockSettingsRepository.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock settings repository for testing
public final class MockSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    // MARK: - State

    public var settings: UserSettings = .default
    public var shouldFail: Bool = false
    public var failError: Error = NSError(domain: "MockError", code: -1)

    // MARK: - Call Tracking

    public private(set) var getSettingsCalled: Bool = false
    public private(set) var getSettingsCallCount: Int = 0
    public private(set) var saveSettingsCalled: Bool = false
    public private(set) var saveSettingsCallCount: Int = 0
    public private(set) var lastSavedSettings: UserSettings?
    public private(set) var resetSettingsCalled: Bool = false
    public private(set) var clearAllDataCalled: Bool = false

    // MARK: - Init

    public init(settings: UserSettings = .default) {
        self.settings = settings
    }

    // MARK: - Protocol Methods

    public func getSettings() async throws -> UserSettings {
        getSettingsCalled = true
        getSettingsCallCount += 1

        if shouldFail {
            throw failError
        }

        return settings
    }

    public func saveSettings(_ settings: UserSettings) async throws {
        saveSettingsCalled = true
        saveSettingsCallCount += 1
        lastSavedSettings = settings

        if shouldFail {
            throw failError
        }

        self.settings = settings
    }

    public func resetSettings() async throws {
        resetSettingsCalled = true

        if shouldFail {
            throw failError
        }

        settings = .default
    }

    public func clearAllData() async throws {
        clearAllDataCalled = true

        if shouldFail {
            throw failError
        }

        settings = .default
    }

    // MARK: - Test Helpers

    public func reset() {
        settings = .default
        shouldFail = false
        getSettingsCalled = false
        getSettingsCallCount = 0
        saveSettingsCalled = false
        saveSettingsCallCount = 0
        lastSavedSettings = nil
        resetSettingsCalled = false
        clearAllDataCalled = false
    }
}
