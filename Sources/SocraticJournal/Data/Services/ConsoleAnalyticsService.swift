// ConsoleAnalyticsService.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Local analytics service that logs events to the console.
/// Replace with Firebase Analytics or any other provider by conforming to the same protocol.
public final class ConsoleAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    public init() {}

    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        #if DEBUG
        if let parameters {
            print("[Analytics] \(event.rawValue) — \(parameters)")
        } else {
            print("[Analytics] \(event.rawValue)")
        }
        #endif
    }

    public func setUserProperty(_ name: String, value: String?) {
        #if DEBUG
        print("[Analytics] Property: \(name) = \(value ?? "nil")")
        #endif
    }
}
