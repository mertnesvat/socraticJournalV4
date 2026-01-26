// CharacterQuizServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

// MARK: - Service Protocol

/// Protocol defining the character quiz matching service
/// Analyzes journal entries to find matching fictional characters
public protocol CharacterQuizServiceProtocol: Sendable {
    /// Matches the user's personality to characters from a fictional universe
    /// - Parameter request: The character match request containing journal entries and universe
    /// - Returns: A result containing character matches with confidence scores
    func matchCharacters(request: CharacterMatchRequest) async throws -> CharacterMatchResult

    /// Generates a sample character match result for preview
    /// - Parameter universeId: The universe to generate sample matches for
    /// - Returns: A sample character match result with disclaimer
    func generateSampleMatch(for universeId: String) async throws -> CharacterMatchResult
}

// MARK: - Request Types

/// Request data for character matching analysis
/// Uses JournalEntryData from FirebaseFunctionsServiceProtocol for Firebase compatibility
public struct CharacterMatchRequest: Codable, Sendable {
    /// Array of journal entries with question/answer pairs
    public let journalEntries: [JournalEntryData]
    /// The ID of the fictional universe to match against
    public let universeId: String

    public init(journalEntries: [JournalEntryData], universeId: String) {
        self.journalEntries = journalEntries
        self.universeId = universeId
    }
}

// MARK: - Response Types

/// Result of character matching analysis
public struct CharacterMatchResult: Codable, Sendable, Equatable {
    /// Array of character matches sorted by confidence (highest first)
    public let matches: [CharacterMatch]
    /// The universe that was analyzed
    public let universe: String
    /// Summary of the analysis approach
    public let analysisSummary: String
    /// When the analysis was performed
    public let generatedAt: Date

    public init(
        matches: [CharacterMatch],
        universe: String,
        analysisSummary: String,
        generatedAt: Date
    ) {
        self.matches = matches
        self.universe = universe
        self.analysisSummary = analysisSummary
        self.generatedAt = generatedAt
    }

    /// Returns the top match if available
    public var topMatch: CharacterMatch? {
        matches.first
    }

    /// Returns matches above a confidence threshold
    public func matches(above threshold: Double) -> [CharacterMatch] {
        matches.filter { $0.confidence >= threshold }
    }
}

/// A journal excerpt used as evidence for the character match
public struct JournalExcerpt: Codable, Sendable, Equatable, Identifiable {
    /// The excerpt text from the user's journal
    public let text: String
    /// Brief explanation of how this excerpt supports the match
    public let relevance: String

    public var id: String { text }

    public init(text: String, relevance: String) {
        self.text = text
        self.relevance = relevance
    }
}

/// A single character match with confidence and reasoning
public struct CharacterMatch: Codable, Sendable, Equatable, Identifiable {
    /// The ID of the matched character
    public let characterId: String
    /// The name of the matched character
    public let characterName: String
    /// Confidence score from 0.0 to 1.0
    public let confidence: Double
    /// AI-generated explanation of why this character matches
    public let reasoning: String
    /// Excerpts from journal entries that support this match
    public let excerpts: [JournalExcerpt]

    public var id: String { characterId }

    public init(
        characterId: String,
        characterName: String,
        confidence: Double,
        reasoning: String,
        excerpts: [JournalExcerpt] = []
    ) {
        self.characterId = characterId
        self.characterName = characterName
        self.confidence = confidence
        self.reasoning = reasoning
        self.excerpts = excerpts
    }

    /// Returns the confidence as a percentage string (e.g., "87%")
    public var confidencePercentage: String {
        "\(Int(confidence * 100))%"
    }

    /// Returns a descriptive label for the confidence level
    public var confidenceLabel: String {
        switch confidence {
        case 0.8...: return "Strong Match"
        case 0.6..<0.8: return "Good Match"
        case 0.4..<0.6: return "Moderate Match"
        default: return "Possible Match"
        }
    }
}

// MARK: - Error Types

/// Errors that can occur in the character quiz service
public enum CharacterQuizError: Error, LocalizedError, Sendable {
    /// Not enough journal entries to perform meaningful analysis
    case insufficientData(required: Int, available: Int)
    /// The specified universe is not available
    case invalidUniverse(String)
    /// Character matching service is currently unavailable
    case serviceUnavailable
    /// Invalid response from the analysis service
    case invalidResponse
    /// Request timed out (analysis may take time)
    case timeout
    /// Unknown error occurred
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .insufficientData(let required, let available):
            return "Need at least \(required) journal entries for character matching. Currently have \(available)."
        case .invalidUniverse(let universe):
            return "The universe '\(universe)' is not available for character matching."
        case .serviceUnavailable:
            return "Character matching is currently unavailable. Please try again later."
        case .invalidResponse:
            return "Received an invalid response from the matching service."
        case .timeout:
            return "Character matching took too long. Please try again."
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
}
