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

    /// Schedule a notification for when a letter is ready to be read
    /// - Parameter letter: The future letter to schedule notification for
    func scheduleLetterUnlock(letter: FutureLetter) async throws

    /// Cancel a previously scheduled letter unlock notification
    /// - Parameter letterId: The ID of the letter whose notification should be cancelled
    func cancelLetterNotification(letterId: String) async

    /// Schedule a daily journaling reminder at the specified time
    /// - Parameters:
    ///   - hour: Hour component (0-23)
    ///   - minute: Minute component (0-59)
    func scheduleDailyReminder(hour: Int, minute: Int) async throws

    /// Cancel the daily reminder notification
    func cancelDailyReminder() async

    /// Reschedule all pending notifications (called on app launch)
    /// - Parameters:
    ///   - letters: All letters that may need notifications
    ///   - settings: Current user settings for daily reminder
    func rescheduleAllNotifications(letters: [FutureLetter], settings: UserSettings) async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async
}

/// Notification identifiers for the app
public enum NotificationIdentifier {
    /// Prefix for letter unlock notifications
    public static let letterPrefix = "letter-unlock-"

    /// Identifier for daily reminder notification
    public static let dailyReminder = "daily-journaling-reminder"

    /// Generate letter notification identifier from letter ID
    public static func forLetter(_ letterId: String) -> String {
        return "\(letterPrefix)\(letterId)"
    }
}

/// Notification category identifiers
public enum NotificationCategory {
    /// Category for letter unlock notifications
    public static let letterReady = "LETTER_READY"

    /// Category for daily reminder notifications
    public static let dailyReminder = "DAILY_REMINDER"
}

/// Notification action identifiers
public enum NotificationAction {
    /// Action to open the letter
    public static let openLetter = "OPEN_LETTER"

    /// Action to start a new journal session
    public static let startSession = "START_SESSION"

    /// Action to snooze the reminder
    public static let snooze = "SNOOZE_REMINDER"
}
