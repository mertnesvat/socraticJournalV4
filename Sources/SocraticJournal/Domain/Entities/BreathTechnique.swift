// BreathTechnique.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A named breathing pattern composed of phases
public struct BreathTechnique: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let description: String
    public let phases: [BreathPhase]
    public let scienceNote: String

    public var cycleDuration: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }

    public static func == (lhs: BreathTechnique, rhs: BreathTechnique) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Presets

    public static let resonance = BreathTechnique(
        id: "resonance",
        name: "Resonance Breathing",
        subtitle: "5.5s in \u{00B7} 5.5s out",
        description: "The optimal rhythm for HRV coherence, discovered independently by prayer traditions worldwide.",
        phases: [
            BreathPhase(id: "resonance-inhale", phaseType: .inhale, duration: 5.5),
            BreathPhase(id: "resonance-exhale", phaseType: .exhale, duration: 5.5)
        ],
        scienceNote: "~5.5 breaths per minute synchronises heart rate and breathing \u{2014} hitting the resonance frequency for maximum heart rate variability."
    )

    public static let coherent = BreathTechnique(
        id: "coherent",
        name: "Coherent Breathing",
        subtitle: "6s in \u{00B7} 6s out",
        description: "A slightly slower variation that maximises parasympathetic activation. Ideal for beginners.",
        phases: [
            BreathPhase(id: "coherent-inhale", phaseType: .inhale, duration: 6.0),
            BreathPhase(id: "coherent-exhale", phaseType: .exhale, duration: 6.0)
        ],
        scienceNote: "The equal ratio creates a calming symmetry. At 5 breaths per minute, this deepens the coherence effect for those comfortable with a slower pace."
    )

    public static let box = BreathTechnique(
        id: "box",
        name: "Box Breathing",
        subtitle: "4s \u{00B7} 4s \u{00B7} 4s \u{00B7} 4s",
        description: "Used by Navy SEALs for acute stress management. Four equal phases create a calming symmetry.",
        phases: [
            BreathPhase(id: "box-inhale", phaseType: .inhale, duration: 4.0),
            BreathPhase(id: "box-hold1", phaseType: .holdAfterInhale, duration: 4.0),
            BreathPhase(id: "box-exhale", phaseType: .exhale, duration: 4.0),
            BreathPhase(id: "box-hold2", phaseType: .holdAfterExhale, duration: 4.0)
        ],
        scienceNote: "Box breathing has a 'neutral energetic effect' \u{2014} it calms without sedating and focuses without winding you up."
    )

    public static let fourSevenEight = BreathTechnique(
        id: "478",
        name: "4-7-8 Relaxation",
        subtitle: "4s in \u{00B7} 7s hold \u{00B7} 8s out",
        description: "Dr Andrew Weil's sleep preparation technique. The extended exhale triggers deep relaxation.",
        phases: [
            BreathPhase(id: "478-inhale", phaseType: .inhale, duration: 4.0),
            BreathPhase(id: "478-hold", phaseType: .holdAfterInhale, duration: 7.0),
            BreathPhase(id: "478-exhale", phaseType: .exhale, duration: 8.0)
        ],
        scienceNote: "The exhale is twice the inhale length, maximally activating the vagus nerve. Dr Weil calls it 'a natural tranquiliser for the nervous system.'"
    )

    public static let allTechniques: [BreathTechnique] = [.resonance, .coherent, .box, .fourSevenEight]
}
