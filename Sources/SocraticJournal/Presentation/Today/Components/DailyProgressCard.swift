// DailyProgressCard.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Hero section showing time-based greeting, streak number, and daily progress ring
struct DailyProgressCard: View {
    let greeting: String
    let streak: Int
    let todayMinutes: Double
    let dailyGoalMinutes: Int

    private var progress: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(todayMinutes / Double(dailyGoalMinutes), 1.0)
    }

    private var minutesDisplay: String {
        let rounded = Int(todayMinutes.rounded())
        return "\(rounded) of \(dailyGoalMinutes) min"
    }

    private var streakLabel: String {
        streak > 0 ? "day streak" : "start your streak"
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Greeting
            Text(greeting)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            // Streak number
            Text("\(streak)")
                .font(AppTypography.stat)
                .foregroundStyle(AppColors.accent)

            Text(streakLabel)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            // Progress ring
            GeometricRing(
                progress: progress,
                size: 120,
                lineWidth: 16
            )
            .padding(.top, AppSpacing.xs)

            // Minutes caption
            Text(minutesDisplay)
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

#Preview("Daily Progress Card") {
    VStack {
        DailyProgressCard(greeting: "good morning", streak: 7, todayMinutes: 3.2, dailyGoalMinutes: 5)
        DailyProgressCard(greeting: "good evening", streak: 0, todayMinutes: 0, dailyGoalMinutes: 5)
    }
    .background(AppColors.background)
}
#endif
