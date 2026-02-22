// StatsRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal stats row showing questions answered, streak days, and friends count
struct StatsRow: View {
    let questionsAnswered: Int
    let streakDays: Int
    let friendCount: Int

    var body: some View {
        HStack(spacing: 0) {
            statColumn(value: "\(questionsAnswered)", label: "Answered")

            verticalDivider

            statColumn(value: "\(streakDays)", label: "Day Streak", icon: "flame.fill")

            verticalDivider

            statColumn(value: "\(friendCount)", label: "Friends")
        }
        .padding(.vertical, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    private func statColumn(value: String, label: String, icon: String? = nil) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.orange)
                }
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(Color(uiColor: .separator))
            .frame(width: 1, height: 36)
    }
}

#Preview {
    StatsRow(questionsAnswered: 42, streakDays: 7, friendCount: 5)
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
}
#endif
