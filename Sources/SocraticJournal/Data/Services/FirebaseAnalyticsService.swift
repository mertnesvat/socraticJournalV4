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

    /// Log breath session started event
    public func logSessionStarted(pattern: String) {
        logEvent(.sessionStarted, parameters: [
            AnalyticsParameter.breathPattern.rawValue: pattern
        ])
    }

    /// Log breath session completed event
    public func logSessionCompleted(pattern: String, durationSeconds: Double, breathsCompleted: Int) {
        logEvent(.sessionCompleted, parameters: [
            AnalyticsParameter.breathPattern.rawValue: pattern,
            AnalyticsParameter.sessionDurationSeconds.rawValue: durationSeconds,
            AnalyticsParameter.breathsCompleted.rawValue: breathsCompleted
        ])
    }

    /// Log onboarding completed event
    public func logOnboardingCompleted() {
        logEvent(.onboardingCompleted, parameters: nil)
    }

    /// Log notification preference change
    public func logNotificationPreferenceChanged(enabled: Bool) {
        logEvent(enabled ? .notificationEnabled : .notificationDisabled, parameters: nil)
    }

    /// Log theme change
    public func logThemeChanged(theme: String) {
        logEvent(.themeChanged, parameters: [
            AnalyticsParameter.themeMode.rawValue: theme
        ])
    }

    // MARK: - User Properties

    /// Set current streak as user property
    public func setStreakDays(_ days: Int) {
        setUserProperty(AnalyticsParameter.streakDays.rawValue, value: "\(days)")
    }
}
#endif
