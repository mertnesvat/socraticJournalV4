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

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        setupNotificationCategories()
    }

    // MARK: - Setup

    private func setupNotificationCategories() {
        // Letter ready actions
        let openLetterAction = UNNotificationAction(
            identifier: NotificationAction.openLetter,
            title: "Read Letter",
            options: [.foreground]
        )

        let letterReadyCategory = UNNotificationCategory(
            identifier: NotificationCategory.letterReady,
            actions: [openLetterAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Daily reminder actions
        let startSessionAction = UNNotificationAction(
            identifier: NotificationAction.startSession,
            title: "Start Journaling",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze,
            title: "Remind in 1 Hour",
            options: []
        )

        let dailyReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.dailyReminder,
            actions: [startSessionAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([letterReadyCategory, dailyReminderCategory])
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

    // MARK: - Letter Notifications

    public func scheduleLetterUnlock(letter: FutureLetter) async throws {
        // Only schedule for sealed letters with future delivery dates
        guard letter.status == .sealed else { return }
        guard letter.deliveryDate > Date() else { return }

        // Check permission first
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "A Letter from Your Past Self"
        content.body = "Your letter is ready to be opened. Take a moment to read what past you had to say."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.letterReady
        content.userInfo = ["letterId": letter.id]

        // Create trigger for the delivery date
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: letter.deliveryDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.forLetter(letter.id),
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func cancelLetterNotification(letterId: String) async {
        let identifier = NotificationIdentifier.forLetter(letterId)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    // MARK: - Daily Reminder

    public func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        // Check permission first
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Cancel any existing daily reminder
        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time for Reflection"
        content.body = "Take a few minutes to journal with Socrates and explore your thoughts."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.dailyReminder

        // Create repeating daily trigger
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

    // MARK: - Reschedule

    public func rescheduleAllNotifications(letters: [FutureLetter], settings: UserSettings) async {
        // Check permission first
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Reschedule letter notifications for sealed letters with letter reminders enabled
        if settings.letterRemindersEnabled {
            for letter in letters where letter.status == .sealed && letter.deliveryDate > Date() {
                do {
                    try await scheduleLetterUnlock(letter: letter)
                } catch {
                    print("Failed to reschedule letter notification for \(letter.id): \(error)")
                }
            }
        }

        // Reschedule daily reminder if enabled
        if settings.dailyReminderEnabled {
            do {
                try await scheduleDailyReminder(
                    hour: settings.dailyReminderHour,
                    minute: settings.dailyReminderMinute
                )
            } catch {
                print("Failed to reschedule daily reminder: \(error)")
            }
        }
    }

    public func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Helpers

    /// Schedule a snooze reminder for 1 hour from now
    public func scheduleSnoozeReminder() async throws {
        let content = UNMutableNotificationContent()
        content.title = "Time for Reflection"
        content.body = "Ready to journal now? Socrates is waiting."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.dailyReminder

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        let request = UNNotificationRequest(
            identifier: "snooze-reminder",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    /// Clear the badge count
    public func clearBadge() async {
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
#endif
