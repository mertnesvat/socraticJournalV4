// SpicyTakesSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Section displaying the user's most reacted-to voice answers — editorial card style
struct SpicyTakesSection: View {
    let takes: [(question: String, reactionCount: Int)]

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView("SPICY TAKES")

            VStack(spacing: AppSpacing.cardGap) {
                ForEach(Array(takes.enumerated()), id: \.offset) { _, take in
                    spicyTakeCard(question: take.question, reactions: take.reactionCount)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Subviews

    private func spicyTakeCard(question: String, reactions: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(question)
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.accent)

                Text("\(reactions) reactions")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.cardPadding)
        .background(AppColors.background)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SpicyTakesSection(takes: [
        (question: "Is it ever okay to go through your partner's phone?", reactionCount: 847),
        (question: "What's something you've never said out loud?", reactionCount: 632),
        (question: "If you could delete one app from everyone's phone?", reactionCount: 519)
    ])
    .background(AppColors.background)
}
#endif
