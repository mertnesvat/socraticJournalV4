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

    private let settingsRepository: SettingsRepositoryProtocol
    private let journalRepository: JournalRepositoryProtocol

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

    public func exportJournalData() async -> URL? {
        do {
            let sessions = try await journalRepository.getAllSessions()
            let letters = try await journalRepository.getAllLetters()

            let exportData = JournalExportData(
                exportDate: Date(),
                sessions: sessions,
                letters: letters
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(exportData)

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("socratic_journal_export_\(exportTimestamp).json")

            try data.write(to: tempURL)
            return tempURL
        } catch {
            self.error = error
            return nil
        }
    }

    private var exportTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}

/// Data structure for journal export
struct JournalExportData: Codable {
    let exportDate: Date
    let sessions: [JournalSession]
    let letters: [FutureLetter]
}
#endif
