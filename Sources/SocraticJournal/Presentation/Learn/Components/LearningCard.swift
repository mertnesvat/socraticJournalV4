// LearningCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A single learning content card with category badge, title, and body
struct LearningCard: View {
    let bit: LearningBit
    let useElevatedBackground: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Category badge
            Text(bit.category.rawValue)
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textOnAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.accent))

            Text(bit.title)
                .font(AppTypography.headlineMedium)
                .foregroundStyle(AppColors.textPrimary)

            Text(bit.body)
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(useElevatedBackground ? AppColors.surfaceElevated : AppColors.surface)
        )
    }
}
#endif
