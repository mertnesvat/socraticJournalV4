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
    private(set) var showClearDataSuccess: Bool = false
    private(set) var notificationPermissionStatus: NotificationPermissionStatus = .notDetermined
    var showClearDataConfirmation: Bool = false
    var showPermissionDeniedAlert: Bool = false

    // MARK: - Computed Properties

    var themeMode: ThemeMode {
        get { settings.themeMode }
        set {
            settings.themeMode = newValue
            Task { await saveSettings() }
        }
    }

    var letterRemindersEnabled: Bool {
        get { settings.letterRemindersEnabled }
        set {
            let newValue = newValue
            settings.letterRemindersEnabled = newValue
            Task {
                await saveSettings()
                await handleLetterRemindersChange(enabled: newValue)
            }
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
    public let journalRepository: JournalRepositoryProtocol
    public let notificationService: NotificationServiceProtocol?

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        journalRepository: JournalRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.journalRepository = journalRepository
        self.notificationService = notificationService
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

    /// Handle letter reminders toggle change
    private func handleLetterRemindersChange(enabled: Bool) async {
        guard let service = notificationService else { return }

        if enabled {
            // Request permission if needed
            if notificationPermissionStatus == .notDetermined {
                let granted = await requestNotificationPermission()
                if !granted {
                    // Revert the toggle if permission denied
                    settings.letterRemindersEnabled = false
                    await saveSettings()
                    return
                }
            } else if notificationPermissionStatus == .denied {
                showPermissionDeniedAlert = true
                settings.letterRemindersEnabled = false
                await saveSettings()
                return
            }

            // Schedule notifications for all sealed letters
            do {
                let letters = try await journalRepository.getAllLetters()
                for letter in letters where letter.status == .sealed && letter.deliveryDate > Date() {
                    try await service.scheduleLetterUnlock(letter: letter)
                }
            } catch {
                self.error = error
            }
        } else {
            // Cancel all letter notifications
            do {
                let letters = try await journalRepository.getAllLetters()
                for letter in letters {
                    await service.cancelLetterNotification(letterId: letter.id)
                }
            } catch {
                self.error = error
            }
        }
    }

    /// Handle daily reminder toggle change
    private func handleDailyReminderChange(enabled: Bool) async {
        guard let service = notificationService else { return }

        if enabled {
            // Request permission if needed
            if notificationPermissionStatus == .notDetermined {
                let granted = await requestNotificationPermission()
                if !granted {
                    // Revert the toggle if permission denied
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
            try await service.scheduleDailyReminder(
                hour: settings.dailyReminderHour,
                minute: settings.dailyReminderMinute
            )
        } catch {
            self.error = error
        }
    }

    public func confirmClearData() {
        showClearDataConfirmation = true
    }

    public func clearAllData() async {
        do {
            // Cancel all notifications before clearing data
            if let service = notificationService {
                await service.removeAllPendingNotifications()
            }

            try await settingsRepository.clearAllData()
            settings = .default
            showClearDataSuccess = true

            // Auto-hide success message
            try? await Task.sleep(for: .seconds(2))
            showClearDataSuccess = false
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
}
#endif
