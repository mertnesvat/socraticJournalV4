// NotificationServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining notification operations for the Circle app
public protocol NotificationServiceProtocol: Sendable {
    /// Request notification permissions from the user
    func requestPermission() async -> Bool

    /// Get current notification permission status
    func getPermissionStatus() async -> NotificationPermissionStatus

    /// Schedule a daily prompt reminder at the specified time
    func scheduleDailyReminder(hour: Int, minute: Int, circleName: String) async throws

    /// Cancel the daily reminder notification
    func cancelDailyReminder() async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async
}

/// Notification permission status
public enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}
