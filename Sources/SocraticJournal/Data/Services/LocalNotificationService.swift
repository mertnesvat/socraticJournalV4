// LocalNotificationService.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UserNotifications
import UIKit

public final class LocalNotificationService: @unchecked Sendable {
    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    public func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    public func scheduleBreathReminder(hour: Int, minute: Int) async throws {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["breathe.daily"])

        let content = UNMutableNotificationContent()
        content.title = "Time to Breathe"
        content.body = "Take a few minutes for your breath practice today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "breathe.daily", content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }

    public func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["breathe.daily"])
    }
}
#endif
