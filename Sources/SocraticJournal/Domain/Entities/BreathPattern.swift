// BreathPattern.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a breathing technique with its phase timings
public struct BreathPattern: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let inhaleDuration: TimeInterval    // seconds
    public let holdInDuration: TimeInterval    // seconds (0 = no hold after inhale)
    public let exhaleDuration: TimeInterval    // seconds
    public let holdOutDuration: TimeInterval   // seconds (0 = no hold after exhale)
    public let difficulty: Difficulty

    /// Difficulty level of the pattern
    public enum Difficulty: String, Codable, Sendable {
        case beginner
        case intermediate
        case advanced
    }

    /// Total duration of one complete breath cycle in seconds
    public var cycleDuration: TimeInterval {
        inhaleDuration + holdInDuration + exhaleDuration + holdOutDuration
    }

    /// Approximate breaths per minute for this pattern
    public var breathsPerMinute: Double {
        60.0 / cycleDuration
    }

    /// Ordered list of phases with their durations for this pattern
    /// Phases with 0 duration are excluded
    public var phases: [(phase: SessionPhase, duration: TimeInterval)] {
        var result: [(phase: SessionPhase, duration: TimeInterval)] = []
        if inhaleDuration > 0 { result.append((.inhale, inhaleDuration)) }
        if holdInDuration > 0 { result.append((.holdIn, holdInDuration)) }
        if exhaleDuration > 0 { result.append((.exhale, exhaleDuration)) }
        if holdOutDuration > 0 { result.append((.holdOut, holdOutDuration)) }
        return result
    }

    public init(
        id: String,
        name: String,
        description: String,
        inhaleDuration: TimeInterval,
        holdInDuration: TimeInterval = 0,
        exhaleDuration: TimeInterval,
        holdOutDuration: TimeInterval = 0,
        difficulty: Difficulty = .beginner
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.inhaleDuration = inhaleDuration
        self.holdInDuration = holdInDuration
        self.exhaleDuration = exhaleDuration
        self.holdOutDuration = holdOutDuration
        self.difficulty = difficulty
    }
}

// MARK: - Built-in Patterns

extension BreathPattern {
    /// Resonance Breathing: 5.5s in, 5.5s out (~5.45 bpm)
    /// The "perfect breath" from James Nestor
    public static let resonance = BreathPattern(
        id: "resonance",
        name: "Resonance",
        description: "The perfect breath. 5.5 seconds in, 5.5 out. Optimizes heart rate variability and calms the nervous system.",
        inhaleDuration: 5.5,
        exhaleDuration: 5.5,
        difficulty: .beginner
    )

    /// Coherent Breathing: 6s in, 6s out (5 bpm)
    /// Slightly slower variant for deeper relaxation
    public static let coherent = BreathPattern(
        id: "coherent",
        name: "Coherent",
        description: "6 seconds in, 6 out. A slightly slower rhythm for deeper relaxation and stress relief.",
        inhaleDuration: 6.0,
        exhaleDuration: 6.0,
        difficulty: .beginner
    )

    /// All available MVP patterns
    public static let allPatterns: [BreathPattern] = [resonance, coherent]

    /// Default pattern for new users
    public static let `default` = resonance
}
