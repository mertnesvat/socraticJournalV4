// BOLTScore.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A recorded BOLT (Body Oxygen Level Test) score
public struct BOLTScore: Identifiable, Codable, Sendable {
    public let id: String
    public let score: TimeInterval
    public let recordedAt: Date

    public init(id: String = UUID().uuidString, score: TimeInterval, recordedAt: Date = Date()) {
        self.id = id
        self.score = score
        self.recordedAt = recordedAt
    }

    public var tier: BOLTTier { BOLTTier.from(score: score) }
}

/// BOLT score tier classification
public enum BOLTTier: String, Codable, Sendable {
    case veryLow, belowAverage, average, good, excellent

    public static func from(score: TimeInterval) -> BOLTTier {
        switch score {
        case ..<10: return .veryLow
        case 10..<20: return .belowAverage
        case 20..<30: return .average
        case 30..<40: return .good
        default: return .excellent
        }
    }

    public var label: String {
        switch self {
        case .veryLow: return "Very Low"
        case .belowAverage: return "Below Average"
        case .average: return "Average"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }

    public var colorHex: String {
        switch self {
        case .veryLow: return "C4502A"
        case .belowAverage: return "7A6030"
        case .average: return "2D5F5D"
        case .good: return "5A6E3D"
        case .excellent: return "2D5F5D"
        }
    }

    public var interpretation: String {
        switch self {
        case .veryLow:
            return "Your CO₂ tolerance is very low — this is common in chronic mouth-breathers and people with anxiety. Buteyko Reduced breathing is your priority pattern. Even a few weeks of practice can dramatically improve this score."
        case .belowAverage:
            return "Below average, but this is where most modern adults land. Your chemoreceptors are over-sensitive to CO₂, causing you to over-breathe. Resonance and Coherent patterns will gradually recalibrate."
        case .average:
            return "Average range. You have reasonable CO₂ tolerance but there's significant room for growth. Regular practice with any pattern will improve this. Aim for 30+ as your next milestone."
        case .good:
            return "Good CO₂ tolerance. Your breathing efficiency is above average. You'll notice this in better sleep, lower resting heart rate, and calmer stress response. Keep going — 40+ is excellent."
        case .excellent:
            return "Excellent. This indicates strong parasympathetic tone, efficient gas exchange, and well-calibrated chemoreceptors. Nestor found that experienced meditators and free divers consistently score here."
        }
    }

    /// Trend direction comparing two scores
    public static func trend(previous: TimeInterval, current: TimeInterval) -> TrendDirection {
        let diff = current - previous
        if diff > 2 { return .improved }
        if diff < -2 { return .declined }
        return .same
    }

    public enum TrendDirection {
        case improved, declined, same

        public var symbol: String {
            switch self {
            case .improved: return "↑"
            case .declined: return "↓"
            case .same: return "→"
            }
        }

        public var colorHex: String {
            switch self {
            case .improved: return "5A6E3D"
            case .declined: return "C4502A"
            case .same: return "7A6E60"
            }
        }
    }
}
