// MockAnalyticsService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock analytics service for testing
public final class MockAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    // MARK: - Tracked Events

    public struct LoggedEvent {
        public let event: AnalyticsEvent
        public let parameters: [String: Any]?
    }

    public private(set) var loggedEvents: [LoggedEvent] = []
    public private(set) var userProperties: [String: String?] = [:]

    // MARK: - Init

    public init() {}

    // MARK: - Protocol Methods

    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        loggedEvents.append(LoggedEvent(event: event, parameters: parameters))
    }

    public func setUserProperty(_ name: String, value: String?) {
        userProperties[name] = value
    }

    // MARK: - Additional logEvent for string-based events

    public func logEvent(_ eventName: String, parameters: [String: Any]?) {
        // Store as custom event - for the PaywallViewModel style calls
        customEvents.append(CustomEvent(name: eventName, parameters: parameters))
    }

    public struct CustomEvent {
        public let name: String
        public let parameters: [String: Any]?
    }

    public private(set) var customEvents: [CustomEvent] = []

    // MARK: - Test Helpers

    public func reset() {
        loggedEvents = []
        userProperties = [:]
        customEvents = []
    }

    public func hasLoggedEvent(_ event: AnalyticsEvent) -> Bool {
        loggedEvents.contains { $0.event == event }
    }

    public func hasLoggedCustomEvent(_ name: String) -> Bool {
        customEvents.contains { $0.name == name }
    }

    public func eventCount(for event: AnalyticsEvent) -> Int {
        loggedEvents.filter { $0.event == event }.count
    }

    public func customEventCount(for name: String) -> Int {
        customEvents.filter { $0.name == name }.count
    }

    public func lastParameters(for event: AnalyticsEvent) -> [String: Any]? {
        loggedEvents.last { $0.event == event }?.parameters
    }

    public func lastCustomParameters(for name: String) -> [String: Any]? {
        customEvents.last { $0.name == name }?.parameters
    }
}
