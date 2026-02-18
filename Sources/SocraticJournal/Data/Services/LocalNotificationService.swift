// LocalNotificationService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UserNotifications

/// Local notification service using UNUserNotificationCenter
/// Replace with FirebaseCloudMessagingService later for remote push
public final class LocalNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let center = UNUserNotificationCenter.current()

    private static let dailyReminderIdentifier = "circle.daily.reminder"

    public init() {}

    public func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    public func getPermissionStatus() async -> NotificationPermissionStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .authorized
        @unknown default: return .notDetermined
        }
    }

    public func scheduleDailyReminder(hour: Int, minute: Int, circleName: String) async throws {
        // Remove existing daily reminder first
        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Today's question is ready"
        content.body = "Your circle \"\(circleName)\" has a new prompt waiting for your voice."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    public func cancelDailyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderIdentifier])
    }

    public func removeAllPendingNotifications() async {
        center.removeAllPendingNotificationRequests()
    }
}
#endif
