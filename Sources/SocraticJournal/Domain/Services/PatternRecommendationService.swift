// PatternRecommendationService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A time-of-day recommendation for a breathing pattern
public struct PatternRecommendation: Sendable {
    public let patternId: String
    public let reason: String
    public let suggestedDurationMinutes: Int

    /// Resolve the full BreathPattern from the recommendation
    public var pattern: BreathPattern? {
        BreathPattern.allPatterns.first { $0.id == patternId }
    }
}

/// Pure logic service that recommends a breathing pattern based on time of day
public struct PatternRecommendationService {
    public static func recommend(for date: Date = Date()) -> PatternRecommendation {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5...8:
            return PatternRecommendation(
                patternId: "resonance",
                reason: "Morning baseline \u{2014} synchronise your HRV for the day",
                suggestedDurationMinutes: 5
            )
        case 9...11:
            return PatternRecommendation(
                patternId: "box",
                reason: "Focus and clarity for deep work",
                suggestedDurationMinutes: 5
            )
        case 12...13:
            return PatternRecommendation(
                patternId: "physiological",
                reason: "Quick reset after the morning push",
                suggestedDurationMinutes: 5
            )
        case 14...16:
            return PatternRecommendation(
                patternId: "resonance",
                reason: "Sustained calm focus for the afternoon",
                suggestedDurationMinutes: 5
            )
        case 17...19:
            return PatternRecommendation(
                patternId: "coherent",
                reason: "Wind-down \u{2014} ease out of work mode",
                suggestedDurationMinutes: 10
            )
        case 20...22:
            return PatternRecommendation(
                patternId: "478",
                reason: "Prepare your nervous system for sleep",
                suggestedDurationMinutes: 10
            )
        default:
            // 23:00-04:59
            return PatternRecommendation(
                patternId: "478",
                reason: "Calm your mind for rest",
                suggestedDurationMinutes: 10
            )
        }
    }
}
