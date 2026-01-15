// LettersListViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// Filter options for letters list
public enum LetterFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case sealed = "Sealed"
    case ready = "Ready"
    case read = "Read"
    case archived = "Archived"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .all: return "tray.full"
        case .sealed: return "lock.fill"
        case .ready: return "envelope.badge"
        case .read: return "envelope.open"
        case .archived: return "archivebox"
        }
    }
}

/// ViewModel for the letters list screen
@Observable
@MainActor
public final class LettersListViewModel {
    // MARK: - State

    private(set) var letters: [FutureLetter] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    var selectedFilter: LetterFilter = .all

    // MARK: - Computed Properties

    var filteredLetters: [FutureLetter] {
        // First update status of any sealed letters that are now ready
        let updatedLetters = letters.map { letter -> FutureLetter in
            if letter.isReadyToOpen && letter.status == .sealed {
                var updated = letter
                updated.status = .ready
                return updated
            }
            return letter
        }

        switch selectedFilter {
        case .all:
            return updatedLetters.sorted { sortLetters($0, $1) }
        case .sealed:
            return updatedLetters
                .filter { $0.status == .sealed && !$0.isReadyToOpen }
                .sorted { $0.deliveryDate < $1.deliveryDate }
        case .ready:
            return updatedLetters
                .filter { $0.status == .ready || ($0.status == .sealed && $0.isReadyToOpen) }
                .sorted { $0.deliveryDate < $1.deliveryDate }
        case .read:
            return updatedLetters
                .filter { $0.status == .read }
                .sorted { ($0.readAt ?? $0.createdAt) > ($1.readAt ?? $1.createdAt) }
        case .archived:
            return updatedLetters
                .filter { $0.status == .archived }
                .sorted { ($0.readAt ?? $0.createdAt) > ($1.readAt ?? $1.createdAt) }
        }
    }

    var readyCount: Int {
        letters.filter { letter in
            letter.status == .ready || (letter.status == .sealed && letter.isReadyToOpen)
        }.count
    }

    var hasNoLetters: Bool {
        letters.isEmpty && !isLoading
    }

    var filterCounts: [LetterFilter: Int] {
        var counts: [LetterFilter: Int] = [:]
        counts[.all] = letters.count
        counts[.sealed] = letters.filter { $0.status == .sealed && !$0.isReadyToOpen }.count
        counts[.ready] = letters.filter { $0.status == .ready || ($0.status == .sealed && $0.isReadyToOpen) }.count
        counts[.read] = letters.filter { $0.status == .read }.count
        counts[.archived] = letters.filter { $0.status == .archived }.count
        return counts
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    public init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    public func loadLetters() async {
        isLoading = true
        error = nil

        do {
            letters = try await repository.getAllLetters()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    public func openLetter(_ letter: FutureLetter) async {
        guard letter.status == .sealed && letter.isReadyToOpen || letter.status == .ready else {
            return
        }

        do {
            try await repository.updateLetterStatus(id: letter.id, status: .read)
            // Update local state
            if let index = letters.firstIndex(where: { $0.id == letter.id }) {
                letters[index].status = .read
                letters[index].readAt = Date()
            }
        } catch {
            self.error = error
        }
    }

    public func archiveLetter(_ letter: FutureLetter) async {
        guard letter.status == .read else { return }

        do {
            try await repository.updateLetterStatus(id: letter.id, status: .archived)
            // Update local state
            if let index = letters.firstIndex(where: { $0.id == letter.id }) {
                letters[index].status = .archived
            }
        } catch {
            self.error = error
        }
    }

    public func refreshLetters() async {
        await loadLetters()
    }

    // MARK: - Private Helpers

    private func sortLetters(_ a: FutureLetter, _ b: FutureLetter) -> Bool {
        // Ready letters first, then by delivery date
        let aIsReady = a.status == .ready || (a.status == .sealed && a.isReadyToOpen)
        let bIsReady = b.status == .ready || (b.status == .sealed && b.isReadyToOpen)

        if aIsReady && !bIsReady { return true }
        if !aIsReady && bIsReady { return false }

        // Then sealed by nearest delivery date
        if a.status == .sealed && b.status == .sealed {
            return a.deliveryDate < b.deliveryDate
        }

        // Everything else by creation date (newest first)
        return a.createdAt > b.createdAt
    }
}
#endif
