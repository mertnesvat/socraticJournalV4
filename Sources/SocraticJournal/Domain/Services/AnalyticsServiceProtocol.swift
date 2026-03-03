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
    // Breath session events
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionPaused = "session_paused"
    case sessionEndedEarly = "session_ended_early"
    case techniqueSelected = "technique_selected"

    // Onboarding events
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"

    // Settings events
    case notificationEnabled = "notification_enabled"
    case notificationDisabled = "notification_disabled"
    case themeChanged = "theme_changed"

    // Engagement events
    case streakMaintained = "streak_maintained"
    case streakBroken = "streak_broken"
    case streakMilestone = "streak_milestone"
}

/// Analytics parameter keys
public enum AnalyticsParameter: String, Sendable {
    // Session params
    case sessionDurationSeconds = "session_duration_seconds"
    case breathPattern = "breath_pattern"
    case breathsCompleted = "breaths_completed"

    // Streak params
    case streakDays = "streak_days"
    case milestoneDays = "milestone_days"

    // Onboarding params
    case onboardingStep = "onboarding_step"

    // General
    case themeMode = "theme_mode"
}
