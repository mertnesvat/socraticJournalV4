// StatsRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Three stacked stat cards with contrasting colors — bold editorial design
struct StatsRow: View {
    let questionsAnswered: Int
    let streakDays: Int
    let friendCount: Int

    var body: some View {
        VStack(spacing: AppSpacing.cardGap) {
            StatCard(
                label: "Questions\nAnswered",
                value: "\(questionsAnswered)",
                backgroundColor: AppColors.cardTeal
            )

            StatCard(
                label: "Day\nStreak",
                value: "\(streakDays)",
                backgroundColor: AppColors.cardYellow
            )

            StatCard(
                label: "Friends",
                value: "\(friendCount)",
                backgroundColor: AppColors.cardDark,
                textColor: .white
            )
        }
    }
}

#Preview {
    StatsRow(questionsAnswered: 42, streakDays: 7, friendCount: 5)
        .padding(AppSpacing.screenPadding)
        .background(AppColors.background)
}
#endif
