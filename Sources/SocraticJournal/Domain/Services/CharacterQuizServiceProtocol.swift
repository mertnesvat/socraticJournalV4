// CharacterQuizServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the character quiz service
/// Analyzes journal entries to match users with fictional characters
public protocol CharacterQuizServiceProtocol: Sendable {
    /// Analyzes journal exchanges to find character matches for a specific franchise
    /// - Parameters:
    ///   - entries: Array of journal exchanges to analyze
    ///   - franchise: The franchise to match characters from
    /// - Returns: A character quiz result with ranked matches
    func analyzeCharacterMatch(
        entries: [Exchange],
        franchise: Franchise
    ) async throws -> CharacterQuizResult

    /// Generates a sample character quiz result for preview mode
    /// - Parameter franchise: The franchise to generate sample results for
    /// - Returns: A sample result with disclaimer
    func generateSampleResult(for franchise: Franchise) async throws -> CharacterQuizResult

    /// Returns the minimum number of entries required for analysis
    var minimumEntriesRequired: Int { get }

    // MARK: - Quiz History

    /// Saves a quiz result to persistent storage
    /// - Parameter result: The quiz result to save
    func saveQuizResult(_ result: CharacterQuizResult) async throws

    /// Retrieves all quiz history, sorted by date (newest first)
    /// - Returns: Array of all saved quiz results
    func getQuizHistory() async throws -> [CharacterQuizResult]

    /// Returns the most recent quiz result across all franchises
    /// - Returns: The latest quiz result, or nil if no history exists
    func getLatestResult() async throws -> CharacterQuizResult?

    /// Returns the most recent quiz result for a specific franchise
    /// - Parameter franchise: The franchise to filter by
    /// - Returns: The latest result for that franchise, or nil if none exists
    func getLatestResult(for franchise: Franchise) async throws -> CharacterQuizResult?
}

/// Errors that can occur during character quiz analysis
public enum CharacterQuizError: Error, LocalizedError, Sendable {
    /// Not enough journal entries to perform analysis
    case insufficientEntries(required: Int, available: Int)
    /// Network request failed
    case networkError(underlying: Error)
    /// Analysis took too long
    case analysisTimeout
    /// Response from analysis service was invalid
    case invalidResponse
    /// The requested franchise is not yet supported
    case unsupportedFranchise(Franchise)
    /// Service is temporarily unavailable
    case serviceUnavailable

    public var errorDescription: String? {
        switch self {
        case .insufficientEntries(let required, let available):
            return "Need at least \(required) journal entries to find your character match. You have \(available)."
        case .networkError:
            return "Unable to connect to the analysis service. Please check your connection and try again."
        case .analysisTimeout:
            return "The analysis took too long. Please try again."
        case .invalidResponse:
            return "Received an unexpected response. Please try again."
        case .unsupportedFranchise(let franchise):
            return "\(franchise.displayName) character matching is coming soon!"
        case .serviceUnavailable:
            return "Character matching is temporarily unavailable. Please try again later."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .insufficientEntries(let required, let available):
            let needed = required - available
            return "Complete \(needed) more journal \(needed == 1 ? "entry" : "entries") to unlock this feature."
        case .networkError:
            return "Check your internet connection and try again."
        case .analysisTimeout:
            return "Try again with a stable connection."
        case .invalidResponse:
            return "If this persists, please contact support."
        case .unsupportedFranchise:
            return "Check back soon for updates!"
        case .serviceUnavailable:
            return "Please try again in a few minutes."
        }
    }
}
