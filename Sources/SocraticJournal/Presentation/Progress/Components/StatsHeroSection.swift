// StatsHeroSection.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Three stat cards in horizontal layout showing total minutes, sessions, and streak
struct StatsHeroSection: View {
    let totalMinutes: String
    let totalSessions: Int
    let streak: Int

    var body: some View {
        HStack(spacing: AppSpacing.cardGap) {
            statCard(
                value: totalMinutes,
                label: "minutes",
                backgroundColor: AppColors.cardTeal
            )

            statCard(
                value: "\(totalSessions)",
                label: "sessions",
                backgroundColor: AppColors.cardYellow
            )

            statCard(
                value: "\(streak)",
                label: "day streak",
                backgroundColor: AppColors.surfaceElevated
            )
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private func statCard(value: String, label: String, backgroundColor: Color) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
    }
}

#Preview("Stats Hero Section") {
    VStack {
        StatsHeroSection(totalMinutes: "42", totalSessions: 12, streak: 5)
        StatsHeroSection(totalMinutes: "0", totalSessions: 0, streak: 0)
    }
    .padding(.vertical)
    .background(AppColors.background)
}
#endif
