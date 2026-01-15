// BigFiveProfile.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a complete Big Five (OCEAN) personality profile
public struct BigFiveProfile: Codable, Sendable, Equatable {
    public let openness: PersonalityTrait
    public let conscientiousness: PersonalityTrait
    public let extraversion: PersonalityTrait
    public let agreeableness: PersonalityTrait
    public let neuroticism: PersonalityTrait
    public let summary: String
    public let analyzedAt: Date

    public init(
        openness: PersonalityTrait,
        conscientiousness: PersonalityTrait,
        extraversion: PersonalityTrait,
        agreeableness: PersonalityTrait,
        neuroticism: PersonalityTrait,
        summary: String,
        analyzedAt: Date = Date()
    ) {
        self.openness = openness
        self.conscientiousness = conscientiousness
        self.extraversion = extraversion
        self.agreeableness = agreeableness
        self.neuroticism = neuroticism
        self.summary = summary
        self.analyzedAt = analyzedAt
    }

    /// Returns all traits as an array for iteration
    public var allTraits: [PersonalityTrait] {
        [openness, conscientiousness, extraversion, agreeableness, neuroticism]
    }

    /// Returns trait by type
    public func trait(for type: TraitType) -> PersonalityTrait {
        switch type {
        case .openness: return openness
        case .conscientiousness: return conscientiousness
        case .extraversion: return extraversion
        case .agreeableness: return agreeableness
        case .neuroticism: return neuroticism
        }
    }

    /// Formatted date string for display
    public var formattedAnalyzedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: analyzedAt)
    }

    /// Time since last analysis
    public var timeSinceAnalysis: String {
        let interval = Date().timeIntervalSince(analyzedAt)
        let hours = Int(interval / 3600)
        let days = hours / 24

        if days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else {
            return "Just now"
        }
    }
}
