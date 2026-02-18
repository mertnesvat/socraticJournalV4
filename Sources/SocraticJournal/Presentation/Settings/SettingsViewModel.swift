// SettingsViewModel.swift
// Circle
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

    // MARK: - Subscription State

    private(set) var subscriptionStatus: SubscriptionStatus = .free
    private(set) var isRestoringPurchases: Bool = false
    private(set) var restoreError: SubscriptionError?

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

    var notificationsDenied: Bool {
        notificationPermissionStatus == .denied
    }

    var formattedSubscriptionExpiry: String? {
        settings.formattedSubscriptionExpiry
    }

    // MARK: - Dependencies

    public let settingsRepository: SettingsRepositoryProtocol
    public let notificationService: NotificationServiceProtocol?
    public let subscriptionService: SubscriptionServiceProtocol?
    public let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.subscriptionService = subscriptionService
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
            if let subscriptionService = subscriptionService {
                subscriptionStatus = await subscriptionService.currentStatus()
                settings.updateSubscription(from: subscriptionStatus)
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

    // MARK: - Subscription

    public func restorePurchases() async {
        guard let service = subscriptionService else { return }
        guard !isRestoringPurchases else { return }

        isRestoringPurchases = true
        restoreError = nil

        do {
            let status = try await service.restorePurchases()
            subscriptionStatus = status
            settings.updateSubscription(from: status)
            await saveSettings()
            if status.isPremium {
                analyticsService?.logEvent(.subscriptionRestored, parameters: nil)
            }
        } catch let error as SubscriptionError {
            restoreError = error
        } catch {
            restoreError = .unknown(error.localizedDescription)
        }

        isRestoringPurchases = false
    }

    public func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}
#endif
