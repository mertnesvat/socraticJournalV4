// AnalyticsServiceProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining analytics tracking capabilities
public protocol AnalyticsServiceProtocol: Sendable {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func setUserProperty(_ name: String, value: String?)
}

/// Analytics events tracked in the app
public enum AnalyticsEvent: String, Sendable {
    // Session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionPaused = "session_paused"
    case sessionAbandoned = "session_abandoned"

    // Technique events
    case techniqueSelected = "technique_selected"

    // Engagement events
    case streakMaintained = "streak_maintained"
    case streakBroken = "streak_broken"
    case streakMilestone = "streak_milestone"
    case dailyGoalReached = "daily_goal_reached"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"
    case dailyGoalChanged = "daily_goal_changed"

    // Learn events
    case articleViewed = "article_viewed"
    case categoryFiltered = "category_filtered"
}

/// Analytics parameter keys
public enum AnalyticsParameter: String, Sendable {
    case techniqueId = "technique_id"
    case techniqueName = "technique_name"
    case sessionDuration = "session_duration"
    case cyclesCompleted = "cycles_completed"
    case streakDays = "streak_days"
    case dailyGoalMinutes = "daily_goal_minutes"
    case articleId = "article_id"
    case category = "category"
    case themeMode = "theme_mode"
    case onboardingStep = "onboarding_step"
}
