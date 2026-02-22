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

    // MARK: - Subscription State

    private(set) var subscriptionStatus: SubscriptionStatus = .free
    private(set) var isRestoringPurchases: Bool = false
    private(set) var restoreError: SubscriptionError?
    var showRestoreSuccessMessage: Bool = false
    var showRestoreNoSubscriptionMessage: Bool = false

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

    /// Whether notifications need permission request
    var needsNotificationPermission: Bool {
        notificationPermissionStatus == .notDetermined
    }

    /// Whether notifications are denied by the system
    var notificationsDenied: Bool {
        notificationPermissionStatus == .denied
    }

    /// Formatted subscription expiry date for display
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
            // Check notification permission status
            if let service = notificationService {
                notificationPermissionStatus = await service.getPermissionStatus()
            }
            // Load subscription status
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
            try await service.scheduleDailyReminder(
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

    // MARK: - Subscription Actions

    /// Restore previous purchases
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
                showRestoreSuccessMessage = true
                analyticsService?.logEvent(.subscriptionRestored, parameters: nil)
                try? await Task.sleep(for: .seconds(2))
                showRestoreSuccessMessage = false
            } else {
                showRestoreNoSubscriptionMessage = true
                try? await Task.sleep(for: .seconds(2))
                showRestoreNoSubscriptionMessage = false
            }
        } catch let error as SubscriptionError {
            restoreError = error
        } catch {
            restoreError = .unknown(error.localizedDescription)
        }

        isRestoringPurchases = false
    }

    /// Open App Store subscription management
    public func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }

    /// Refresh subscription status from the service
    public func refreshSubscriptionStatus() async {
        guard let service = subscriptionService else { return }

        subscriptionStatus = await service.currentStatus()
        settings.updateSubscription(from: subscriptionStatus)
        await saveSettings()
    }
}
#endif
