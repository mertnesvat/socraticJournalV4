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

    /// The currently selected universe (if any)
    var selectedUniverse: FictionalUniverse? {
        switch state {
        case .analyzing(let universe):
            return universe
        case .results(_, let universe):
            return universe
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
        return nil
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

    // MARK: - Init

    public init(
        repository: JournalRepositoryProtocol,
        quizService: CharacterQuizServiceProtocol
    ) {
        self.repository = repository
        self.quizService = quizService
    }

    // MARK: - Actions

    /// Load initial data and determine if user can take the quiz
    public func loadData() async {
        do {
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
    }

    /// Retry after error
    public func retry() async {
        await loadData()
    }

    /// Find a character by ID from a universe
    public func findCharacter(id: String, in universe: FictionalUniverse) -> FictionalCharacter? {
        universe.characters.first { $0.id == id }
    }
}
#endif
