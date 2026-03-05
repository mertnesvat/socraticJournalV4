// BreathInsight.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A short, scientifically grounded insight about breathing practice
public struct BreathInsight: Identifiable, Sendable {
    public let id: String
    public let text: String
    /// Pattern IDs this insight relates to. Empty means general/all patterns.
    public let relatedPatternIds: [String]

    public init(id: String, text: String, relatedPatternIds: [String] = []) {
        self.id = id
        self.text = text
        self.relatedPatternIds = relatedPatternIds
    }

    /// Whether this insight is general (applies to all patterns)
    public var isGeneral: Bool {
        relatedPatternIds.isEmpty
    }
}

// MARK: - Static Insight Library

extension BreathInsight {

    /// All 30 breath insights, inspired by breathing science and James Nestor's "Breath"
    public static let allInsights: [BreathInsight] = [

        // --- Resonance-specific ---
        BreathInsight(
            id: "insight_01",
            text: "Breathing at 5.5 breaths per minute maximizes heart rate variability and vagal tone -- the body's resonance frequency.",
            relatedPatternIds: ["resonance"]
        ),
        BreathInsight(
            id: "insight_02",
            text: "Gregorian monks, Buddhist chanters, and Hindu mantra reciters all converge on roughly 5.5 breaths per minute -- a coincidence across centuries.",
            relatedPatternIds: ["resonance", "coherent"]
        ),
        BreathInsight(
            id: "insight_03",
            text: "A single 10-minute resonance session can lower systolic blood pressure by 5-10 mmHg within minutes.",
            relatedPatternIds: ["resonance"]
        ),

        // --- Coherent-specific ---
        BreathInsight(
            id: "insight_04",
            text: "Coherent breathing at 5 breaths per minute rebuilds parasympathetic tone over weeks, measurably lowering resting heart rate.",
            relatedPatternIds: ["coherent"]
        ),
        BreathInsight(
            id: "insight_05",
            text: "Stephen Elliott found that equal inhale-exhale ratios with whole-number counts make breathwork accessible to complete beginners.",
            relatedPatternIds: ["coherent"]
        ),

        // --- Box Breathing ---
        BreathInsight(
            id: "insight_06",
            text: "Navy SEALs use Box Breathing before missions to lower cortisol by up to 25% and sharpen focus under pressure.",
            relatedPatternIds: ["box"]
        ),
        BreathInsight(
            id: "insight_07",
            text: "The equal-phase structure of Box Breathing forces total attentional control, which is why it disrupts anxious thought loops.",
            relatedPatternIds: ["box"]
        ),
        BreathInsight(
            id: "insight_08",
            text: "Breath holds in Box Breathing gently build CO2 tolerance -- the key mechanism for reducing panic about breathing itself.",
            relatedPatternIds: ["box", "buteyko"]
        ),

        // --- 4-7-8 ---
        BreathInsight(
            id: "insight_09",
            text: "Dr. Andrew Weil's 4-7-8 pattern is genuinely sedating. Consistent evening use measurably shortens sleep onset time.",
            relatedPatternIds: ["478"]
        ),
        BreathInsight(
            id: "insight_10",
            text: "The 7-second hold in 4-7-8 breathing pressurizes oxygen into the bloodstream, while the long exhale triggers deep vagal relaxation.",
            relatedPatternIds: ["478"]
        ),

        // --- Physiological Sigh ---
        BreathInsight(
            id: "insight_11",
            text: "A single physiological sigh can reduce cortisol within 30 seconds -- it is the fastest known method to lower arousal.",
            relatedPatternIds: ["physiological"]
        ),
        BreathInsight(
            id: "insight_12",
            text: "Your body performs physiological sighs spontaneously every five minutes to reinflate collapsed alveoli. The double inhale is not a technique -- it is biology.",
            relatedPatternIds: ["physiological"]
        ),
        BreathInsight(
            id: "insight_13",
            text: "Stanford's Huberman Lab showed that cyclic sighing outperforms meditation for real-time stress reduction in controlled trials.",
            relatedPatternIds: ["physiological"]
        ),

        // --- Buteyko ---
        BreathInsight(
            id: "insight_14",
            text: "Modern humans chronically over-breathe. Buteyko's insight: the urge to breathe is triggered by CO2, not lack of oxygen.",
            relatedPatternIds: ["buteyko"]
        ),
        BreathInsight(
            id: "insight_15",
            text: "The Bohr Effect: when CO2 drops too low, hemoglobin grips oxygen tighter, paradoxically starving tissues of the oxygen they need.",
            relatedPatternIds: ["buteyko"]
        ),

        // --- Tummo / Wim Hof ---
        BreathInsight(
            id: "insight_16",
            text: "Tibetan monks practicing Tummo can raise their skin temperature by 8 degrees Celsius through controlled hyperventilation and visualization.",
            relatedPatternIds: ["wim"]
        ),
        BreathInsight(
            id: "insight_17",
            text: "Wim Hof practitioners showed voluntary influence over their innate immune response -- previously thought impossible by immunologists.",
            relatedPatternIds: ["wim"]
        ),

        // --- Alternate Nostril ---
        BreathInsight(
            id: "insight_18",
            text: "Your nostrils alternate dominance every 90 minutes. Nadi Shodhana manually overrides this cycle to balance both brain hemispheres.",
            relatedPatternIds: ["nadi"]
        ),
        BreathInsight(
            id: "insight_19",
            text: "Right-nostril breathing activates the sympathetic system; left-nostril breathing activates the parasympathetic. Alternating balances both.",
            relatedPatternIds: ["nadi"]
        ),

        // --- General Insights (apply to all patterns) ---
        BreathInsight(
            id: "insight_20",
            text: "Humming increases nasal nitric oxide production by 15x, boosting oxygen absorption and antimicrobial defense in the sinuses."
        ),
        BreathInsight(
            id: "insight_21",
            text: "The ancient yogis called breath 'prana' -- the vital life force that connects mind and body across every tradition."
        ),
        BreathInsight(
            id: "insight_22",
            text: "Nose breathing filters, warms, and humidifies air while releasing nitric oxide -- a vasodilator that improves oxygen uptake by 18%."
        ),
        BreathInsight(
            id: "insight_23",
            text: "Humans have lost 12% of lung capacity over the last 200,000 years as our faces shortened and airways narrowed."
        ),
        BreathInsight(
            id: "insight_24",
            text: "Slow, nasal breathing activates the lower lobes of the lungs, where the richest blood supply and most efficient gas exchange occur."
        ),
        BreathInsight(
            id: "insight_25",
            text: "The diaphragm is the only skeletal muscle that works involuntarily and voluntarily -- the bridge between conscious and unconscious life."
        ),
        BreathInsight(
            id: "insight_26",
            text: "Just 5 minutes of structured breathing daily is enough to measurably shift autonomic nervous system balance within two weeks."
        ),
        BreathInsight(
            id: "insight_27",
            text: "Every exhale is a micro-dose of relaxation. The longer you exhale relative to inhale, the stronger the parasympathetic signal."
        ),
        BreathInsight(
            id: "insight_28",
            text: "Mouth breathing during sleep reduces oxygen saturation by up to 10%, fragments sleep architecture, and raises morning cortisol."
        ),
        BreathInsight(
            id: "insight_29",
            text: "The vagus nerve -- the longest cranial nerve -- is directly stimulated by slow, deep exhalations, calming heart rate within seconds."
        ),
        BreathInsight(
            id: "insight_30",
            text: "Carbon dioxide is not just a waste gas. It is essential for oxygen delivery, pH balance, and smooth muscle relaxation throughout the body."
        ),
    ]
}
