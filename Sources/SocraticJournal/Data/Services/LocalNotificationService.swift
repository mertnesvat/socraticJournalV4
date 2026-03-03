// LocalNotificationService.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UserNotifications
import UIKit

/// Notification permission status
public enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}

/// Local notification service for daily breath reminders
public final class LocalNotificationService: @unchecked Sendable {
    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    // MARK: - Permission

    public func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            return false
        }
    }

    public func getPermissionStatus() async -> NotificationPermissionStatus {
        let settings = await notificationCenter.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .authorized
        @unknown default: return .notDetermined
        }
    }

    // MARK: - Daily Reminder

    public func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to Breathe"
        content.body = "Your daily breathing practice is waiting."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-breath-reminder",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func cancelDailyReminder() async {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["daily-breath-reminder"]
        )
        notificationCenter.removeDeliveredNotifications(
            withIdentifiers: ["daily-breath-reminder"]
        )
    }

    public func clearBadge() async {
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
#endif
