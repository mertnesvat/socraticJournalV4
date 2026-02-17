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
    case sessionQuestionShown = "session_question_shown"
    case sessionAnswerSubmitted = "session_answer_submitted"
    case sessionQuestionSkipped = "session_question_skipped"
    case sessionFollowUpGenerated = "session_follow_up_generated"
    case sessionInsightViewed = "session_insight_viewed"
    case sessionError = "session_error"

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

    // Subscription events
    case paywallViewed = "paywall_viewed"
    case paywallDismissed = "paywall_dismissed"
    case paywallProductsLoaded = "paywall_products_loaded"
    case paywallProductsLoadFailed = "paywall_products_load_failed"
    case paywallProductSelected = "paywall_product_selected"
    case paywallPurchaseStarted = "paywall_purchase_started"
    case paywallPurchaseCompleted = "paywall_purchase_completed"
    case paywallPurchaseFailed = "paywall_purchase_failed"
    case paywallPurchaseCancelled = "paywall_purchase_cancelled"
    case paywallRestoreStarted = "paywall_restore_started"
    case paywallRestoreCompleted = "paywall_restore_completed"
    case paywallRestoreFailed = "paywall_restore_failed"
    case subscriptionRestored = "subscription_restored"
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
    case questionIndex = "question_index"
    case questionText = "question_text"
    case answerLength = "answer_length"
    case responseTime = "response_time_ms"
    case errorType = "error_type"
    case phase = "phase"
}
