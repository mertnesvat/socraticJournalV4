// FirebaseAnalyticsService.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseAnalytics

public final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    public static let shared = FirebaseAnalyticsService()

    private init() {}

    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        #if DEBUG
        print("[Analytics] Event: \(event.rawValue), params: \(parameters ?? [:])")
        #endif
    }

    public func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
        #if DEBUG
        print("[Analytics] User property: \(name) = \(value ?? "nil")")
        #endif
    }
}
#endif
