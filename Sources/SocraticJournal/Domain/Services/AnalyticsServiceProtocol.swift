// AnalyticsServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining analytics tracking capabilities
public protocol AnalyticsServiceProtocol: Sendable {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func setUserProperty(_ name: String, value: String?)
}

/// Analytics events tracked in the app
public enum AnalyticsEvent: String, Sendable {
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"
    case onboardingScreenViewed = "onboarding_screen_viewed"

    // Settings
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"

    // Subscription
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

    // Circle events (to be expanded)
    case circleCreated = "circle_created"
    case circleMemberAdded = "circle_member_added"
    case voiceNoteRecorded = "voice_note_recorded"
    case voiceNotePlayed = "voice_note_played"
    case promptViewed = "prompt_viewed"
    case promptFeedbackGiven = "prompt_feedback_given"

    // App review
    case appReviewRequested = "app_review_requested"
    case appReviewCompleted = "app_review_completed"
}

/// Analytics parameter keys
public enum AnalyticsParameter: String, Sendable {
    case circleId = "circle_id"
    case circleName = "circle_name"
    case memberCount = "member_count"
    case promptId = "prompt_id"
    case voiceNoteDuration = "voice_note_duration"
    case themeMode = "theme_mode"
    case screenName = "screen_name"
}
