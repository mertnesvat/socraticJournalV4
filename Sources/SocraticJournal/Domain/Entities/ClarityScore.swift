// ClarityScore.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Score quality level based on total score
public enum ScoreQuality: String, Codable, Sendable {
    case quick = "Quick Check-in"
    case moderate = "Thoughtful Reflection"
    case high = "Deep Dive"

    /// Returns quality level based on score (0-100)
    public static func from(score: Int) -> ScoreQuality {
        switch score {
        case 0..<40: return .quick
        case 40..<70: return .moderate
        default: return .high
        }
    }
}

/// Represents the clarity score and insights from a journal session
public struct ClarityScore: Codable, Sendable, Equatable {
    /// The overall clarity score from 0 to 100
    public let total: Int

    /// Completion score component (0-100) - 30% weight
    /// Based on how many questions were answered vs skipped
    public let completion: Int

    /// Depth score component (0-100) - 40% weight
    /// Based on average word count and thoughtfulness of answers
    public let depth: Int

    /// Emotional score component (0-100) - 30% weight
    /// Based on presence of emotional words and self-reflection
    public let emotional: Int

    /// Display label for the score quality (e.g., "Deep Dive")
    public let label: String

    /// Personalized encouraging message based on score quality
    public let message: String

    public init(
        total: Int,
        completion: Int,
        depth: Int,
        emotional: Int,
        label: String,
        message: String
    ) {
        self.total = min(max(total, 0), 100)
        self.completion = min(max(completion, 0), 100)
        self.depth = min(max(depth, 0), 100)
        self.emotional = min(max(emotional, 0), 100)
        self.label = label
        self.message = message
    }

    /// Returns the score quality enum
    public var quality: ScoreQuality {
        ScoreQuality.from(score: total)
    }

    /// Returns a color hint based on score quality
    public var qualityColorName: String {
        switch quality {
        case .quick: return "orange"
        case .moderate: return "blue"
        case .high: return "green"
        }
    }
}
