// SummaryStatsRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 3-column summary stats: total minutes, total sessions, average per day
struct SummaryStatsRow: View {
    let totalMinutes: Double
    let totalSessions: Int
    let averagePerDay: Double

    var body: some View {
        HStack(spacing: 0) {
            statColumn(value: String(format: "%.0f", totalMinutes), label: "minutes")

            HairlineDivider(axis: .vertical)
                .frame(height: 50)

            statColumn(value: "\(totalSessions)", label: "sessions")

            HairlineDivider(axis: .vertical)
                .frame(height: 50)

            statColumn(value: String(format: "%.1f", averagePerDay), label: "min/day")
        }
        .padding(.vertical, AppSpacing.md)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
#endif
