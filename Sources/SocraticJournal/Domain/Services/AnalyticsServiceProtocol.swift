// AnalyticsServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining analytics tracking capabilities
public protocol AnalyticsServiceProtocol: Sendable {
    /// Log a custom analytics event
    /// - Parameters:
    ///   - event: The event type to log
    ///   - parameters: Optional additional parameters
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)

    /// Set a user property for analytics segmentation
    /// - Parameters:
    ///   - name: Property name
    ///   - value: Property value (nil to clear)
    func setUserProperty(_ name: String, value: String?)
}

/// Analytics events tracked in the app
public enum AnalyticsEvent: String, Sendable {
    // Session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionAbandoned = "session_abandoned"
    case clarityScoreReceived = "clarity_score_received"

    // Letter events
    case letterComposed = "letter_composed"
    case letterUnlocked = "letter_unlocked"
    case letterViewed = "letter_viewed"
    case letterPromptsRequested = "letter_prompts_requested"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"

    // Feature engagement
    case characterDiscoveryViewed = "character_discovery_viewed"
    case wisdomQuotesViewed = "wisdom_quotes_viewed"
    case statisticsViewed = "statistics_viewed"
    case exportDataRequested = "export_data_requested"

    // App review
    case appReviewRequested = "app_review_requested"
    case appReviewCompleted = "app_review_completed"
}

/// Analytics parameter keys
public enum AnalyticsParameter: String, Sendable {
    case sessionId = "session_id"
    case clarityScore = "clarity_score"
    case scoreCategory = "score_category"
    case exchangeCount = "exchange_count"
    case letterId = "letter_id"
    case letterDuration = "letter_duration_days"
    case themeMode = "theme_mode"
    case sessionCount = "session_count"
    case streakDays = "streak_days"
    case promptCount = "prompt_count"
}
