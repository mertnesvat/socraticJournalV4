// MockAnalyticsService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

public final class MockAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    public struct LoggedEvent {
        public let event: AnalyticsEvent
        public let parameters: [String: Any]?
    }

    public private(set) var loggedEvents: [LoggedEvent] = []
    public private(set) var userProperties: [String: String?] = [:]

    public init() {}

    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        loggedEvents.append(LoggedEvent(event: event, parameters: parameters))
    }

    public func setUserProperty(_ name: String, value: String?) {
        userProperties[name] = value
    }

    public func reset() {
        loggedEvents = []
        userProperties = [:]
    }

    public func hasLoggedEvent(_ event: AnalyticsEvent) -> Bool {
        loggedEvents.contains { $0.event == event }
    }

    public func eventCount(for event: AnalyticsEvent) -> Int {
        loggedEvents.filter { $0.event == event }.count
    }

    public func lastParameters(for event: AnalyticsEvent) -> [String: Any]? {
        loggedEvents.last { $0.event == event }?.parameters
    }
}
