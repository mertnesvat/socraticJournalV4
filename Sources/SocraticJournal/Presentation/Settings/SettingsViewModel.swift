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
    var showClearDataConfirmation: Bool = false

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
            settings.letterRemindersEnabled = newValue
            Task { await saveSettings() }
        }
    }

    var dailyReminderEnabled: Bool {
        get { settings.dailyReminderEnabled }
        set {
            settings.dailyReminderEnabled = newValue
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

    // MARK: - Dependencies

    public let settingsRepository: SettingsRepositoryProtocol
    public let journalRepository: JournalRepositoryProtocol

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        journalRepository: JournalRepositoryProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.journalRepository = journalRepository
    }

    // MARK: - Actions

    public func loadSettings() async {
        isLoading = true
        error = nil

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

    public func confirmClearData() {
        showClearDataConfirmation = true
    }

    public func clearAllData() async {
        do {
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

}
#endif
