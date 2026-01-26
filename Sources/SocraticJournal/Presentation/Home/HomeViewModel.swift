// HomeViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Home screen
@Observable
@MainActor
public final class HomeViewModel {
    // MARK: - State

    private(set) var sessions: [JournalSession] = []
    private(set) var stats: JournalStats = .empty
    private(set) var readyLettersCount: Int = 0
    private(set) var sealedLettersCount: Int = 0
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    var selectedDate: Date? = nil
    var filteredSessions: [JournalSession] {
        guard let selectedDate = selectedDate else {
            return sessions
        }
        let calendar = Calendar.current
        return sessions.filter { session in
            calendar.isDate(session.createdAt, inSameDayAs: selectedDate)
        }
    }

    var hasNoSessions: Bool {
        sessions.isEmpty && !isLoading
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    public init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    public func loadData() async {
        isLoading = true
        error = nil

        do {
            async let sessionsTask = repository.getAllSessions()
            async let statsTask = repository.getStats()
            async let readyLettersTask = repository.getReadyLettersCount()
            async let sealedLettersTask = repository.getLetters(status: .sealed)

            sessions = try await sessionsTask
            stats = try await statsTask
            readyLettersCount = try await readyLettersTask
            sealedLettersCount = try await sealedLettersTask.count
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func selectDate(_ date: Date?) {
        if let date = date, let selectedDate = selectedDate {
            // If tapping the same date, deselect
            let calendar = Calendar.current
            if calendar.isDate(date, inSameDayAs: selectedDate) {
                self.selectedDate = nil
                return
            }
        }
        selectedDate = date
    }

    public func deleteSession(_ session: JournalSession) async {
        do {
            try await repository.deleteSession(id: session.id)
            sessions.removeAll { $0.id == session.id }
            stats = try await repository.getStats()
        } catch {
            self.error = error
        }
    }

    public func refreshData() async {
        await loadData()
    }
}
#endif
