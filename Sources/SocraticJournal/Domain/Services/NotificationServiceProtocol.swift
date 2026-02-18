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

    // MARK: - Circle-Specific Notifications

    /// Schedule a daily prompt notification for a specific circle.
    /// - Parameters:
    ///   - circleId: The circle identifier.
    ///   - circleName: The circle display name.
    ///   - circleIcon: The SF Symbol name for the circle icon.
    ///   - hour: The hour to send the notification (0-23).
    ///   - minute: The minute to send the notification (0-59).
    ///   - promptSnippet: The first portion of today's prompt text.
    func scheduleCirclePrompt(
        circleId: UUID,
        circleName: String,
        circleIcon: String,
        hour: Int,
        minute: Int,
        promptSnippet: String
    ) async throws

    /// Cancel all pending notifications for a specific circle.
    /// - Parameter circleId: The circle identifier.
    func cancelCircleNotifications(for circleId: UUID) async

    /// Update the app badge count.
    /// - Parameter count: The number to display on the badge. Pass 0 to clear.
    func setBadgeCount(_ count: Int) async

    /// Clear the app badge count (sets to 0).
    func clearBadge() async
}

/// Per-circle notification settings stored in UserDefaults.
public struct CircleNotificationSetting: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID { circleId }
    public var circleId: UUID
    public var isEnabled: Bool
    public var hour: Int
    public var minute: Int

    public init(
        circleId: UUID,
        isEnabled: Bool = true,
        hour: Int = 18,
        minute: Int = 0
    ) {
        self.circleId = circleId
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
    }

    /// Date representation of the notification time for DatePicker binding.
    public var notificationTime: Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Update hour and minute from a Date value.
    public mutating func setTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        hour = components.hour ?? 18
        minute = components.minute ?? 0
    }
}

/// Notification identifiers
public enum NotificationIdentifier {
    public static let dailyPrompt = "daily-circle-prompt"

    /// Generate a per-circle notification identifier.
    public static func circlePrompt(for circleId: UUID) -> String {
        "circle-prompt-\(circleId.uuidString)"
    }
}

/// Notification category identifiers
public enum NotificationCategory {
    public static let dailyPrompt = "DAILY_PROMPT"
    public static let circlePrompt = "CIRCLE_PROMPT"
}

/// Notification action identifiers
public enum NotificationAction {
    public static let recordResponse = "RECORD_RESPONSE"
    public static let snooze = "SNOOZE_REMINDER"
}
