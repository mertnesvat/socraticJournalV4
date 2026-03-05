// MilestoneGridSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A 2-column grid displaying all milestones, unlocked first then locked
struct MilestoneGridSection: View {
    let milestones: [Milestone]

    private var sortedMilestones: [Milestone] {
        let unlocked = milestones.filter { $0.isUnlocked }
            .sorted { ($0.unlockedAt ?? .distantPast) < ($1.unlockedAt ?? .distantPast) }
        let locked = milestones.filter { !$0.isUnlocked }
        return unlocked + locked
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Milestones")

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(sortedMilestones) { milestone in
                    MilestoneCard(milestone: milestone)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.cardPadding)
        }
    }
}

#Preview("Milestone Grid") {
    ScrollView {
        MilestoneGridSection(milestones: Milestone.allMilestones.enumerated().map { index, milestone in
            var m = milestone
            if index < 3 {
                m.isUnlocked = true
                m.unlockedAt = Date().addingTimeInterval(Double(-index) * 86400)
            }
            return m
        })
    }
    .background(AppColors.background)
}
#endif
