// CharacterQuizHistoryRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining character quiz history data operations
public protocol CharacterQuizHistoryRepositoryProtocol: Sendable {
    // MARK: - History Operations

    /// Saves a new quiz result to history
    func saveResult(_ entry: CharacterQuizHistoryEntry) async throws

    /// Fetches all quiz results, sorted by date (newest first)
    func getAllResults() async throws -> [CharacterQuizHistoryEntry]

    /// Fetches quiz results for a specific universe
    func getResults(forUniverse universeId: String) async throws -> [CharacterQuizHistoryEntry]

    /// Fetches a specific result by ID
    func getResult(id: String) async throws -> CharacterQuizHistoryEntry?

    // MARK: - Favorites

    /// Toggles the favorite status of a result
    func toggleFavorite(id: String) async throws

    /// Fetches all favorited results
    func getFavorites() async throws -> [CharacterQuizHistoryEntry]

    // MARK: - Deletion

    /// Deletes a specific result
    func deleteResult(id: String) async throws

    /// Deletes all results for a universe
    func deleteResults(forUniverse universeId: String) async throws

    /// Clears all quiz history
    func clearAllHistory() async throws

    // MARK: - Queries

    /// Returns the most recent result for a universe (if any)
    func getMostRecentResult(forUniverse universeId: String) async throws -> CharacterQuizHistoryEntry?

    /// Returns the count of results
    func getResultCount() async throws -> Int
}
