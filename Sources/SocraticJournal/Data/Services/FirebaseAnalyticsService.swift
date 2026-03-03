// FirebaseAnalyticsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseAnalytics

/// Firebase Analytics implementation
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

    // MARK: - Convenience

    public func logSessionCompleted(techniqueId: String, duration: TimeInterval, cycles: Int) {
        logEvent(.sessionCompleted, parameters: [
            AnalyticsParameter.techniqueId.rawValue: techniqueId,
            AnalyticsParameter.sessionDurationSeconds.rawValue: duration,
            AnalyticsParameter.cyclesCompleted.rawValue: cycles
        ])
    }

    public func logThemeChanged(theme: String) {
        logEvent(.themeChanged, parameters: [
            AnalyticsParameter.themeMode.rawValue: theme
        ])
    }

    public func setStreakDays(_ days: Int) {
        setUserProperty(AnalyticsParameter.streakDays.rawValue, value: "\(days)")
    }
}
#endif
