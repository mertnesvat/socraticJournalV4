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
    func requestPermission() async -> Bool

    /// Get current notification permission status
    func getPermissionStatus() async -> NotificationPermissionStatus

    /// Schedule a daily prompt reminder for a circle
    /// - Parameters:
    ///   - circleName: Name of the circle (for notification text)
    ///   - circleId: ID of the circle
    ///   - hour: Hour component (0-23)
    ///   - minute: Minute component (0-59)
    func schedulePromptReminder(circleName: String, circleId: UUID, hour: Int, minute: Int) async throws

    /// Schedule a nudge reminder if user hasn't responded
    /// - Parameters:
    ///   - circleName: Name of the circle
    ///   - circleId: ID of the circle
    ///   - delayHours: Hours after prompt to send nudge
    func scheduleNudge(circleName: String, circleId: UUID, delayHours: Int) async throws

    /// Cancel all notifications for a specific circle
    func cancelCircleNotifications(circleId: UUID) async

    /// Remove all pending notifications
    func removeAllPendingNotifications() async
}

/// Notification identifiers
public enum NotificationIdentifier {
    public static let promptPrefix = "circle-prompt-"
    public static let nudgePrefix = "circle-nudge-"

    public static func forPrompt(_ circleId: UUID) -> String {
        return "\(promptPrefix)\(circleId.uuidString)"
    }

    public static func forNudge(_ circleId: UUID) -> String {
        return "\(nudgePrefix)\(circleId.uuidString)"
    }
}

/// Notification category identifiers
public enum NotificationCategory {
    public static let dailyPrompt = "DAILY_PROMPT"
    public static let nudge = "NUDGE"
}

/// Notification action identifiers
public enum NotificationAction {
    public static let respond = "RESPOND"
    public static let listen = "LISTEN"
    public static let snooze = "SNOOZE"
}
