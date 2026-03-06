// WidgetBreathPattern.swift
// RumiWidget
// Copyright 2024 StudioNext

import Foundation

/// Lightweight mirror of BreathPattern for use in the widget extension.
/// Duplicated here because the SocraticJournal SPM target has Firebase
/// dependencies that are not available in a WidgetKit extension target.
struct WidgetBreathPattern {
    let id: String
    let name: String
    let timing: String
    let tag: String
    let tagColorHex: String
    let bestFor: String

    // MARK: - The 8 Patterns (mirrors BreathPattern.allPatterns order)

    static let resonance = WidgetBreathPattern(
        id: "resonance",
        name: "Resonance",
        timing: "5.5 · 5.5",
        tag: "HRV · Default",
        tagColorHex: "2D5F5D",
        bestFor: "Morning practice · Daily baseline"
    )

    static let coherent = WidgetBreathPattern(
        id: "coherent",
        name: "Coherent",
        timing: "6 · 6",
        tag: "Beginner · Calm",
        tagColorHex: "2D5F5D",
        bestFor: "First week of practice · Wind-down"
    )

    static let box = WidgetBreathPattern(
        id: "box",
        name: "Box",
        timing: "4 · 4 · 4 · 4",
        tag: "Focus · Stress",
        tagColorHex: "C4502A",
        bestFor: "Pre-work · Before a difficult conversation"
    )

    static let fourSevenEight = WidgetBreathPattern(
        id: "478",
        name: "4-7-8",
        timing: "4 · 7 · 8",
        tag: "Sleep · Parasympathetic",
        tagColorHex: "6B4C8A",
        bestFor: "Evening · Pre-sleep · Anxiety spike"
    )

    static let physiologicalSigh = WidgetBreathPattern(
        id: "physiological",
        name: "Physiological Sigh",
        timing: "2+1 · · 8",
        tag: "Fastest reset",
        tagColorHex: "C4502A",
        bestFor: "Immediate stress relief · Single-breath rescue"
    )

    static let buteyko = WidgetBreathPattern(
        id: "buteyko",
        name: "Buteyko Reduced",
        timing: "3 · 3 · 3",
        tag: "CO₂ · Asthma",
        tagColorHex: "7A6030",
        bestFor: "Chronic mouth-breathers · Building CO₂ tolerance"
    )

    static let tummo = WidgetBreathPattern(
        id: "wim",
        name: "Tummo / Power",
        timing: "30× + hold",
        tag: "Advanced · Energy",
        tagColorHex: "C4502A",
        bestFor: "Morning energy · Cold exposure · Advanced only"
    )

    static let alternateNostril = WidgetBreathPattern(
        id: "nadi",
        name: "Alternate Nostril",
        timing: "4 · 4 · 4 per side",
        tag: "Balance · Ancient",
        tagColorHex: "5A6E3D",
        bestFor: "Pre-meditation · Mental clarity · Balance"
    )

    static let allPatterns: [WidgetBreathPattern] = [
        .resonance, .coherent, .box, .fourSevenEight,
        .physiologicalSigh, .buteyko, .tummo, .alternateNostril
    ]

    static func find(id: String?) -> WidgetBreathPattern? {
        guard let id else { return nil }
        return allPatterns.first { $0.id == id }
    }
}
