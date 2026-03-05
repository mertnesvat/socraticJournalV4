// ProgramCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A single program card displayed in the program browser
struct ProgramCard: View {
    let program: BreathProgram

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Tag badge
                    Text(program.difficultyLabel.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: program.tagColorHex))
                        )

                    // Title
                    Text(program.title)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    // Subtitle
                    Text(program.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)

                    // Duration and difficulty
                    Text("\(program.durationDays) days \u{00B7} \(program.difficultyLabel)")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ProgramCard(program: .nasalBreathingReset)
        HairlineDivider()
        ProgramCard(program: .stressResilience)
        HairlineDivider()
        ProgramCard(program: .breathMastery)
        HairlineDivider()
        ProgramCard(program: .eveningWindDown)
    }
    .background(AppColors.background)
}
#endif
