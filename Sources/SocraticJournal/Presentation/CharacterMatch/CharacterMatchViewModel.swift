// CharacterMatchViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Character Match feature
@Observable
@MainActor
public final class CharacterMatchViewModel {
    // MARK: - State

    private(set) var isLoading: Bool = false
    private(set) var isAnalyzing: Bool = false
    private(set) var error: Error?
    private(set) var totalEntries: Int = 0

    /// Currently selected franchise
    var selectedFranchise: CharacterFranchise = .lordOfTheRings

    /// Cached results per franchise
    private var cachedResults: [CharacterFranchise: CharacterMatchResult] = [:]

    /// Current result for the selected franchise
    var currentResult: CharacterMatchResult? {
        cachedResults[selectedFranchise]
    }

    /// Whether features are unlocked (requires 5+ entries)
    var isUnlocked: Bool {
        totalEntries >= 5
    }

    /// Progress toward unlocking (0.0 to 1.0)
    var unlockProgress: Double {
        min(Double(totalEntries) / 5.0, 1.0)
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol
    private let functionsService: FirebaseFunctionsServiceProtocol

    // MARK: - Init

    public init(
        repository: JournalRepositoryProtocol,
        functionsService: FirebaseFunctionsServiceProtocol
    ) {
        self.repository = repository
        self.functionsService = functionsService
    }

    // MARK: - Actions

    /// Loads the initial data
    public func loadData() async {
        isLoading = true
        error = nil

        do {
            let stats = try await repository.getStats()
            totalEntries = stats.totalEntries
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Select a franchise
    public func selectFranchise(_ franchise: CharacterFranchise) {
        selectedFranchise = franchise
    }

    /// Analyze journal entries for character match
    public func analyzeCharacterMatch() async {
        guard isUnlocked else { return }

        isAnalyzing = true
        error = nil

        do {
            // Get completed sessions
            let sessions = try await repository.getAllSessions()
            let completedSessions = sessions.filter { $0.isComplete }

            // Convert to journal entry data
            let journalEntries: [JournalEntryData] = completedSessions.flatMap { session in
                session.exchanges.compactMap { exchange in
                    guard !exchange.skipped else { return nil }
                    return JournalEntryData(
                        question: exchange.question,
                        answer: exchange.answer,
                        clarityMirror: exchange.clarityMirror
                    )
                }
            }

            // Make the API call
            let request = CharacterMatchRequest(
                journalEntries: journalEntries,
                franchise: selectedFranchise
            )

            let result = try await functionsService.analyzeCharacterMatch(request: request)

            // Cache the result
            cachedResults[selectedFranchise] = result

        } catch {
            self.error = error
        }

        isAnalyzing = false
    }
}
#endif
