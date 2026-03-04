// BreathPattern.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Types of breath phases in a pattern
public enum BreathPhaseType: String, Codable, Sendable {
    case inhale
    case hold
    case exhale
    case inhaleTopUp
}

/// A single phase within a breath pattern
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

/// Difficulty level for a breath pattern
public enum BreathDifficulty: String, Codable, Sendable {
    case beginner
    case intermediate
    case advanced
}

/// A breathing pattern with phases, metadata, and scientific context
public struct BreathPattern: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let timing: String
    public let phases: [BreathPhase]
    public let bpm: String
    public let tag: String
    public let tagColorHex: String
    public let importance: String
    public let bestFor: String
    public let difficulty: BreathDifficulty

    /// Total duration of one breath cycle
    public var cycleDuration: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }

    // MARK: - The 8 Patterns

    public static let resonance = BreathPattern(
        id: "resonance",
        name: "Resonance",
        timing: "5.5 · 5.5",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 5.5, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 5.5, phaseType: .exhale),
        ],
        bpm: "5.5 BPM",
        tag: "HRV · Default",
        tagColorHex: "2D5F5D",
        importance: "The headline finding from James Nestor. Breathing at exactly 5.5 breaths per minute synchronises your heart rate variability to its resonance frequency — the point at which the baroreflex and cardiac vagal tone are perfectly in phase. The effect on HRV, blood pressure, and anxiety is measurable within a single session.",
        bestFor: "Morning practice · Daily baseline",
        difficulty: .beginner
    )

    public static let coherent = BreathPattern(
        id: "coherent",
        name: "Coherent",
        timing: "6 · 6",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 6.0, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 6.0, phaseType: .exhale),
        ],
        bpm: "5 BPM",
        tag: "Beginner · Calm",
        tagColorHex: "2D5F5D",
        importance: "Developed by Stephen Elliott, coherent breathing produces the same resonance effect through a slightly longer, rounder cycle. Easier to learn than 5.5 because the count is whole numbers. Regular practice rebuilds the parasympathetic nervous system and lowers resting heart rate over weeks.",
        bestFor: "First week of practice · Wind-down",
        difficulty: .beginner
    )

    public static let box = BreathPattern(
        id: "box",
        name: "Box",
        timing: "4 · 4 · 4 · 4",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold1", name: "Hold", duration: 4.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 4.0, phaseType: .exhale),
            BreathPhase(id: "hold2", name: "Hold", duration: 4.0, phaseType: .hold),
        ],
        bpm: "3.75 BPM",
        tag: "Focus · Stress",
        tagColorHex: "C4502A",
        importance: "Used by Navy SEALs under combat stress. The equal-phase structure forces the nervous system out of fight-or-flight by demanding total attentional control. The double hold phases build CO₂ tolerance gently over time, which is the key mechanism for reducing anxiety about breathing itself.",
        bestFor: "Pre-work · Before a difficult conversation",
        difficulty: .beginner
    )

    public static let fourSevenEight = BreathPattern(
        id: "478",
        name: "4-7-8",
        timing: "4 · 7 · 8",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 7.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8.0, phaseType: .exhale),
        ],
        bpm: "3.2 BPM",
        tag: "Sleep · Parasympathetic",
        tagColorHex: "6B4C8A",
        importance: "Dr Andrew Weil's signature pattern. The extended 7-second hold pressurises oxygen into the bloodstream, and the 8-second exhale activates the vagus nerve more than any other phase ratio. Consistent evening use measurably shortens sleep onset time. Do not use while driving — it is genuinely sedating.",
        bestFor: "Evening · Pre-sleep · Anxiety spike",
        difficulty: .intermediate
    )

    public static let physiologicalSigh = BreathPattern(
        id: "physiological",
        name: "Physiological Sigh",
        timing: "2+1 · · 8",
        phases: [
            BreathPhase(id: "inhale1", name: "Inhale", duration: 2.0, phaseType: .inhale),
            BreathPhase(id: "inhale2", name: "Top Up", duration: 1.0, phaseType: .inhaleTopUp),
            BreathPhase(id: "hold", name: "Hold", duration: 0.5, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 8.0, phaseType: .exhale),
        ],
        bpm: "~5 BPM",
        tag: "Fastest reset",
        tagColorHex: "C4502A",
        importance: "Discovered by Stanford neuroscientist Andrew Huberman. A double inhale through the nose (first breath fully inflates alveoli, second sniff pops any collapsed ones) followed by a long exhale. This is the fastest known method to reduce physiological arousal — a single sigh can lower cortisol within 30 seconds. Your body does this spontaneously when you cry.",
        bestFor: "Immediate stress relief · Single-breath rescue",
        difficulty: .beginner
    )

    public static let buteyko = BreathPattern(
        id: "buteyko",
        name: "Buteyko Reduced",
        timing: "3 · 3 · 3",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 3.0, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 3.0, phaseType: .exhale),
            BreathPhase(id: "hold", name: "Hold", duration: 3.0, phaseType: .hold),
        ],
        bpm: "~6 BPM",
        tag: "CO₂ · Asthma",
        tagColorHex: "7A6030",
        importance: "Konstantin Buteyko's insight was counter-intuitive: modern humans over-breathe, not under-breathe. Chronic hyperventilation depletes CO₂, which paradoxically causes oxygen to bind tighter to haemoglobin (Bohr Effect). Reduced breathing retrains your chemoreceptors to tolerate higher CO₂, which is the actual trigger for the urge to breathe. This pattern is foundational for asthma and anxiety.",
        bestFor: "Chronic mouth-breathers · Building CO₂ tolerance",
        difficulty: .intermediate
    )

    public static let tummo = BreathPattern(
        id: "wim",
        name: "Tummo / Power",
        timing: "30× + hold",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 2.0, phaseType: .inhale),
            BreathPhase(id: "exhale", name: "Exhale", duration: 1.5, phaseType: .exhale),
        ],
        bpm: "20+ BPM",
        tag: "Advanced · Energy",
        tagColorHex: "C4502A",
        importance: "Based on Tibetan Tummo practice, popularised by Wim Hof. Rapid, forceful breathing for 30 cycles deliberately induces hypocapnia (CO₂ depletion), followed by a breath-hold. This creates an alkaline blood shift, floods the body with adrenaline, and temporarily suppresses the innate immune response. The scientific evidence is genuine but so are the risks — never in water, never while driving.",
        bestFor: "Morning energy · Cold exposure · Advanced only",
        difficulty: .advanced
    )

    public static let alternateNostril = BreathPattern(
        id: "nadi",
        name: "Alternate Nostril",
        timing: "4 · 4 · 4 per side",
        phases: [
            BreathPhase(id: "inhale", name: "Inhale", duration: 4.0, phaseType: .inhale),
            BreathPhase(id: "hold", name: "Hold", duration: 4.0, phaseType: .hold),
            BreathPhase(id: "exhale", name: "Exhale", duration: 4.0, phaseType: .exhale),
        ],
        bpm: "~5 BPM",
        tag: "Balance · Ancient",
        tagColorHex: "5A6E3D",
        importance: "Nadi Shodhana from the Hatha Yoga Pradipika, now validated neurologically. Alternating which nostril you breathe through directly modulates which brain hemisphere is dominant (right nostril activates left hemisphere and vice versa). The nasal cycle connection Nestor describes is real — this practice manually overrides it to achieve bilateral balance. Good for creative work and pre-meditation.",
        bestFor: "Pre-meditation · Mental clarity · Balance",
        difficulty: .intermediate
    )

    /// All 8 patterns in recommended display order
    public static let allPatterns: [BreathPattern] = [
        .resonance, .coherent, .box, .fourSevenEight,
        .physiologicalSigh, .buteyko, .tummo, .alternateNostril,
    ]
}
