// SettingsViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Settings screen
@Observable
@MainActor
public final class SettingsViewModel {
    // MARK: - State

    private(set) var settings: UserSettings = .default
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var notificationPermissionStatus: NotificationPermissionStatus = .notDetermined
    var showPermissionDeniedAlert: Bool = false

    // MARK: - Computed Properties

    var themeMode: ThemeMode {
        get { settings.themeMode }
        set {
            settings.themeMode = newValue
            Task { await saveSettings() }
        }
    }

    var dailyReminderEnabled: Bool {
        get { settings.dailyReminderEnabled }
        set {
            let newValue = newValue
            settings.dailyReminderEnabled = newValue
            Task {
                await saveSettings()
                await handleDailyReminderChange(enabled: newValue)
            }
        }
    }

    var reminderTime: Date {
        get { settings.reminderTime }
        set {
            settings.setReminderTime(from: newValue)
            Task {
                await saveSettings()
                if settings.dailyReminderEnabled {
                    await updateDailyReminder()
                }
            }
        }
    }

    var weeklyGoalMinutes: Int {
        get { settings.weeklyGoalMinutes }
        set {
            settings.weeklyGoalMinutes = newValue
            Task { await saveSettings() }
        }
    }

    /// Whether notifications need permission request
    var needsNotificationPermission: Bool {
        notificationPermissionStatus == .notDetermined
    }

    /// Whether notifications are denied by the system
    var notificationsDenied: Bool {
        notificationPermissionStatus == .denied
    }

    // MARK: - Dependencies

    public let settingsRepository: SettingsRepositoryProtocol
    public let notificationService: NotificationServiceProtocol?
    public let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    public func loadSettings() async {
        isLoading = true
        error = nil

        do {
            settings = try await settingsRepository.getSettings()
            // Check notification permission status
            if let service = notificationService {
                notificationPermissionStatus = await service.getPermissionStatus()
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func saveSettings() async {
        do {
            try await settingsRepository.saveSettings(settings)
        } catch {
            self.error = error
        }
    }

    /// Request notification permission if not yet determined
    public func requestNotificationPermission() async -> Bool {
        guard let service = notificationService else { return false }

        let granted = await service.requestPermission()
        notificationPermissionStatus = await service.getPermissionStatus()
        return granted
    }

    /// Handle daily reminder toggle change
    private func handleDailyReminderChange(enabled: Bool) async {
        guard let service = notificationService else { return }

        if enabled {
            // Request permission if needed
            if notificationPermissionStatus == .notDetermined {
                let granted = await requestNotificationPermission()
                if !granted {
                    settings.dailyReminderEnabled = false
                    await saveSettings()
                    return
                }
            } else if notificationPermissionStatus == .denied {
                showPermissionDeniedAlert = true
                settings.dailyReminderEnabled = false
                await saveSettings()
                return
            }

            await updateDailyReminder()
        } else {
            await service.cancelDailyReminder()
        }
    }

    /// Update daily reminder with current time settings
    private func updateDailyReminder() async {
        guard let service = notificationService else { return }

        do {
            try await service.scheduleBreathReminder(
                hour: settings.dailyReminderHour,
                minute: settings.dailyReminderMinute
            )
        } catch {
            self.error = error
        }
    }

    /// Open system settings to enable notifications
    public func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Reset onboarding flag so user can replay the onboarding flow
    public func resetOnboarding() async {
        settings.hasCompletedOnboarding = false
        await saveSettings()
    }
}
#endif
