// NotificationServiceProtocol.swift
// Circle
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
    func requestPermission() async -> Bool

    /// Get current notification permission status
    func getPermissionStatus() async -> NotificationPermissionStatus

    /// Schedule a daily prompt reminder at the specified time
    func scheduleDailyReminder(hour: Int, minute: Int) async throws

    /// Cancel the daily reminder notification
    func cancelDailyReminder() async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async
}

/// Notification identifiers
public enum NotificationIdentifier {
    public static let dailyPrompt = "daily-circle-prompt"
}

/// Notification category identifiers
public enum NotificationCategory {
    public static let dailyPrompt = "DAILY_PROMPT"
}

/// Notification action identifiers
public enum NotificationAction {
    public static let recordResponse = "RECORD_RESPONSE"
    public static let snooze = "SNOOZE_REMINDER"
}
