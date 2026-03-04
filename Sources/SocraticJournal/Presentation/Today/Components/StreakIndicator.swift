// StreakIndicator.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A small streak badge for use in various contexts
struct StreakIndicator: View {
    let streak: Int

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(streak > 0 ? AppColors.accent : AppColors.textTertiary)

            Text("\(streak)")
                .font(AppTypography.captionBold)
                .foregroundStyle(streak > 0 ? AppColors.accent : AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xxs)
        .background(
            Capsule()
                .fill(streak > 0 ? AppColors.accent.opacity(0.12) : AppColors.surfaceElevated)
        )
    }
}

#Preview("Streak Indicator") {
    HStack(spacing: 16) {
        StreakIndicator(streak: 0)
        StreakIndicator(streak: 3)
        StreakIndicator(streak: 14)
    }
    .padding()
    .background(AppColors.background)
}
#endif
