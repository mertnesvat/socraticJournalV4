// ExportViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// State representing the export operation status
public enum ExportState: Equatable {
    case idle
    case loading
    case success(URL)
    case failure(String)
}

/// ViewModel for the export functionality
@Observable
@MainActor
public final class ExportViewModel {
    // MARK: - State

    private(set) var state: ExportState = .idle
    private(set) var exportData: JournalExport?
    private(set) var isLoadingPreview: Bool = false

    /// Whether export was successful and URL is available
    var exportURL: URL? {
        if case .success(let url) = state {
            return url
        }
        return nil
    }

    /// Whether there is an error message to display
    var errorMessage: String? {
        if case .failure(let message) = state {
            return message
        }
        return nil
    }

    /// Whether the export operation is in progress
    var isExporting: Bool {
        state == .loading
    }

    /// Whether the share sheet should be shown
    var showShareSheet: Bool {
        exportURL != nil
    }

    // MARK: - Dependencies

    private let exportService: DataExportServiceProtocol

    // MARK: - Init

    public init(exportService: DataExportServiceProtocol) {
        self.exportService = exportService
    }

    // MARK: - Actions

    /// Load preview data without exporting to file
    public func loadPreview() async {
        isLoadingPreview = true
        do {
            exportData = try await exportService.createExportData()
        } catch {
            // Preview loading failures are non-critical
            exportData = nil
        }
        isLoadingPreview = false
    }

    /// Export all journal data to a file
    public func exportData() async {
        state = .loading

        do {
            let url = try await exportService.exportAllData()
            state = .success(url)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .failure(message)
        }
    }

    /// Reset state after sharing or dismissing
    public func resetState() {
        state = .idle
    }

    /// Reset error state to allow retry
    public func clearError() {
        if case .failure = state {
            state = .idle
        }
    }
}
#endif
