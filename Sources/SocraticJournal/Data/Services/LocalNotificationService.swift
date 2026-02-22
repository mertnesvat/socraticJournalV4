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
        // New question actions
        let recordAnswerAction = UNNotificationAction(
            identifier: NotificationAction.recordAnswer,
            title: "Record Answer",
            options: [.foreground]
        )

        let newQuestionCategory = UNNotificationCategory(
            identifier: NotificationCategory.newQuestion,
            actions: [recordAnswerAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Friend answered actions
        let viewFriendAction = UNNotificationAction(
            identifier: NotificationAction.viewFriend,
            title: "Listen",
            options: [.foreground]
        )

        let friendAnsweredCategory = UNNotificationCategory(
            identifier: NotificationCategory.friendAnswered,
            actions: [viewFriendAction, recordAnswerAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Streak reminder actions
        let openAppAction = UNNotificationAction(
            identifier: NotificationAction.openApp,
            title: "Keep Streak",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze,
            title: "Remind Later",
            options: []
        )

        let streakReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.streakReminder,
            actions: [openAppAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // FOMO trigger actions
        let fomoCategory = UNNotificationCategory(
            identifier: NotificationCategory.fomoTrigger,
            actions: [recordAnswerAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Weekly award actions
        let awardCategory = UNNotificationCategory(
            identifier: NotificationCategory.weeklyAward,
            actions: [openAppAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([
            newQuestionCategory,
            friendAnsweredCategory,
            streakReminderCategory,
            fomoCategory,
            awardCategory
        ])
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

    // MARK: - Social Notifications

    public func scheduleNewQuestionNotification(hour: Int, minute: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Cancel any existing daily question reminder
        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "New Question Dropped"
        content.body = "What's your take today? Record your answer before your friends do."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.newQuestion

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.dailyQuestion,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func scheduleFriendAnsweredNotification(friendName: String, questionPreview: String) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(friendName) just recorded their take"
        content.body = "Record yours to hear it: \"\(questionPreview)\""
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.friendAnswered
        content.userInfo = ["friendName": friendName]

        // Trigger immediately (push-style, 1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let identifier = "\(NotificationIdentifier.friendAnswered)\(UUID().uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func scheduleStreakReminderNotification(streakDays: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You're on a \(streakDays)-day streak! Record today's take to keep it going."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.streakReminder

        // Schedule for 8 PM if they haven't answered yet
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.streakReminder,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func scheduleFOMONotification(friendCount: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your Friends Are Talking"
        content.body = "\(friendCount) friend\(friendCount == 1 ? "" : "s") answered today's question. You haven't yet."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.fomoTrigger

        // Trigger immediately (push-style, 1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.fomoTrigger,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func scheduleAwardNotification(awardTitle: String) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "Weekly Awards Are In"
        content.body = "This week's \(awardTitle) award goes to... tap to find out!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.weeklyAward

        // Trigger immediately (push-style, 1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.weeklyAward,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    // MARK: - Cancel & Manage

    public func cancelDailyReminder() async {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.dailyQuestion]
        )
        notificationCenter.removeDeliveredNotifications(
            withIdentifiers: [NotificationIdentifier.dailyQuestion]
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

        // Reschedule daily question reminder if enabled
        if settings.dailyReminderEnabled {
            do {
                try await scheduleNewQuestionNotification(
                    hour: settings.dailyReminderHour,
                    minute: settings.dailyReminderMinute
                )
            } catch {
                print("Failed to reschedule daily question reminder: \(error)")
            }
        }
    }

    // MARK: - Helpers

    /// Schedule a snooze reminder for 1 hour from now
    public func scheduleSnoozeReminder() async throws {
        let content = UNMutableNotificationContent()
        content.title = "New Question Waiting"
        content.body = "Ready to record your take? Your friends are waiting to hear it."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.newQuestion

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
