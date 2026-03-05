// MilestoneCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A card displaying a single milestone — unlocked or locked state
struct MilestoneCard: View {
    let milestone: Milestone

    private var milestoneColor: Color {
        Color(hex: milestone.colorHex)
    }

    private var borderColor: Color {
        milestone.isUnlocked ? milestoneColor : Color(hex: "D8D0C4")
    }

    private var iconColor: Color {
        milestone.isUnlocked ? milestoneColor : AppColors.textTertiary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Icon
            Image(systemName: milestone.iconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(height: 28)

            // Title
            Text(milestone.title)
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundStyle(
                    milestone.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary
                )
                .lineLimit(1)

            if milestone.isUnlocked {
                // Description
                Text(milestone.description)
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                // Unlock date
                if let date = milestone.unlockedAt {
                    Text(formattedDate(date))
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.textTertiary)
                }
            } else {
                // Locked placeholder
                Text("?")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: milestone.isUnlocked ? 1.5 : 1)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview("Milestone Cards") {
    let unlocked = Milestone(
        id: "first_breath",
        title: "First Breath",
        description: "Complete your first session",
        iconName: "wind",
        colorHex: "2D5F5D",
        isUnlocked: true,
        unlockedAt: Date()
    )
    let locked = Milestone(
        id: "century",
        title: "Century",
        description: "100 total minutes",
        iconName: "clock",
        colorHex: "2D5F5D",
        isUnlocked: false
    )

    HStack(spacing: 12) {
        MilestoneCard(milestone: unlocked)
        MilestoneCard(milestone: locked)
    }
    .padding()
    .background(AppColors.background)
}
#endif
