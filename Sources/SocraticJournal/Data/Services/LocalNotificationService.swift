// LocalNotificationService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UserNotifications
import UIKit

/// Local notification service implementation using UNUserNotificationCenter
public final class LocalNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let notificationCenter: UNUserNotificationCenter

    /// Rotating notification body messages
    private static let reminderMessages = [
        "5 minutes for your lungs, heart, and mind.",
        "Your daily breath practice is waiting.",
        "Inhale calm. Exhale tension."
    ]

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        setupNotificationCategories()
    }

    // MARK: - Setup

    private func setupNotificationCategories() {
        let startSessionAction = UNNotificationAction(
            identifier: NotificationAction.startSession,
            title: "Start",
            options: [.foreground]
        )

        let breathReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.breathReminder,
            actions: [startSessionAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([breathReminderCategory])
    }

    // MARK: - Permission

    public func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }

    public func getPermissionStatus() async -> NotificationPermissionStatus {
        let settings = await notificationCenter.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    // MARK: - Breath Reminder

    public func scheduleBreathReminder(hour: Int, minute: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Cancel any existing daily reminder
        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time to breathe"
        content.body = Self.reminderMessages.randomElement() ?? Self.reminderMessages[0]
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.breathReminder

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.dailyBreathReminder,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    // MARK: - Cancel & Manage

    public func cancelDailyReminder() async {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.dailyBreathReminder]
        )
        notificationCenter.removeDeliveredNotifications(
            withIdentifiers: [NotificationIdentifier.dailyBreathReminder]
        )
    }

    public func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Reschedule

    public func rescheduleAllNotifications(settings: UserSettings) async {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Reschedule daily breath reminder if enabled
        if settings.dailyReminderEnabled {
            do {
                try await scheduleBreathReminder(
                    hour: settings.dailyReminderHour,
                    minute: settings.dailyReminderMinute
                )
            } catch {
                print("Failed to reschedule daily breath reminder: \(error)")
            }
        }
    }

    // MARK: - Helpers

    /// Clear the badge count
    public func clearBadge() async {
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
#endif
