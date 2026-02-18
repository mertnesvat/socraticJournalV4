// CircleNotificationScheduler.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UIKit

/// Coordinates notification scheduling for circles using the existing LocalNotificationService.
/// Handles per-circle mute state via UserDefaults and badge count management.
public final class CircleNotificationScheduler: @unchecked Sendable {
    private let notificationService: NotificationServiceProtocol
    private let defaults: UserDefaults

    /// Number of hours after prompt time to send the nudge
    private let nudgeDelayHours = 3

    public init(
        notificationService: NotificationServiceProtocol = LocalNotificationService(),
        defaults: UserDefaults = .standard
    ) {
        self.notificationService = notificationService
        self.defaults = defaults
    }

    // MARK: - Mute Management

    /// Returns true if the circle has been muted by the user
    public func isCircleMuted(_ circleId: UUID) -> Bool {
        defaults.bool(forKey: muteKey(for: circleId))
    }

    /// Toggle mute state for a circle. Returns the new mute state.
    @discardableResult
    public func toggleMute(circleId: UUID) -> Bool {
        let key = muteKey(for: circleId)
        let newValue = !defaults.bool(forKey: key)
        defaults.set(newValue, forKey: key)
        return newValue
    }

    /// Set the mute state for a circle explicitly
    public func setMuted(_ muted: Bool, circleId: UUID) {
        defaults.set(muted, forKey: muteKey(for: circleId))
    }

    private func muteKey(for circleId: UUID) -> String {
        "circle_muted_\(circleId.uuidString)"
    }

    // MARK: - Scheduling

    /// Schedule a daily recurring prompt reminder for a circle at its configured prompt time.
    /// Respects per-circle mute state -- does nothing if the circle is muted.
    public func scheduleForCircle(_ circle: CircleGroup) async {
        guard !isCircleMuted(circle.id) else { return }

        do {
            try await notificationService.schedulePromptReminder(
                circleName: "\(circle.emoji) \(circle.name)",
                circleId: circle.id,
                hour: circle.promptHour,
                minute: circle.promptMinute
            )
        } catch {
            print("[CircleNotificationScheduler] Failed to schedule prompt for \(circle.name): \(error)")
        }
    }

    /// Schedule a one-time nudge notification 3 hours after the circle's prompt time.
    /// Respects per-circle mute state -- does nothing if the circle is muted.
    public func scheduleNudge(for circle: CircleGroup) async {
        guard !isCircleMuted(circle.id) else { return }

        do {
            try await notificationService.scheduleNudge(
                circleName: "\(circle.emoji) \(circle.name)",
                circleId: circle.id,
                delayHours: nudgeDelayHours
            )
        } catch {
            print("[CircleNotificationScheduler] Failed to schedule nudge for \(circle.name): \(error)")
        }
    }

    /// Cancel all pending and delivered notifications for a specific circle.
    public func cancelForCircle(circleId: UUID) async {
        await notificationService.cancelCircleNotifications(circleId: circleId)
    }

    /// Cancel all existing notifications and re-schedule for every provided circle.
    /// Useful after settings changes or app launch.
    public func rescheduleAll(circles: [CircleGroup]) async {
        await notificationService.removeAllPendingNotifications()

        for circle in circles {
            await scheduleForCircle(circle)
        }
    }

    // MARK: - Badge

    /// Update the app badge to reflect the number of unresponded prompts.
    @MainActor
    public func updateBadgeCount(unrespondedCount: Int) {
        UIApplication.shared.applicationIconBadgeNumber = unrespondedCount
    }
}
#endif
