// InsightCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Motivational insight card with pattern-specific text
public struct InsightCard: View {
    let patternId: String

    public var body: some View {
        Text(insight(for: patternId))
            .font(.system(size: 13, design: .serif))
            .italic()
            .foregroundStyle(AppColors.textPrimary)
            .lineSpacing(13 * 0.75)
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.accent.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.accent.opacity(0.12), lineWidth: 1)
            )
    }

    static func insight(for patternId: String) -> String {
        switch patternId {
        case "resonance":
            return "Each session at 5.5 breaths per minute strengthens the baroreflex — the body's master blood pressure regulator. The effect is cumulative."
        case "coherent":
            return "Stephen Elliott's research shows coherent breathing rebuilds parasympathetic tone over weeks. You're rewiring your resting state."
        case "box":
            return "The Navy SEALs use box breathing because it works under the worst conditions. What you just practiced is battle-tested composure."
        case "478":
            return "Dr Weil calls this the natural tranquiliser of the nervous system. Consistent evening practice measurably shortens sleep onset."
        case "physiological":
            return "Stanford's Andrew Huberman proved a single double-inhale sigh can lower cortisol in 30 seconds. You just did many."
        case "buteyko":
            return "Every session of reduced breathing recalibrates your CO₂ chemoreceptors. The 'air hunger' reflex gets quieter over time."
        case "wim":
            return "The alkaline blood shift you just created temporarily suppresses inflammatory markers. Wim Hof's ice baths are built on this."
        case "nadi":
            return "Nadi Shodhana creates bilateral brain hemisphere balance. Ancient yogis knew what neuroscience confirmed centuries later."
        default:
            return "Every breath practice strengthens the connection between your mind and body. Consistency is what creates lasting change."
        }
    }

    private func insight(for patternId: String) -> String {
        Self.insight(for: patternId)
    }
}
#endif
