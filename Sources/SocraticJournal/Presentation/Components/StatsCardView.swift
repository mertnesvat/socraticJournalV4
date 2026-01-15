// StatsCardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays journal statistics summary
public struct StatsCardView: View {
    let stats: JournalStats

    public init(stats: JournalStats) {
        self.stats = stats
    }

    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Journey")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 0) {
                StatItem(
                    value: "\(stats.totalEntries)",
                    label: "Total",
                    icon: "book.closed.fill"
                )

                Divider()
                    .frame(height: 40)

                StatItem(
                    value: "\(stats.currentStreak)",
                    label: "Streak",
                    icon: "flame.fill"
                )

                Divider()
                    .frame(height: 40)

                StatItem(
                    value: "\(stats.longestStreak)",
                    label: "Best",
                    icon: "trophy.fill"
                )

                Divider()
                    .frame(height: 40)

                StatItem(
                    value: "\(stats.thisWeekEntries)",
                    label: "This Week",
                    icon: "calendar"
                )
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct StatItem: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatsCardView(stats: JournalStats(
        totalEntries: 42,
        currentStreak: 7,
        longestStreak: 14,
        thisWeekEntries: 5
    ))
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
