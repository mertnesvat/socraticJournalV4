// DailyProgressCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Shows total minutes, session count, and progress toward daily goal
struct DailyProgressCard: View {
    let totalMinutes: Double
    let sessionsCount: Int
    let goalProgress: Double
    let dailyGoalMinutes: Int

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Big stat
            Text("\(Int(totalMinutes))")
                .font(AppTypography.statLarge)
                .foregroundStyle(AppColors.accent)

            Text("minutes today")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.surfaceElevated)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.accent)
                        .frame(width: geometry.size.width * goalProgress, height: 6)
                }
            }
            .frame(height: 6)

            // Subtext
            HStack {
                if sessionsCount > 0 {
                    Text("\(sessionsCount) \(sessionsCount == 1 ? "session" : "sessions")")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                } else {
                    Text("Start your first session")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textTertiary)
                }

                Spacer()

                Text("Goal: \(dailyGoalMinutes) min")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.cardPadding)
        .background(AppColors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }
}
#endif
