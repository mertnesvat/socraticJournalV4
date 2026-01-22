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

    /// Log session started event
    /// - Parameter sessionId: The session identifier
    public func logSessionStarted(sessionId: String) {
        logEvent(.sessionStarted, parameters: [
            AnalyticsParameter.sessionId.rawValue: sessionId
        ])
    }

    /// Log session completed event
    /// - Parameters:
    ///   - sessionId: The session identifier
    ///   - clarityScore: The clarity score achieved
    ///   - exchangeCount: Number of exchanges in the session
    public func logSessionCompleted(sessionId: String, clarityScore: Int, exchangeCount: Int) {
        let scoreCategory: String
        switch clarityScore {
        case 0..<40:
            scoreCategory = "emerging"
        case 40..<70:
            scoreCategory = "developing"
        case 70..<85:
            scoreCategory = "clear"
        default:
            scoreCategory = "profound"
        }

        logEvent(.sessionCompleted, parameters: [
            AnalyticsParameter.sessionId.rawValue: sessionId,
            AnalyticsParameter.clarityScore.rawValue: clarityScore,
            AnalyticsParameter.scoreCategory.rawValue: scoreCategory,
            AnalyticsParameter.exchangeCount.rawValue: exchangeCount
        ])
    }

    /// Log clarity score received event
    /// - Parameters:
    ///   - score: The clarity score
    ///   - sessionId: The session identifier
    public func logClarityScoreReceived(score: Int, sessionId: String) {
        logEvent(.clarityScoreReceived, parameters: [
            AnalyticsParameter.sessionId.rawValue: sessionId,
            AnalyticsParameter.clarityScore.rawValue: score
        ])
    }

    /// Log letter composed event
    /// - Parameters:
    ///   - letterId: The letter identifier
    ///   - durationDays: Days until unlock
    public func logLetterComposed(letterId: String, durationDays: Int) {
        logEvent(.letterComposed, parameters: [
            AnalyticsParameter.letterId.rawValue: letterId,
            AnalyticsParameter.letterDuration.rawValue: durationDays
        ])
    }

    /// Log letter unlocked event
    /// - Parameter letterId: The letter identifier
    public func logLetterUnlocked(letterId: String) {
        logEvent(.letterUnlocked, parameters: [
            AnalyticsParameter.letterId.rawValue: letterId
        ])
    }

    /// Log onboarding completed event
    public func logOnboardingCompleted() {
        logEvent(.onboardingCompleted, parameters: nil)
    }

    /// Log notification preference change
    /// - Parameter enabled: Whether notifications are enabled
    public func logNotificationPreferenceChanged(enabled: Bool) {
        logEvent(enabled ? .notificationEnabled : .notificationDisabled, parameters: nil)
    }

    /// Log theme change
    /// - Parameter theme: The new theme mode
    public func logThemeChanged(theme: String) {
        logEvent(.themeChanged, parameters: [
            AnalyticsParameter.themeMode.rawValue: theme
        ])
    }

    /// Log app review requested
    /// - Parameter sessionCount: Total sessions completed
    public func logAppReviewRequested(sessionCount: Int) {
        logEvent(.appReviewRequested, parameters: [
            AnalyticsParameter.sessionCount.rawValue: sessionCount
        ])
    }

    // MARK: - User Properties

    /// Set total session count as user property
    /// - Parameter count: Total completed sessions
    public func setSessionCount(_ count: Int) {
        setUserProperty(AnalyticsParameter.sessionCount.rawValue, value: "\(count)")
    }

    /// Set current streak as user property
    /// - Parameter days: Current streak in days
    public func setStreakDays(_ days: Int) {
        setUserProperty(AnalyticsParameter.streakDays.rawValue, value: "\(days)")
    }
}
#endif
