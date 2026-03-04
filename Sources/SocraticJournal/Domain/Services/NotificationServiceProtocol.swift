// NotificationServiceProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Notification permission status
public enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}

/// Protocol for scheduling and managing breath reminder notifications
public protocol NotificationServiceProtocol: Sendable {
    /// Request notification permissions from the user
    func requestPermission() async -> Bool

    /// Get current notification permission status
    func getPermissionStatus() async -> NotificationPermissionStatus

    /// Schedule a daily breath reminder at the specified time
    func scheduleDailyBreathReminder(hour: Int, minute: Int) async throws

    /// Cancel the daily breath reminder
    func cancelDailyReminder() async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async
}

/// Notification identifiers
public enum NotificationIdentifier {
    public static let dailyBreathReminder = "daily-breath-reminder"
}
