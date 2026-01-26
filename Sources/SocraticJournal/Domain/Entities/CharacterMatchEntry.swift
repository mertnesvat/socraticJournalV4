// CharacterMatchEntry.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a single character match with confidence score and explanation
public struct CharacterMatchEntry: Codable, Identifiable, Hashable, Sendable {
    public let character: FictionalCharacter
    public let confidencePercentage: Int
    public let explanation: String

    /// Uses the character's id for identification
    public var id: String {
        character.id
    }

    public init(
        character: FictionalCharacter,
        confidencePercentage: Int,
        explanation: String
    ) {
        self.character = character
        // Clamp confidence between 0 and 100
        self.confidencePercentage = max(0, min(100, confidencePercentage))
        self.explanation = explanation
    }

    /// Returns a formatted confidence string (e.g., "85%")
    public var formattedConfidence: String {
        "\(confidencePercentage)%"
    }

    /// Returns the confidence as a decimal (0.0 to 1.0)
    public var confidenceDecimal: Double {
        Double(confidencePercentage) / 100.0
    }

    /// Returns a confidence level description
    public var confidenceLevel: ConfidenceLevel {
        switch confidencePercentage {
        case 80...100: return .veryHigh
        case 60..<80: return .high
        case 40..<60: return .moderate
        case 20..<40: return .low
        default: return .veryLow
        }
    }
}

/// Describes the confidence level of a character match
public enum ConfidenceLevel: String, Codable, Sendable {
    case veryHigh
    case high
    case moderate
    case low
    case veryLow

    public var displayName: String {
        switch self {
        case .veryHigh: return "Very Strong Match"
        case .high: return "Strong Match"
        case .moderate: return "Moderate Match"
        case .low: return "Mild Match"
        case .veryLow: return "Slight Match"
        }
    }
}
