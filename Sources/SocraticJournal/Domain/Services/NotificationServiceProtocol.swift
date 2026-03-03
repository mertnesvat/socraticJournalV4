// NotificationServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Notification permission status
public enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}

/// Protocol for scheduling and managing notifications
public protocol NotificationServiceProtocol: Sendable {
    /// Request notification permissions from the user
    /// - Returns: True if permission was granted, false otherwise
    func requestPermission() async -> Bool

    /// Get current notification permission status
    func getPermissionStatus() async -> NotificationPermissionStatus

    /// Schedule a daily breath reminder at the specified time
    /// - Parameters:
    ///   - hour: Hour component (0-23)
    ///   - minute: Minute component (0-59)
    func scheduleBreathReminder(hour: Int, minute: Int) async throws

    /// Cancel the daily breath reminder
    func cancelDailyReminder() async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async

    /// Reschedule all notifications on app launch based on current settings
    /// - Parameter settings: Current user settings
    func rescheduleAllNotifications(settings: UserSettings) async
}

/// Notification identifiers for the app
public enum NotificationIdentifier {
    /// Identifier for daily breath reminder
    public static let dailyBreathReminder = "daily-breath-reminder"
}

/// Notification category identifiers
public enum NotificationCategory {
    /// Category for breath reminder notifications
    public static let breathReminder = "BREATH_REMINDER"
}

/// Notification action identifiers
public enum NotificationAction {
    /// Action to start a breathing session
    public static let startSession = "START_SESSION"

    /// Action to open the app
    public static let openApp = "OPEN_APP"
}
