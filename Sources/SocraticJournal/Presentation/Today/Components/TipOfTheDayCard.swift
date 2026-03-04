// TipOfTheDayCard.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A subtle card showing a breathing science tip, rotating daily
struct TipOfTheDayCard: View {
    static let tips: [String] = [
        "Nasal breathing filters, warms, and humidifies air before it reaches your lungs.",
        "Slow breathing at 5-6 breaths per minute maximises heart rate variability.",
        "The diaphragm is the most efficient breathing muscle and also massages your internal organs.",
        "Extended exhales activate the parasympathetic nervous system, lowering heart rate and blood pressure.",
        "Breathing through your nose releases nitric oxide, which helps dilate blood vessels.",
        "Box breathing is used by Navy SEALs to manage acute stress in high-pressure situations.",
        "Your breathing pattern directly influences your emotional state through the vagus nerve.",
        "Coherent breathing at 5 breaths per minute creates maximum heart-brain synchronisation.",
        "Most adults breathe 15-20 times per minute, but optimal relaxed breathing is 5-6 times.",
        "The 4-7-8 technique was developed by Dr Andrew Weil as a natural tranquiliser.",
        "Breathing exercises can reduce cortisol levels by up to 25% in just 5 minutes.",
        "Resonance frequency breathing improves baroreflex sensitivity, a marker of cardiac health.",
        "Ancient yogic pranayama techniques align closely with modern respiratory science.",
        "Even 3 minutes of focused breathing can shift your nervous system from fight-or-flight to rest-and-digest.",
        "Consistent daily breathwork practice has been shown to improve sleep quality within two weeks.",
        "Your lungs process around 11,000 litres of air every day."
    ]

    private var todayTip: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % Self.tips.count
        return Self.tips[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("DID YOU KNOW?")
                .font(AppTypography.sectionHeader)
                .tracking(AppTypography.sectionHeaderTracking)
                .foregroundStyle(AppColors.textTertiary)

            Text(todayTip)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surfaceElevated)
        )
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

#Preview("Tip of the Day") {
    TipOfTheDayCard()
        .padding(.vertical)
        .background(AppColors.background)
}
#endif
