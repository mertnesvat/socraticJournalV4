// StreakBadge.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the user's current question streak — editorial left-aligned, no capsule
public struct StreakBadge: View {
    let streak: QuestionStreak

    public init(streak: QuestionStreak) {
        self.streak = streak
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(streak.currentStreak)")
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.textPrimary)

            Text("day streak")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(streak: QuestionStreak(
            userId: "preview",
            currentStreak: 3,
            longestStreak: 5
        ))

        StreakBadge(streak: QuestionStreak(
            userId: "preview",
            currentStreak: 12,
            longestStreak: 20
        ))
    }
    .padding(.horizontal, AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
