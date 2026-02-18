// LocalNotificationService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UserNotifications
import UIKit

/// Local notification service using UNUserNotificationCenter
public final class LocalNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        setupNotificationCategories()
    }

    private func setupNotificationCategories() {
        let recordAction = UNNotificationAction(
            identifier: NotificationAction.recordResponse,
            title: "Record Response",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze,
            title: "Remind in 1 Hour",
            options: []
        )

        let dailyPromptCategory = UNNotificationCategory(
            identifier: NotificationCategory.dailyPrompt,
            actions: [recordAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let circlePromptCategory = UNNotificationCategory(
            identifier: NotificationCategory.circlePrompt,
            actions: [recordAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([dailyPromptCategory, circlePromptCategory])
    }

    // MARK: - Permission

    public func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request notification permission: \(error)")
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

    // MARK: - Daily Prompt Reminder (Global)

    public func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        await cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Your Circle is Waiting"
        content.body = "Today's question is ready. Record your voice and hear from your people."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.dailyPrompt

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.dailyPrompt,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func cancelDailyReminder() async {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.dailyPrompt]
        )
        notificationCenter.removeDeliveredNotifications(
            withIdentifiers: [NotificationIdentifier.dailyPrompt]
        )
    }

    public func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Circle-Specific Notifications

    public func scheduleCirclePrompt(
        circleId: UUID,
        circleName: String,
        circleIcon: String,
        hour: Int,
        minute: Int,
        promptSnippet: String
    ) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Cancel any existing notification for this circle first
        await cancelCircleNotifications(for: circleId)

        let content = UNMutableNotificationContent()
        content.title = "\(circleName)"
        // Truncate prompt to first 50 characters
        let truncatedPrompt = promptSnippet.count > 50
            ? String(promptSnippet.prefix(50)) + "..."
            : promptSnippet
        content.body = "Today's Circle question: \(truncatedPrompt)"
        content.subtitle = circleName
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.circlePrompt

        // Store circle ID in userInfo for deep-link handling
        content.userInfo = [
            "circleId": circleId.uuidString,
            "circleName": circleName,
            "circleIcon": circleIcon
        ]

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = NotificationIdentifier.circlePrompt(for: circleId)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    public func cancelCircleNotifications(for circleId: UUID) async {
        let identifier = NotificationIdentifier.circlePrompt(for: circleId)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    // MARK: - Badge Management

    public func setBadgeCount(_ count: Int) async {
        if #available(iOS 16.0, *) {
            try? await notificationCenter.setBadgeCount(count)
        } else {
            await MainActor.run {
                UIApplication.shared.applicationIconBadgeNumber = count
            }
        }
    }

    public func clearBadge() async {
        await setBadgeCount(0)
    }
}
#endif
