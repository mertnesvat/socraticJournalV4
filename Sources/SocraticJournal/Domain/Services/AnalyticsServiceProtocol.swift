// AnalyticsServiceProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

public protocol AnalyticsServiceProtocol: Sendable {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func setUserProperty(_ name: String, value: String?)
}

public enum AnalyticsEvent: String, Sendable {
    // Breath session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionPaused = "session_paused"
    case sessionResumed = "session_resumed"

    // Pattern events
    case patternSelected = "pattern_selected"

    // Engagement
    case streakMaintained = "streak_maintained"
    case streakMilestone = "streak_milestone"

    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"

    // Learn
    case articleOpened = "article_opened"

    // Settings
    case themeChanged = "theme_changed"
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case dailyGoalChanged = "daily_goal_changed"
    case hapticToggled = "haptic_toggled"
}
