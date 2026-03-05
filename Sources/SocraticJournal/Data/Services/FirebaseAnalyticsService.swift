// FirebaseAnalyticsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseAnalytics

/// Firebase Analytics implementation of AnalyticsServiceProtocol
public final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    public static let shared = FirebaseAnalyticsService()

    private init() {}

    // MARK: - AnalyticsServiceProtocol

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

    // MARK: - Convenience Methods

    public func logSessionCompleted(patternId: String, durationSeconds: Double, cycles: Int) {
        logEvent(.sessionCompleted, parameters: [
            AnalyticsParameter.patternId.rawValue: patternId,
            AnalyticsParameter.sessionDurationSeconds.rawValue: durationSeconds,
            AnalyticsParameter.cyclesCompleted.rawValue: cycles,
        ])
    }

    public func logPatternSelected(patternId: String, patternName: String) {
        logEvent(.patternSelected, parameters: [
            AnalyticsParameter.patternId.rawValue: patternId,
            AnalyticsParameter.patternName.rawValue: patternName,
        ])
    }

    public func logOnboardingCompleted() {
        logEvent(.onboardingCompleted, parameters: nil)
    }

    public func logThemeChanged(theme: String) {
        logEvent(.themeChanged, parameters: [
            AnalyticsParameter.themeMode.rawValue: theme,
        ])
    }

    public func setStreakDays(_ days: Int) {
        setUserProperty(AnalyticsParameter.streakDays.rawValue, value: "\(days)")
    }
}
#endif
