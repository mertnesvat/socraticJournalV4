// AnalyticsServiceProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining analytics tracking capabilities
public protocol AnalyticsServiceProtocol: Sendable {
    /// Log a custom analytics event
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)

    /// Set a user property for analytics segmentation
    func setUserProperty(_ name: String, value: String?)
}

/// Analytics events tracked in the Breath Pacer app
public enum AnalyticsEvent: String, Sendable {
    // Session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionPaused = "session_paused"

    // Technique events
    case techniqueSelected = "technique_selected"
    case durationSelected = "duration_selected"

    // Engagement events
    case streakMaintained = "streak_maintained"
    case dailyGoalReached = "daily_goal_reached"

    // Navigation events
    case tabSelected = "tab_selected"
    case learnArticleViewed = "learn_article_viewed"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"
    case dailyGoalChanged = "daily_goal_changed"
}

/// Analytics parameter keys
public enum AnalyticsParameter: String, Sendable {
    case techniqueId = "technique_id"
    case techniqueName = "technique_name"
    case sessionDurationSeconds = "session_duration_seconds"
    case cyclesCompleted = "cycles_completed"
    case streakDays = "streak_days"
    case tabName = "tab_name"
    case articleId = "article_id"
    case themeMode = "theme_mode"
    case dailyGoalMinutes = "daily_goal_minutes"
}
