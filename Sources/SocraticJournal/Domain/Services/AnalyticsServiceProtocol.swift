// AnalyticsServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining analytics tracking capabilities
public protocol AnalyticsServiceProtocol: Sendable {
    /// Log a custom analytics event
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)

    /// Set a user property for analytics segmentation
    func setUserProperty(_ name: String, value: String?)
}

/// Analytics events tracked in the app
public enum AnalyticsEvent: String, Sendable {
    // Breath session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionPaused = "session_paused"

    // Pattern events
    case patternSelected = "pattern_selected"

    // Engagement events
    case streakMaintained = "streak_maintained"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"

    // Learn events
    case articleExpanded = "article_expanded"
}

/// Analytics parameter keys
public enum AnalyticsParameter: String, Sendable {
    case patternId = "pattern_id"
    case patternName = "pattern_name"
    case sessionDurationSeconds = "session_duration_seconds"
    case cyclesCompleted = "cycles_completed"
    case streakDays = "streak_days"
    case onboardingStep = "onboarding_step"
    case themeMode = "theme_mode"
    case articleTitle = "article_title"
}
