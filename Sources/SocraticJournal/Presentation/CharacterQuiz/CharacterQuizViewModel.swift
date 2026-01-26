// CharacterQuizViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

// MARK: - Quiz State

/// Represents the current state of the character quiz flow
public enum CharacterQuizState: Equatable {
    case idle
    case selectingUniverse
    case analyzing(universe: FictionalUniverse)
    case results(result: CharacterMatchResult, universe: FictionalUniverse)
    case viewingHistory
    case viewingHistoryDetail(entry: CharacterQuizHistoryEntry)
    case error(message: String)
    case insufficientEntries(current: Int, required: Int)
}

// MARK: - ViewModel

/// ViewModel for the Character Quiz feature
@Observable
@MainActor
public final class CharacterQuizViewModel {
    // MARK: - State

    private(set) var state: CharacterQuizState = .idle
    private(set) var totalEntries: Int = 0
    private(set) var journalEntries: [String] = []

    /// Quiz history entries
    private(set) var historyEntries: [CharacterQuizHistoryEntry] = []

    /// The currently viewed history entry
    private(set) var selectedHistoryEntry: CharacterQuizHistoryEntry?

    /// The currently selected universe (if any)
    var selectedUniverse: FictionalUniverse? {
        switch state {
        case .analyzing(let universe):
            return universe
        case .results(_, let universe):
            return universe
        case .viewingHistoryDetail(let entry):
            return FictionalUniverse.allUniverses.first { $0.id == entry.universeId }
        default:
            return nil
        }
    }

    /// Whether the quiz is currently analyzing
    var isAnalyzing: Bool {
        if case .analyzing = state { return true }
        return false
    }

    /// Whether results are being displayed
    var isShowingResults: Bool {
        if case .results = state { return true }
        return false
    }

    /// The current result (if available)
    var currentResult: CharacterMatchResult? {
        if case .results(let result, _) = state { return result }
        if case .viewingHistoryDetail(let entry) = state { return entry.result }
        return nil
    }

    /// Whether history is being viewed
    var isViewingHistory: Bool {
        if case .viewingHistory = state { return true }
        if case .viewingHistoryDetail = state { return true }
        return false
    }

    /// Count of history entries
    var historyCount: Int {
        historyEntries.count
    }

    /// Count of favorite entries
    var favoritesCount: Int {
        historyEntries.filter { $0.isFavorite }.count
    }

    /// Minimum entries required for quiz
    private let minimumEntriesRequired = 3

    /// Whether user has enough entries
    var hasEnoughEntries: Bool {
        totalEntries >= minimumEntriesRequired
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol
    private let quizService: CharacterQuizServiceProtocol
    private let historyRepository: CharacterQuizHistoryRepositoryProtocol

    // MARK: - Init

    public init(
        repository: JournalRepositoryProtocol,
        quizService: CharacterQuizServiceProtocol,
        historyRepository: CharacterQuizHistoryRepositoryProtocol = LocalCharacterQuizHistoryRepository()
    ) {
        self.repository = repository
        self.quizService = quizService
        self.historyRepository = historyRepository
    }

    // MARK: - Actions

    /// Load initial data and determine if user can take the quiz
    public func loadData() async {
        do {
            // Load history first
            historyEntries = try await historyRepository.getAllResults()

            // Get entry count
            let stats = try await repository.getStats()
            totalEntries = stats.totalEntries

            // If not enough entries, show insufficient entries state
            if totalEntries < minimumEntriesRequired {
                state = .insufficientEntries(
                    current: totalEntries,
                    required: minimumEntriesRequired
                )
                return
            }

            // Load journal entries for analysis
            let sessions = try await repository.getAllSessions()
            let completedSessions = sessions.filter { $0.isComplete }

            // Extract journal content from sessions
            journalEntries = completedSessions.compactMap { session -> String? in
                // Get the user's responses from the session
                let userMessages = session.messages.filter { $0.role == .user }
                guard !userMessages.isEmpty else { return nil }

                // Combine user messages into a single entry
                return userMessages.map { $0.content }.joined(separator: "\n")
            }

            // Show universe selection
            state = .selectingUniverse

        } catch {
            state = .error(message: error.localizedDescription)
        }
    }

    /// Start the quiz flow - show universe selection
    public func startQuiz() {
        if hasEnoughEntries {
            state = .selectingUniverse
        } else {
            state = .insufficientEntries(
                current: totalEntries,
                required: minimumEntriesRequired
            )
        }
    }

    /// Select a universe and begin analysis
    public func selectUniverse(_ universe: FictionalUniverse) async {
        state = .analyzing(universe: universe)

        do {
            // Create request with journal entries
            let request = CharacterMatchRequest(
                journalEntries: journalEntries,
                universeId: universe.id
            )

            // If we don't have enough entries, generate sample
            let result: CharacterMatchResult
            if journalEntries.isEmpty || journalEntries.count < minimumEntriesRequired {
                result = try await quizService.generateSampleMatch(for: universe.id)
            } else {
                result = try await quizService.matchCharacters(request: request)
            }

            // Save result to history
            let historyEntry = CharacterQuizHistoryEntry(
                universeId: universe.id,
                universeName: universe.name,
                result: result,
                entryCountAtAnalysis: totalEntries
            )
            try await historyRepository.saveResult(historyEntry)

            // Refresh history
            historyEntries = try await historyRepository.getAllResults()

            state = .results(result: result, universe: universe)

        } catch let error as CharacterQuizError {
            state = .error(message: error.localizedDescription)
        } catch {
            state = .error(message: "An unexpected error occurred. Please try again.")
        }
    }

    /// Try a different universe from results
    public func tryDifferentUniverse() {
        state = .selectingUniverse
    }

    /// Reset to initial state
    public func reset() {
        state = .idle
        selectedHistoryEntry = nil
    }

    /// Retry after error
    public func retry() async {
        await loadData()
    }

    /// Find a character by ID from a universe
    public func findCharacter(id: String, in universe: FictionalUniverse) -> FictionalCharacter? {
        universe.characters.first { $0.id == id }
    }

    // MARK: - History Actions

    /// Show history view
    public func showHistory() {
        state = .viewingHistory
    }

    /// View a specific history entry
    public func viewHistoryEntry(_ entry: CharacterQuizHistoryEntry) {
        selectedHistoryEntry = entry
        state = .viewingHistoryDetail(entry: entry)
    }

    /// Toggle favorite status for an entry
    public func toggleFavorite(_ entry: CharacterQuizHistoryEntry) async {
        do {
            try await historyRepository.toggleFavorite(id: entry.id)
            historyEntries = try await historyRepository.getAllResults()

            // Update selected entry if viewing detail
            if let selected = selectedHistoryEntry, selected.id == entry.id {
                selectedHistoryEntry = historyEntries.first { $0.id == entry.id }
            }
        } catch {
            // Silently fail - could show error in future
        }
    }

    /// Delete a history entry
    public func deleteHistoryEntry(_ entry: CharacterQuizHistoryEntry) async {
        do {
            try await historyRepository.deleteResult(id: entry.id)
            historyEntries = try await historyRepository.getAllResults()

            // If viewing the deleted entry, go back to history
            if let selected = selectedHistoryEntry, selected.id == entry.id {
                selectedHistoryEntry = nil
                state = .viewingHistory
            }
        } catch {
            // Silently fail - could show error in future
        }
    }

    /// Re-analyze with a specific universe (using current journal entries)
    public func reanalyze(universeId: String) async {
        guard let universe = FictionalUniverse.allUniverses.first(where: { $0.id == universeId }) else {
            return
        }
        await selectUniverse(universe)
    }

    /// Go back from history detail to history list
    public func backToHistory() {
        selectedHistoryEntry = nil
        state = .viewingHistory
    }

    /// Go back from history to quiz
    public func backToQuiz() {
        selectedHistoryEntry = nil
        if hasEnoughEntries {
            state = .selectingUniverse
        } else {
            state = .insufficientEntries(
                current: totalEntries,
                required: minimumEntriesRequired
            )
        }
    }

    /// Check if personality has evolved since last result for a universe
    public func hasPersonalityEvolved(for universeId: String) -> Bool {
        let universeResults = historyEntries.filter { $0.universeId == universeId }
        guard universeResults.count >= 2 else { return false }

        let sortedResults = universeResults.sorted { $0.createdAt > $1.createdAt }
        return sortedResults[0].hasEvolvedFrom(sortedResults[1])
    }
}
#endif
