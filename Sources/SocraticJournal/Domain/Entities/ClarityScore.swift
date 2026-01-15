// ClarityScore.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents the clarity score and insights from a journal session
public struct ClarityScore: Codable, Sendable, Equatable {
    /// The overall clarity score from 0.0 to 10.0
    public let score: Double

    /// Key themes identified in the session
    public let themes: [String]

    /// Brief insight summary
    public let insight: String

    /// Areas for further exploration
    public let explorationSuggestions: [String]

    public init(
        score: Double,
        themes: [String] = [],
        insight: String = "",
        explorationSuggestions: [String] = []
    ) {
        self.score = min(max(score, 0.0), 10.0)
        self.themes = themes
        self.insight = insight
        self.explorationSuggestions = explorationSuggestions
    }

    /// Returns a display-friendly label for the score
    public var scoreLabel: String {
        switch score {
        case 0..<3: return "Emerging"
        case 3..<5: return "Developing"
        case 5..<7: return "Clear"
        case 7..<9: return "Insightful"
        default: return "Profound"
        }
    }
}
