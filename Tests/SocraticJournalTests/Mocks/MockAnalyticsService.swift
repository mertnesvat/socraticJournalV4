// MockAnalyticsService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock implementation of AnalyticsServiceProtocol for testing
public final class MockAnalyticsService: AnalyticsServiceProtocol {
    // MARK: - Call Tracking

    public private(set) var loggedEvents: [(event: AnalyticsEvent, parameters: [String: Any]?)] = []
    public private(set) var userProperties: [String: String?] = [:]

    // MARK: - Initialization

    public init() {}

    // MARK: - AnalyticsServiceProtocol

    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        loggedEvents.append((event: event, parameters: parameters))
    }

    public func setUserProperty(_ name: String, value: String?) {
        userProperties[name] = value
    }

    // MARK: - Test Helpers

    /// Returns true if the specified event was logged
    public func hasLoggedEvent(_ event: AnalyticsEvent) -> Bool {
        loggedEvents.contains { $0.event == event }
    }

    /// Returns the count of how many times an event was logged
    public func eventCount(for event: AnalyticsEvent) -> Int {
        loggedEvents.filter { $0.event == event }.count
    }

    /// Returns parameters for the last logged event of the specified type
    public func lastParameters(for event: AnalyticsEvent) -> [String: Any]? {
        loggedEvents.last { $0.event == event }?.parameters
    }

    /// Resets all tracked data
    public func reset() {
        loggedEvents = []
        userProperties = [:]
    }
}
