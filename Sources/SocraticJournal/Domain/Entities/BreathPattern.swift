// BreathPattern.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation
import SwiftUI

enum BreathPhaseType: String, Codable, Sendable {
    case inhale, hold, exhale
}

struct BreathPhase: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let duration: TimeInterval
    let phaseType: BreathPhaseType
}

struct BreathPattern: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let timing: String
    let phases: [BreathPhase]
    let bpm: String
    let tag: String
    let tagColorHex: String
    let importance: String
    let best: String

    var cycleDuration: TimeInterval { phases.reduce(0) { $0 + $1.duration } }
}

// MARK: - All 8 Patterns

extension BreathPattern {
    static let resonance = BreathPattern(
        id: "resonance",
        name: "Resonance",
        timing: "5.5 · 5.5",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 5.5, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 5.5, phaseType: .exhale)
        ],
        bpm: "5.5 BPM",
        tag: "HRV · Default",
        tagColorHex: "2D5F5D",
        importance: "The headline finding from James Nestor. Breathing at exactly 5.5 breaths per minute synchronises your heart rate variability to its resonance frequency \u{2014} the point at which the baroreflex and cardiac vagal tone are perfectly in phase. The effect on HRV, blood pressure, and anxiety is measurable within a single session.",
        best: "Morning practice · Daily baseline"
    )

    static let coherent = BreathPattern(
        id: "coherent",
        name: "Coherent",
        timing: "6 · 6",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 6, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 6, phaseType: .exhale)
        ],
        bpm: "5 BPM",
        tag: "Beginner · Calm",
        tagColorHex: "2D5F5D",
        importance: "Developed by Stephen Elliott, coherent breathing produces the same resonance effect through a slightly longer, rounder cycle. Easier to learn than 5.5 because the count is whole numbers. Regular practice rebuilds the parasympathetic nervous system and lowers resting heart rate over weeks.",
        best: "First week of practice · Wind-down"
    )

    static let box = BreathPattern(
        id: "box",
        name: "Box",
        timing: "4 · 4 · 4 · 4",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4, phaseType: .inhale),
            BreathPhase(id: "hold1", name: "Hold", duration: 4, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 4, phaseType: .exhale),
            BreathPhase(id: "hold2", name: "Hold", duration: 4, phaseType: .hold)
        ],
        bpm: "3.75 BPM",
        tag: "Focus · Stress",
        tagColorHex: "C4502A",
        importance: "Used by Navy SEALs under combat stress. The equal-phase structure forces the nervous system out of fight-or-flight by demanding total attentional control. The double hold phases build CO\u{2082} tolerance gently over time, which is the key mechanism for reducing anxiety about breathing itself.",
        best: "Pre-work · Before a difficult conversation"
    )

    static let fourSevenEight = BreathPattern(
        id: "478",
        name: "4-7-8",
        timing: "4 · 7 · 8",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 7, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8, phaseType: .exhale)
        ],
        bpm: "3.2 BPM",
        tag: "Sleep · Parasympathetic",
        tagColorHex: "6B4C8A",
        importance: "Dr Andrew Weil\u{2019}s signature pattern. The extended 7-second hold pressurises oxygen into the bloodstream, and the 8-second exhale activates the vagus nerve more than any other phase ratio. Consistent evening use measurably shortens sleep onset time. Do not use while driving \u{2014} it is genuinely sedating.",
        best: "Evening · Pre-sleep · Anxiety spike"
    )

    static let physiologicalSigh = BreathPattern(
        id: "physiological",
        name: "Physiological Sigh",
        timing: "2+1 · · 8",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 3, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 0.5, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8, phaseType: .exhale)
        ],
        bpm: "~5 BPM",
        tag: "Fastest reset",
        tagColorHex: "C4502A",
        importance: "Discovered by Stanford neuroscientist Andrew Huberman. A double inhale through the nose (first breath fully inflates alveoli, second sniff pops any collapsed ones) followed by a long exhale. This is the fastest known method to reduce physiological arousal \u{2014} a single sigh can lower cortisol within 30 seconds. Your body does this spontaneously when you cry.",
        best: "Immediate stress relief · Single-breath rescue"
    )

    static let buteyko = BreathPattern(
        id: "buteyko",
        name: "Buteyko Reduced",
        timing: "3 · 3 · 3",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 3, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 3, phaseType: .exhale),
            BreathPhase(id: "hold", name: "Hold", duration: 3, phaseType: .hold)
        ],
        bpm: "~6 BPM",
        tag: "CO\u{2082} · Asthma",
        tagColorHex: "7A6030",
        importance: "Konstantin Buteyko\u{2019}s insight was counter-intuitive: modern humans over-breathe, not under-breathe. Chronic hyperventilation depletes CO\u{2082}, which paradoxically causes oxygen to bind tighter to haemoglobin (Bohr Effect). Reduced breathing retrains your chemoreceptors to tolerate higher CO\u{2082}, which is the actual trigger for the urge to breathe. This pattern is foundational for asthma and anxiety.",
        best: "Chronic mouth-breathers · Building CO\u{2082} tolerance"
    )

    static let tummo = BreathPattern(
        id: "wim",
        name: "Tummo / Power",
        timing: "30\u{00D7} + hold",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 2, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 1.5, phaseType: .exhale)
        ],
        bpm: "20+ BPM",
        tag: "Advanced · Energy",
        tagColorHex: "C4502A",
        importance: "Based on Tibetan Tummo practice, popularised by Wim Hof. Rapid, forceful breathing for 30 cycles deliberately induces hypocapnia (CO\u{2082} depletion), followed by a breath-hold. This creates an alkaline blood shift, floods the body with adrenaline, and temporarily suppresses the innate immune response. The scientific evidence is genuine but so are the risks \u{2014} never in water, never while driving.",
        best: "Morning energy · Cold exposure · Advanced only"
    )

    static let alternateNostril = BreathPattern(
        id: "nadi",
        name: "Alternate Nostril",
        timing: "4 · 4 · 4 per side",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 4, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 4, phaseType: .exhale)
        ],
        bpm: "~5 BPM",
        tag: "Balance · Ancient",
        tagColorHex: "5A6E3D",
        importance: "Nadi Shodhana from the Hatha Yoga Pradipika, now validated neurologically. Alternating which nostril you breathe through directly modulates which brain hemisphere is dominant (right nostril activates left hemisphere and vice versa). The nasal cycle connection Nestor describes is real \u{2014} this practice manually overrides it to achieve bilateral balance. Good for creative work and pre-meditation.",
        best: "Pre-meditation · Mental clarity · Balance"
    )

    static let allPatterns: [BreathPattern] = [
        .resonance, .coherent, .box, .fourSevenEight,
        .physiologicalSigh, .buteyko, .tummo, .alternateNostril
    ]
}
