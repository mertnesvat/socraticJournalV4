// AnalyticsServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

public protocol AnalyticsServiceProtocol: Sendable {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func setUserProperty(_ name: String, value: String?)
}

public enum AnalyticsEvent: String, Sendable {
    // Session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionPaused = "session_paused"

    // Technique events
    case techniqueSelected = "technique_selected"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"
    case dailyGoalChanged = "daily_goal_changed"

    // Engagement
    case streakMaintained = "streak_maintained"
    case learnCardViewed = "learn_card_viewed"
}

public enum AnalyticsParameter: String, Sendable {
    case techniqueId = "technique_id"
    case techniqueName = "technique_name"
    case sessionDurationSeconds = "session_duration_seconds"
    case cyclesCompleted = "cycles_completed"
    case streakDays = "streak_days"
    case dailyGoalMinutes = "daily_goal_minutes"
    case themeMode = "theme_mode"
    case onboardingStep = "onboarding_step"
    case learningBitId = "learning_bit_id"
}
