// SuggestedPatternCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card displaying the time-of-day recommended breathing pattern
public struct SuggestedPatternCard: View {
    let recommendation: PatternRecommendation
    let onTap: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section header
            Text("SUGGESTED FOR YOU")
                .font(.system(size: 11))
                .tracking(1.2)
                .foregroundStyle(AppColors.textTertiary)

            // Card
            Button(action: onTap) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("RIGHT NOW")
                            .font(.system(size: 10))
                            .tracking(1.2)
                            .foregroundStyle(AppColors.accent)

                        Text(recommendation.pattern?.name ?? recommendation.patternId)
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.accent)

                        Text(recommendation.reason)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Text("\(recommendation.suggestedDurationMinutes) min")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.accent)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.accent.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.accent.opacity(0.12), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.cardPadding)
    }
}

#Preview {
    SuggestedPatternCard(
        recommendation: PatternRecommendationService.recommend(),
        onTap: {}
    )
    .background(AppColors.background)
}
#endif
