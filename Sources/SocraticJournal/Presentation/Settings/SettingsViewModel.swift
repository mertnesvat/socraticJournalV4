// SettingsViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

@Observable
@MainActor
public final class SettingsViewModel {
    private(set) var settings: UserSettings = .default
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    var themeMode: ThemeMode {
        get { settings.themeMode }
        set {
            settings.themeMode = newValue
            Task { await saveSettings() }
        }
    }

    var dailyGoalMinutes: Int {
        get { settings.dailyGoalMinutes }
        set {
            settings.dailyGoalMinutes = newValue
            Task { await saveSettings() }
        }
    }

    var breathReminderEnabled: Bool {
        get { settings.breathReminderEnabled }
        set {
            settings.breathReminderEnabled = newValue
            Task { await saveSettings() }
        }
    }

    var hapticFeedbackEnabled: Bool {
        get { settings.hapticFeedbackEnabled }
        set {
            settings.hapticFeedbackEnabled = newValue
            Task { await saveSettings() }
        }
    }

    var reminderTime: Date {
        get { settings.reminderTime }
        set {
            settings.setReminderTime(from: newValue)
            Task { await saveSettings() }
        }
    }

    public let settingsRepository: SettingsRepositoryProtocol

    public init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    public func loadSettings() async {
        isLoading = true
        do {
            settings = try await settingsRepository.getSettings()
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

    public func resetOnboarding() async {
        settings.hasCompletedOnboarding = false
        await saveSettings()
    }
}
#endif
