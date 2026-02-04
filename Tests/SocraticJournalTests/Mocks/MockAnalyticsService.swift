// MockAnalyticsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock analytics service for testing
/// Records all logged events and user properties for verification
public final class MockAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    // MARK: - Recorded Events

    /// All logged events with their parameters
    public private(set) var loggedEvents: [(event: AnalyticsEvent, parameters: [String: Any]?)] = []

    /// All set user properties
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

    /// Returns all parameters for logged events of the specified type
    public func parameters(for event: AnalyticsEvent) -> [[String: Any]?] {
        loggedEvents.filter { $0.event == event }.map { $0.parameters }
    }

    /// Returns the count of times an event was logged
    public func eventCount(for event: AnalyticsEvent) -> Int {
        loggedEvents.filter { $0.event == event }.count
    }

    /// Resets all recorded state
    public func reset() {
        loggedEvents.removeAll()
        userProperties.removeAll()
    }
}
