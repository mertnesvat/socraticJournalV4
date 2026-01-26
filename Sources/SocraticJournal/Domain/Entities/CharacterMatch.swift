// CharacterMatch.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Supported franchises for character matching
public enum CharacterFranchise: String, CaseIterable, Codable, Sendable {
    case lordOfTheRings = "lordOfTheRings"
    case harryPotter = "harryPotter"
    case starWars = "starWars"

    /// Display name for the franchise
    public var displayName: String {
        switch self {
        case .lordOfTheRings: return "Lord of the Rings"
        case .harryPotter: return "Harry Potter"
        case .starWars: return "Star Wars"
        }
    }

    /// Icon for the franchise
    public var icon: String {
        switch self {
        case .lordOfTheRings: return "mountain.2.fill"
        case .harryPotter: return "wand.and.stars"
        case .starWars: return "sparkle"
        }
    }
}

/// Individual character match result
public struct CharacterMatch: Codable, Sendable, Identifiable, Equatable {
    public var id: String { character }

    /// Name of the matched character
    public let character: String

    /// Confidence percentage (0-100)
    public let confidence: Int

    /// Explanation of why this character matches
    public let reasoning: String

    public init(character: String, confidence: Int, reasoning: String) {
        self.character = character
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

/// Complete character match analysis result
public struct CharacterMatchResult: Codable, Sendable, Equatable {
    /// Top 3 character matches ordered by confidence
    public let matches: [CharacterMatch]

    /// The franchise that was analyzed
    public let franchise: CharacterFranchise

    /// When the analysis was performed
    public let analyzedAt: Date

    public init(matches: [CharacterMatch], franchise: CharacterFranchise, analyzedAt: Date) {
        self.matches = matches
        self.franchise = franchise
        self.analyzedAt = analyzedAt
    }

    /// The primary (highest confidence) match
    public var primaryMatch: CharacterMatch? {
        matches.first
    }
}
