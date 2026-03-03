// BreathTechnique.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

enum BreathPhaseType: String, Codable, Sendable {
    case inhale, hold, exhale, inhaleTopUp
}

struct BreathPhase: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let duration: TimeInterval
    let phaseType: BreathPhaseType
}

enum BreathDifficulty: String, Codable, Sendable {
    case beginner, intermediate, advanced
}

struct BreathTechnique: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let phases: [BreathPhase]
    let defaultDurationMinutes: Int
    let difficulty: BreathDifficulty
    let bestFor: String

    var cycleDuration: TimeInterval { phases.reduce(0) { $0 + $1.duration } }

    static let resonant = BreathTechnique(
        id: "resonant",
        name: "Resonant Breathing",
        subtitle: "The Perfect Breath",
        description: "Inhale and exhale at 5.5 seconds each — the rate that synchronizes heart, lungs, and circulation for peak efficiency. Discovered independently by prayer traditions worldwide.",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 5.5, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 5.5, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Daily wellness, heart rate variability, calm focus"
    )

    static let boxBreathing = BreathTechnique(
        id: "box",
        name: "Box Breathing",
        subtitle: "Navy SEAL Focus",
        description: "Four equal phases — inhale, hold, exhale, hold — creating a 'box' pattern. Calms without sedating and focuses without winding you up. Used by elite military operators.",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold1", name: "Hold", duration: 4.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 4.0, phaseType: .exhale),
            BreathPhase(id: "hold2", name: "Hold", duration: 4.0, phaseType: .hold)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Acute stress, pre-performance focus, concentration"
    )

    static let fourSevenEight = BreathTechnique(
        id: "478",
        name: "4-7-8 Breathing",
        subtitle: "Natural Tranquilizer",
        description: "Dr. Andrew Weil's technique rooted in ancient pranayama. The exhale is twice the inhale length, maximally activating the vagus nerve. A natural tranquilizer for the nervous system.",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 7.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8.0, phaseType: .exhale)
        ],
        defaultDurationMinutes: 3,
        difficulty: .intermediate,
        bestFor: "Sleep preparation, anxiety relief, winding down"
    )

    static let cyclicSighing = BreathTechnique(
        id: "cyclic_sigh",
        name: "Cyclic Sighing",
        subtitle: "Stanford Stress Reset",
        description: "Based on the physiological sigh your body performs naturally. A double inhale fully inflates the lungs, then a long exhale offloads CO₂. Stanford proved 5 minutes beats meditation for mood.",
        phases: [
            BreathPhase(id: "inhale1", name: "Inhale", duration: 2.0, phaseType: .inhale),
            BreathPhase(id: "inhale2", name: "Top Up", duration: 2.0, phaseType: .inhaleTopUp),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8.0, phaseType: .exhale)
        ],
        defaultDurationMinutes: 5,
        difficulty: .beginner,
        bestFor: "Quick stress relief, mood improvement, calm"
    )

    static let allTechniques: [BreathTechnique] = [.resonant, .boxBreathing, .fourSevenEight, .cyclicSighing]
}
