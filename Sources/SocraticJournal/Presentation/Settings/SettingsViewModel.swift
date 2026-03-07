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
    private(set) var hasSampleData: Bool = false
    private(set) var isSampleDataLoading: Bool = false

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

    var dailyGoalMinutes: Int {
        get { settings.dailyGoalMinutes }
        set {
            settings.dailyGoalMinutes = newValue
            Task { await saveSettings() }
        }
    }

    var hapticRhythmEnabled: Bool {
        get { settings.hapticRhythmEnabled }
        set {
            settings.hapticRhythmEnabled = newValue
            Task { await saveSettings() }
        }
    }

    var notificationsDenied: Bool {
        notificationPermissionStatus == .denied
    }

    var healthKitEnabled: Bool {
        get { settings.healthKitEnabled }
        set {
            settings.healthKitEnabled = newValue
            Task { await saveSettings() }
        }
    }

    var saveMindfulMinutes: Bool {
        get { settings.saveMindfulMinutes }
        set {
            settings.saveMindfulMinutes = newValue
            Task { await saveSettings() }
        }
    }

    var showHRVInsights: Bool {
        get { settings.showHRVInsights }
        set {
            settings.showHRVInsights = newValue
            Task { await saveSettings() }
        }
    }

    // MARK: - Dependencies

    public let settingsRepository: SettingsRepositoryProtocol
    public let sessionRepository: BreathSessionRepositoryProtocol?
    public let notificationService: NotificationServiceProtocol?
    public let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        sessionRepository: BreathSessionRepositoryProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.sessionRepository = sessionRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    public func loadSettings() async {
        isLoading = true
        error = nil

        do {
            settings = try await settingsRepository.getSettings()
            if let service = notificationService {
                notificationPermissionStatus = await service.getPermissionStatus()
            }
            await checkSampleData()
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

    private func handleDailyReminderChange(enabled: Bool) async {
        guard let service = notificationService else { return }

        if enabled {
            if notificationPermissionStatus == .notDetermined {
                let granted = await service.requestPermission()
                notificationPermissionStatus = await service.getPermissionStatus()
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

    public func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    public func resetOnboarding() async {
        settings.hasCompletedOnboarding = false
        await saveSettings()
    }

    // MARK: - Sample Data

    public func addSampleData() async {
        guard let repo = sessionRepository else { return }
        isSampleDataLoading = true
        do {
            try await repo.addSampleData()
            hasSampleData = true
        } catch {
            self.error = error
        }
        isSampleDataLoading = false
    }

    public func removeSampleData() async {
        guard let repo = sessionRepository else { return }
        isSampleDataLoading = true
        do {
            try await repo.removeSampleData()
            hasSampleData = false
        } catch {
            self.error = error
        }
        isSampleDataLoading = false
    }

    private func checkSampleData() async {
        guard let repo = sessionRepository else { return }
        hasSampleData = (try? await repo.hasSampleData()) ?? false
    }
}

#endif
