// CircleStreakView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays circle streak information in a warm, non-gamified manner.
/// Supports both compact (for list rows) and expanded (for detail view) modes.
struct CircleStreakView: View {
    let currentStreak: Int
    let longestStreak: Int
    let isCompact: Bool

    init(currentStreak: Int, longestStreak: Int, isCompact: Bool = false) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.isCompact = isCompact
    }

    var body: some View {
        if isCompact {
            compactView
        } else {
            expandedView
        }
    }

    // MARK: - Compact View (for CircleListView rows)

    private var compactView: some View {
        Group {
            if currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(CircleTheme.warmAmber)
                    Text("\(currentStreak)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CircleTheme.warmAmber)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    CircleTheme.warmAmber.opacity(0.12),
                    in: Capsule()
                )
            }
        }
    }

    // MARK: - Expanded View (for CircleDetailView)

    private var expandedView: some View {
        VStack(spacing: 12) {
            // Current streak
            HStack(spacing: 10) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(streakColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: streakIcon)
                        .font(.system(size: 20))
                        .foregroundStyle(streakColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(streakTitle)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(streakSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if currentStreak > 0 {
                    Text("\(currentStreak)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(streakColor)
                }
            }

            // Longest streak (shown subtly if different from current)
            if longestStreak > currentStreak && longestStreak > 1 {
                HStack(spacing: 6) {
                    Image(systemName: "trophy")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text("Longest streak: \(longestStreak) day\(longestStreak == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 54)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    // MARK: - Computed Properties

    private var streakColor: Color {
        if currentStreak >= 7 {
            return CircleTheme.warmAmber
        } else if currentStreak > 0 {
            return CircleTheme.warmAmber.opacity(0.8)
        } else {
            return .secondary
        }
    }

    private var streakIcon: String {
        if currentStreak >= 7 {
            return "flame.fill"
        } else if currentStreak > 0 {
            return "flame"
        } else {
            return "flame"
        }
    }

    private var streakTitle: String {
        if currentStreak == 0 {
            return "Start your streak"
        } else if currentStreak == 1 {
            return "1 day connected"
        } else {
            return "\(currentStreak) days connected"
        }
    }

    private var streakSubtitle: String {
        if currentStreak == 0 {
            return "Record a response to begin"
        } else if currentStreak < 3 {
            return "Keep the conversation going"
        } else if currentStreak < 7 {
            return "Your circle is getting closer"
        } else {
            return "Your circle is thriving"
        }
    }
}

// MARK: - Preview

#Preview("Expanded - Active Streak") {
    VStack(spacing: 16) {
        CircleStreakView(currentStreak: 5, longestStreak: 12, isCompact: false)
        CircleStreakView(currentStreak: 14, longestStreak: 14, isCompact: false)
        CircleStreakView(currentStreak: 0, longestStreak: 5, isCompact: false)
        CircleStreakView(currentStreak: 1, longestStreak: 1, isCompact: false)
    }
    .padding()
}

#Preview("Compact") {
    HStack(spacing: 12) {
        CircleStreakView(currentStreak: 5, longestStreak: 12, isCompact: true)
        CircleStreakView(currentStreak: 0, longestStreak: 5, isCompact: true)
        CircleStreakView(currentStreak: 14, longestStreak: 14, isCompact: true)
    }
    .padding()
}
#endif
