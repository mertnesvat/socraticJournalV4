// NotificationServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Notification permission status
public enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case provisional
}

/// Notification identifiers
enum NotificationIdentifier {
    static let dailyReminder = "com.breathe.dailyReminder"
}

/// Notification categories
enum NotificationCategory {
    static let breathReminder = "breathReminder"
}

/// Notification actions
enum NotificationAction {
    static let startSession = "startSession"
}

/// Protocol defining notification capabilities for the Breath app
public protocol NotificationServiceProtocol: Sendable {
    func requestPermission() async -> Bool
    func getPermissionStatus() async -> NotificationPermissionStatus
    func scheduleDailyReminder(hour: Int, minute: Int) async throws
    func cancelDailyReminder() async
    func removeAllPendingNotifications() async
    func rescheduleAllNotifications(settings: UserSettings) async
}
