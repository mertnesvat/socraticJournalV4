// LocalNotificationService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UserNotifications
import UIKit

public final class LocalNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        setupNotificationCategories()
    }

    private func setupNotificationCategories() {
        let startAction = UNNotificationAction(
            identifier: NotificationAction.startSession,
            title: "Start Session",
            options: [.foreground]
        )
        let breathCategory = UNNotificationCategory(
            identifier: NotificationCategory.breathReminder,
            actions: [startAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        notificationCenter.setNotificationCategories([breathCategory])
    }

    public func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
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

    public func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }
        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to Breathe"
        content.body = "Take a few minutes for your breath practice today."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.breathReminder

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.dailyReminder,
            content: content,
            trigger: trigger
        )
        try await notificationCenter.add(request)
    }

    public func cancelDailyReminder() async {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.dailyReminder]
        )
        notificationCenter.removeDeliveredNotifications(
            withIdentifiers: [NotificationIdentifier.dailyReminder]
        )
    }

    public func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    public func rescheduleAllNotifications(settings: UserSettings) async {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }
        if settings.breathReminderEnabled {
            try? await scheduleDailyReminder(
                hour: settings.breathReminderHour,
                minute: settings.breathReminderMinute
            )
        }
    }
}
#endif
