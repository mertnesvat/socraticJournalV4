// FirebaseAnalyticsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseAnalytics

/// Firebase Analytics implementation of AnalyticsServiceProtocol
public final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    /// Shared instance for analytics operations
    public static let shared = FirebaseAnalyticsService()

    private init() {}

    // MARK: - AnalyticsServiceProtocol

    public func logEvent(_ event: AnalyticsEvent) {
        let params = event.parameters.isEmpty ? nil : event.parameters
        Analytics.logEvent(event.name, parameters: params)
        #if DEBUG
        print("[Analytics] Event: \(event.name), params: \(params ?? [:])")
        #endif
    }

    public func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
        #if DEBUG
        print("[Analytics] User property: \(name) = \(value ?? "nil")")
        #endif
    }

    // MARK: - Convenience: User Properties

    /// Set the number of circles the user belongs to
    /// - Parameter count: Number of circles
    public func setCircleCount(_ count: Int) {
        setUserProperty(AnalyticsUserProperty.circleCount.rawValue, value: "\(count)")
    }

    /// Set the total number of voice notes the user has sent
    /// - Parameter count: Lifetime voice note count
    public func setTotalVoiceNotesSent(_ count: Int) {
        setUserProperty(AnalyticsUserProperty.totalVoiceNotesSent.rawValue, value: "\(count)")
    }

    /// Set the current daily streak
    /// - Parameter days: Consecutive days with at least one response
    public func setCurrentStreakDays(_ days: Int) {
        setUserProperty(AnalyticsUserProperty.currentStreakDays.rawValue, value: "\(days)")
    }
}
#endif
