// JSONDataExportService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// JSON-based implementation of the data export service
public final class JSONDataExportService: DataExportServiceProtocol, @unchecked Sendable {
    private let journalRepository: JournalRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    public init(
        journalRepository: JournalRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        fileManager: FileManager = .default
    ) {
        self.journalRepository = journalRepository
        self.settingsRepository = settingsRepository
        self.fileManager = fileManager

        self.encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
    }

    public func createExportData() async throws -> JournalExport {
        let sessions = try await journalRepository.getAllSessions()
        let letters = try await journalRepository.getAllLetters()
        let settings = try await settingsRepository.getSettings()

        return JournalExport(
            exportedAt: Date(),
            version: SocraticJournal.version,
            sessions: sessions,
            letters: letters,
            settings: settings
        )
    }

    public func exportAllData() async throws -> URL {
        // Create export data
        let exportData = try await createExportData()

        // Encode to JSON
        let jsonData: Data
        do {
            jsonData = try encoder.encode(exportData)
        } catch {
            throw DataExportError.failedToEncodeData(error)
        }

        // Create file URL with timestamp
        let filename = "socratic_journal_export_\(formatTimestamp(Date())).json"
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documentsURL.appendingPathComponent(filename)

        // Write to file
        do {
            try jsonData.write(to: exportURL, options: .atomic)
        } catch {
            throw DataExportError.failedToWriteFile(error)
        }

        return exportURL
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: date)
    }
}
