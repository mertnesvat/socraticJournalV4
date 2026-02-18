// CircleNotificationSettingsViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for per-circle notification settings.
/// Manages loading circles, toggling notifications, and scheduling per-circle reminders.
@Observable
@MainActor
public final class CircleNotificationSettingsViewModel {
    // MARK: - State

    private(set) var circles: [Circle] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var permissionStatus: NotificationPermissionStatus = .notDetermined
    var showPermissionDeniedAlert = false

    /// Current per-circle notification settings, kept in sync with UserSettings.
    var circleSettings: [UUID: CircleNotificationSetting] = [:]

    var permissionDenied: Bool {
        permissionStatus == .denied
    }

    // MARK: - Dependencies

    private let circleService: CircleServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    // MARK: - Init

    public init(
        circleService: CircleServiceProtocol,
        notificationService: NotificationServiceProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.circleService = circleService
        self.notificationService = notificationService
        self.settingsRepository = settingsRepository
    }

    // MARK: - Actions

    /// Load circles and their notification settings.
    func loadData() async {
        isLoading = true
        error = nil
        do {
            circles = try await circleService.getCircles()
            let settings = try await settingsRepository.getSettings()
            permissionStatus = await notificationService.getPermissionStatus()

            // Build settings dictionary from persisted settings
            circleSettings = [:]
            for circle in circles {
                let setting = settings.circleNotificationSetting(for: circle.id)
                circleSettings[circle.id] = setting
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }

    /// Toggle notifications for a specific circle.
    func toggleNotification(for circleId: UUID, enabled: Bool) async {
        guard var setting = circleSettings[circleId] else { return }

        if enabled {
            // Check permission first
            if permissionStatus == .notDetermined {
                let granted = await notificationService.requestPermission()
                permissionStatus = await notificationService.getPermissionStatus()
                if !granted {
                    return
                }
            } else if permissionStatus == .denied {
                showPermissionDeniedAlert = true
                return
            }
        }

        setting.isEnabled = enabled
        circleSettings[circleId] = setting
        await persistSetting(setting)

        if enabled {
            await scheduleNotification(for: circleId)
        } else {
            await notificationService.cancelCircleNotifications(for: circleId)
        }
    }

    /// Update the notification time for a specific circle.
    func updateTime(for circleId: UUID, time: Date) async {
        guard var setting = circleSettings[circleId] else { return }
        setting.setTime(from: time)
        circleSettings[circleId] = setting
        await persistSetting(setting)

        if setting.isEnabled {
            await scheduleNotification(for: circleId)
        }
    }

    /// Schedule the notification for a specific circle using stored settings.
    private func scheduleNotification(for circleId: UUID) async {
        guard let setting = circleSettings[circleId],
              let circle = circles.first(where: { $0.id == circleId }) else { return }

        do {
            try await notificationService.scheduleCirclePrompt(
                circleId: circleId,
                circleName: circle.name,
                circleIcon: circle.emojiIcon,
                hour: setting.hour,
                minute: setting.minute,
                promptSnippet: "What's on your mind today?"
            )
        } catch {
            self.error = error
        }
    }

    /// Persist the updated setting to the settings repository.
    private func persistSetting(_ setting: CircleNotificationSetting) async {
        do {
            var settings = try await settingsRepository.getSettings()
            settings.setCircleNotificationSetting(setting)
            try await settingsRepository.saveSettings(settings)
        } catch {
            self.error = error
        }
    }

    /// Open system notification settings.
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Re-schedule all enabled circle notifications (e.g., after app launch or settings change).
    func rescheduleAllCircleNotifications() async {
        for circle in circles {
            guard let setting = circleSettings[circle.id], setting.isEnabled else { continue }
            await scheduleNotification(for: circle.id)
        }
    }
}
#endif
