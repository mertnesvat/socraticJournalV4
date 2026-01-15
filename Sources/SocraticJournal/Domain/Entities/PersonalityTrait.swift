// PersonalityTrait.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a single Big Five personality trait
public struct PersonalityTrait: Codable, Sendable, Equatable {
    public let type: TraitType
    public let score: Int          // 0-100
    public let label: String       // High/Moderate/Low
    public let description: String
    public let evidence: [String]  // Quotes from journal entries

    public init(
        type: TraitType,
        score: Int,
        label: String,
        description: String,
        evidence: [String]
    ) {
        self.type = type
        self.score = max(0, min(100, score))
        self.label = label
        self.description = description
        self.evidence = evidence
    }

    /// Returns the trait name for display
    public var displayName: String {
        type.displayName
    }

    /// Returns the trait emoji
    public var emoji: String {
        type.emoji
    }
}

/// Big Five personality trait types (OCEAN model)
public enum TraitType: String, Codable, Sendable, CaseIterable {
    case openness
    case conscientiousness
    case extraversion
    case agreeableness
    case neuroticism

    /// Display name for the trait
    public var displayName: String {
        switch self {
        case .openness: return "Openness to Experience"
        case .conscientiousness: return "Conscientiousness"
        case .extraversion: return "Extraversion"
        case .agreeableness: return "Agreeableness"
        case .neuroticism: return "Neuroticism"
        }
    }

    /// Short name for the trait
    public var shortName: String {
        switch self {
        case .openness: return "Openness"
        case .conscientiousness: return "Conscientiousness"
        case .extraversion: return "Extraversion"
        case .agreeableness: return "Agreeableness"
        case .neuroticism: return "Neuroticism"
        }
    }

    /// Emoji representing the trait
    public var emoji: String {
        switch self {
        case .openness: return "🎨"
        case .conscientiousness: return "📋"
        case .extraversion: return "🎭"
        case .agreeableness: return "🤝"
        case .neuroticism: return "🌊"
        }
    }

    /// Brief description of what this trait measures
    public var briefDescription: String {
        switch self {
        case .openness:
            return "Curiosity, creativity, and openness to new ideas"
        case .conscientiousness:
            return "Organization, dependability, and self-discipline"
        case .extraversion:
            return "Sociability, assertiveness, and positive emotions"
        case .agreeableness:
            return "Compassion, cooperation, and trust"
        case .neuroticism:
            return "Emotional sensitivity and tendency toward negative emotions"
        }
    }
}
