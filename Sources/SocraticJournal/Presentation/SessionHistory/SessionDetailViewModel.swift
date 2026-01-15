// SessionDetailViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the session detail bottom sheet
@Observable
@MainActor
public final class SessionDetailViewModel {
    // MARK: - State

    private(set) var session: JournalSession
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    /// All exchanges sorted by timestamp
    var sortedExchanges: [Exchange] {
        session.exchanges.sorted { $0.timestamp < $1.timestamp }
    }

    /// Number of answered (non-skipped) exchanges
    var answeredCount: Int {
        session.exchanges.filter { !$0.skipped }.count
    }

    /// Number of skipped exchanges
    var skippedCount: Int {
        session.exchanges.filter { $0.skipped }.count
    }

    /// Total number of exchanges
    var totalExchanges: Int {
        session.exchanges.count
    }

    /// Exchanges with insight cards
    var insightExchanges: [Exchange] {
        session.exchanges.filter { $0.insightCard != nil }
    }

    /// Formatted session date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: session.createdAt)
    }

    /// Short formatted date for header
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: session.createdAt)
    }

    /// Time of session
    var sessionTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: session.createdAt)
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    public init(session: JournalSession, repository: JournalRepositoryProtocol) {
        self.session = session
        self.repository = repository
    }

    // MARK: - Actions

    /// Reload session data from repository
    public func refreshSession() async {
        isLoading = true
        error = nil

        do {
            if let updatedSession = try await repository.getSession(id: session.id) {
                session = updatedSession
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
#endif
