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

    // MARK: - Social Notifications

    /// Schedule a daily new question reminder at the specified time
    /// - Parameters:
    ///   - hour: Hour component (0-23)
    ///   - minute: Minute component (0-59)
    func scheduleNewQuestionNotification(hour: Int, minute: Int) async throws

    /// Schedule a notification that a friend answered today's question
    /// - Parameters:
    ///   - friendName: Display name of the friend
    ///   - questionPreview: Short preview of the question they answered
    func scheduleFriendAnsweredNotification(friendName: String, questionPreview: String) async throws

    /// Schedule a streak maintenance reminder
    /// - Parameter streakDays: Current streak day count
    func scheduleStreakReminderNotification(streakDays: Int) async throws

    /// Schedule a FOMO nudge notification
    /// - Parameter friendCount: Number of friends who answered today
    func scheduleFOMONotification(friendCount: Int) async throws

    /// Schedule an award announcement notification
    /// - Parameter awardTitle: Title of the award (e.g. "Spiciest Take")
    func scheduleAwardNotification(awardTitle: String) async throws

    /// Cancel the daily question reminder
    func cancelDailyReminder() async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async

    /// Reschedule all notifications on app launch based on current settings
    /// - Parameter settings: Current user settings
    func rescheduleAllNotifications(settings: UserSettings) async
}

/// Notification identifiers for the app
public enum NotificationIdentifier {
    /// Identifier for daily question reminder
    public static let dailyQuestion = "daily-question-reminder"

    /// Prefix for friend answered notifications
    public static let friendAnswered = "friend-answered-"

    /// Identifier for streak reminder
    public static let streakReminder = "streak-reminder"

    /// Identifier for FOMO trigger notification
    public static let fomoTrigger = "fomo-trigger"

    /// Identifier for weekly award notification
    public static let weeklyAward = "weekly-award"
}

/// Notification category identifiers
public enum NotificationCategory {
    /// Category for new question notifications
    public static let newQuestion = "NEW_QUESTION"

    /// Category for friend answered notifications
    public static let friendAnswered = "FRIEND_ANSWERED"

    /// Category for streak reminder notifications
    public static let streakReminder = "STREAK_REMINDER"

    /// Category for FOMO trigger notifications
    public static let fomoTrigger = "FOMO_TRIGGER"

    /// Category for weekly award notifications
    public static let weeklyAward = "WEEKLY_AWARD"
}

/// Notification action identifiers
public enum NotificationAction {
    /// Action to record an answer
    public static let recordAnswer = "RECORD_ANSWER"

    /// Action to view a friend's profile
    public static let viewFriend = "VIEW_FRIEND"

    /// Action to open the app
    public static let openApp = "OPEN_APP"

    /// Action to snooze the reminder
    public static let snooze = "SNOOZE_REMINDER"
}
