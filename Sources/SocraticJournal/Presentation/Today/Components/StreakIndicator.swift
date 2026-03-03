// StreakIndicator.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the user's consecutive day streak
struct StreakIndicator: View {
    let streak: Int

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: streak > 0 ? "flame.fill" : "flame")
                .foregroundStyle(streak > 0 ? AppColors.accent : AppColors.textTertiary)

            if streak > 0 {
                Text("\(streak) day streak")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                Text("Start your streak today")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
}
#endif
