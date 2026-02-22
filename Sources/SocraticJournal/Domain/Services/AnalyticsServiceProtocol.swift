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
    // Question events
    case questionViewed = "question_viewed"
    case questionAnswered = "question_answered"
    case questionSkipped = "question_skipped"
    case questionShared = "question_shared"

    // Recording events
    case recordingStarted = "recording_started"
    case recordingCompleted = "recording_completed"
    case recordingReRecorded = "recording_re_recorded"
    case recordingDuration = "recording_duration"

    // Reveal events
    case friendAnswerUnlocked = "friend_answer_unlocked"
    case friendAnswerPlayed = "friend_answer_played"
    case friendAnswerReacted = "friend_answer_reacted"

    // Social events
    case friendRequestSent = "friend_request_sent"
    case friendRequestAccepted = "friend_request_accepted"
    case friendRemoved = "friend_removed"
    case friendSearched = "friend_searched"

    // Engagement events
    case streakMaintained = "streak_maintained"
    case streakBroken = "streak_broken"
    case streakMilestone = "streak_milestone"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"

    // Virality events
    case questionSharedExternal = "question_shared_external"
    case appInviteSent = "app_invite_sent"
    case contactsImportStarted = "contacts_import_started"
    case shareCardGenerated = "share_card_generated"

    // Profile events
    case profileViewed = "profile_viewed"
    case profileEdited = "profile_edited"
    case historyViewed = "history_viewed"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"

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
    // Question params
    case questionId = "question_id"
    case questionText = "question_text"
    case questionCategory = "question_category"
    case questionLevel = "question_level"

    // Recording params
    case recordingDurationSeconds = "recording_duration_seconds"
    case recordingFileSize = "recording_file_size"

    // Social params
    case friendId = "friend_id"
    case friendCount = "friend_count"
    case searchQuery = "search_query"

    // Reveal params
    case revealId = "reveal_id"
    case emojiReaction = "emoji_reaction"

    // Streak params
    case streakDays = "streak_days"
    case milestoneDays = "milestone_days"

    // Onboarding params
    case onboardingStep = "onboarding_step"

    // Share params
    case shareCardStyle = "share_card_style"
    case sharePlatform = "share_platform"

    // General
    case themeMode = "theme_mode"
}
