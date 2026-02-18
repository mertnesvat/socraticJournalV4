// LocalNotificationService.swift
// SocraticJournal
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

    // MARK: - Setup

    private func setupNotificationCategories() {
        let respondAction = UNNotificationAction(
            identifier: NotificationAction.respond,
            title: "Record Response",
            options: [.foreground]
        )

        let listenAction = UNNotificationAction(
            identifier: NotificationAction.listen,
            title: "Listen",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze,
            title: "Remind Later",
            options: []
        )

        let promptCategory = UNNotificationCategory(
            identifier: NotificationCategory.dailyPrompt,
            actions: [respondAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let nudgeCategory = UNNotificationCategory(
            identifier: NotificationCategory.nudge,
            actions: [respondAction, listenAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([promptCategory, nudgeCategory])
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

    // MARK: - Prompt Reminder

    public func schedulePromptReminder(circleName: String, circleId: UUID, hour: Int, minute: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        // Cancel existing prompt notification for this circle
        await cancelCircleNotifications(circleId: circleId)

        let content = UNMutableNotificationContent()
        content.title = "Today's Question is Ready"
        content.body = "Your circle \(circleName) has a new question. Record your answer!"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.dailyPrompt
        content.userInfo = ["circleId": circleId.uuidString]

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.forPrompt(circleId),
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    // MARK: - Nudge

    public func scheduleNudge(circleName: String, circleId: UUID, delayHours: Int) async throws {
        let status = await getPermissionStatus()
        guard status == .authorized || status == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your Circle is Waiting"
        content.body = "\(circleName) wants to hear from you today."
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.nudge
        content.userInfo = ["circleId": circleId.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(delayHours * 3600),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.forNudge(circleId),
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    // MARK: - Cancellation

    public func cancelCircleNotifications(circleId: UUID) async {
        let identifiers = [
            NotificationIdentifier.forPrompt(circleId),
            NotificationIdentifier.forNudge(circleId)
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    public func removeAllPendingNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
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
