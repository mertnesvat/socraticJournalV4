// DataExportServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Errors that can occur during data export
public enum DataExportError: Error, LocalizedError, Sendable {
    case failedToCreateExportData
    case failedToEncodeData(Error)
    case failedToWriteFile(Error)
    case failedToCreateDirectory(Error)

    public var errorDescription: String? {
        switch self {
        case .failedToCreateExportData:
            return "Failed to gather data for export"
        case .failedToEncodeData(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .failedToWriteFile(let error):
            return "Failed to write export file: \(error.localizedDescription)"
        case .failedToCreateDirectory(let error):
            return "Failed to create export directory: \(error.localizedDescription)"
        }
    }
}

/// Protocol defining data export operations
public protocol DataExportServiceProtocol: Sendable {
    /// Creates the export data structure with all journal data
    /// - Returns: JournalExport containing all sessions, letters, and settings
    func createExportData() async throws -> JournalExport

    /// Exports all journal data to a JSON file
    /// - Returns: URL of the created export file
    func exportAllData() async throws -> URL
}
