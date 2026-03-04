// BreathTechnique.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// The type of breath phase in a technique cycle
public enum BreathPhaseType: String, Codable, Sendable {
    case inhale
    case hold
    case exhale
}

/// A single phase within a breathing technique cycle
public struct BreathPhase: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let duration: TimeInterval
    public let phaseType: BreathPhaseType

    public init(id: String, name: String, duration: TimeInterval, phaseType: BreathPhaseType) {
        self.id = id
        self.name = name
        self.duration = duration
        self.phaseType = phaseType
    }
}

/// Difficulty level for a breath technique
public enum BreathDifficulty: String, Codable, Sendable {
    case beginner
    case intermediate
}

/// A breathing technique with its phases, timing, and metadata
public struct BreathTechnique: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let description: String
    public let phases: [BreathPhase]
    public let defaultDurationMinutes: Int
    public let difficulty: BreathDifficulty
    public let bestFor: String

    /// Total duration of one complete breath cycle
    public var cycleDuration: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }

    /// Formatted timing string (e.g. "5.5s in · 5.5s out")
    public var timingDescription: String {
        phases.map { phase in
            let seconds = phase.duration.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0fs", phase.duration)
                : String(format: "%.1fs", phase.duration)
            return seconds
        }.joined(separator: " · ")
    }

    // MARK: - Phase 1 Techniques

    public static let resonant = BreathTechnique(
        id: "resonant",
        name: "Resonance Breathing",
        subtitle: "The Perfect Breath",
        description: "Inhale and exhale at 5.5 seconds each — the rate that synchronizes heart, lungs, and circulation for peak efficiency. ~5.5 BPM hits HRV resonance frequency.",
        phases: [
            BreathPhase(id: "inhale", name: "inhale", duration: 5.5, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "exhale", duration: 5.5, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Daily wellness, HRV, calm focus"
    )

    public static let coherent = BreathTechnique(
        id: "coherent",
        name: "Coherent Breathing",
        subtitle: "Calm Entry Point",
        description: "A slightly more accessible rhythm — 6 seconds in, 6 seconds out. Same coherence principle as resonance breathing. Great for beginners.",
        phases: [
            BreathPhase(id: "inhale", name: "inhale", duration: 6.0, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "exhale", duration: 6.0, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Beginners, relaxation, coherence"
    )

    /// All available techniques for the current phase
    public static let allTechniques: [BreathTechnique] = [.resonant, .coherent]
}
