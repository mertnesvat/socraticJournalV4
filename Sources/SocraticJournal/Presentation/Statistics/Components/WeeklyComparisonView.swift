// WeeklyComparisonView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compares this week's statistics with last week
public struct WeeklyComparisonView: View {
    let thisWeekCount: Int
    let lastWeekCount: Int
    let thisWeekAverage: Double
    let lastWeekAverage: Double
    let percentChange: Double

    @State private var animatedThisWeek: CGFloat = 0
    @State private var animatedLastWeek: CGFloat = 0

    public init(
        thisWeekCount: Int,
        lastWeekCount: Int,
        thisWeekAverage: Double,
        lastWeekAverage: Double,
        percentChange: Double
    ) {
        self.thisWeekCount = thisWeekCount
        self.lastWeekCount = lastWeekCount
        self.thisWeekAverage = thisWeekAverage
        self.lastWeekAverage = lastWeekAverage
        self.percentChange = percentChange
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Header with trend indicator
            HStack {
                Text("Week Comparison")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()

                trendBadge
            }

            // Visual comparison
            HStack(spacing: 24) {
                // Last week
                weekColumn(
                    title: "Last Week",
                    count: lastWeekCount,
                    average: lastWeekAverage,
                    progress: animatedLastWeek,
                    color: .secondary
                )

                // Divider with arrow
                VStack {
                    Image(systemName: trendIcon)
                        .font(.title2)
                        .foregroundStyle(trendColor)
                }
                .frame(width: 40)

                // This week
                weekColumn(
                    title: "This Week",
                    count: thisWeekCount,
                    average: thisWeekAverage,
                    progress: animatedThisWeek,
                    color: .accentColor
                )
            }

            // Summary message
            summaryMessage
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onAppear {
            let maxCount = max(thisWeekCount, lastWeekCount, 1)
            withAnimation(.easeOut(duration: 0.8)) {
                animatedThisWeek = CGFloat(thisWeekCount) / CGFloat(maxCount)
                animatedLastWeek = CGFloat(lastWeekCount) / CGFloat(maxCount)
            }
        }
    }

    private func weekColumn(
        title: String,
        count: Int,
        average: Double,
        progress: CGFloat,
        color: Color
    ) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Session count bar
            VStack(spacing: 8) {
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(color)

                GeometryReader { geometry in
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .systemGray5))
                            .frame(width: 40)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.8))
                            .frame(width: 40, height: geometry.size.height * progress)
                    }
                }
                .frame(width: 40, height: 80)

                Text("sessions")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Average score
            VStack(spacing: 2) {
                Text("Avg Score")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if average > 0 {
                    Text(String(format: "%.0f", average))
                        .font(.headline)
                        .foregroundStyle(color)
                } else {
                    Text("-")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var trendBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: trendIcon)
                .font(.caption)
            Text(trendText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(trendColor.opacity(0.15))
        .foregroundStyle(trendColor)
        .clipShape(Capsule())
    }

    private var trendIcon: String {
        if percentChange > 0 {
            return "arrow.up.right"
        } else if percentChange < 0 {
            return "arrow.down.right"
        } else {
            return "arrow.right"
        }
    }

    private var trendColor: Color {
        if percentChange > 0 {
            return .green
        } else if percentChange < 0 {
            return .red
        } else {
            return .secondary
        }
    }

    private var trendText: String {
        if percentChange == 0 && thisWeekCount == 0 && lastWeekCount == 0 {
            return "No data"
        } else if percentChange == 0 {
            return "Same"
        } else {
            return String(format: "%.0f%%", abs(percentChange))
        }
    }

    private var summaryMessage: some View {
        HStack {
            Image(systemName: summaryIcon)
                .foregroundStyle(summaryColor)

            Text(summaryText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var summaryIcon: String {
        if thisWeekCount > lastWeekCount {
            return "sparkles"
        } else if thisWeekCount < lastWeekCount {
            return "arrow.counterclockwise"
        } else if thisWeekCount == 0 {
            return "lightbulb"
        } else {
            return "checkmark.circle"
        }
    }

    private var summaryColor: Color {
        if thisWeekCount > lastWeekCount {
            return .green
        } else if thisWeekCount < lastWeekCount {
            return .orange
        } else {
            return .blue
        }
    }

    private var summaryText: String {
        if thisWeekCount == 0 && lastWeekCount == 0 {
            return "Start journaling to track your progress!"
        } else if thisWeekCount > lastWeekCount {
            return "Great progress! You're journaling more than last week."
        } else if thisWeekCount < lastWeekCount {
            return "Keep it up! Try to match last week's pace."
        } else {
            return "Consistent effort! You're maintaining a good habit."
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        WeeklyComparisonView(
            thisWeekCount: 5,
            lastWeekCount: 3,
            thisWeekAverage: 72.5,
            lastWeekAverage: 65.0,
            percentChange: 66.7
        )

        WeeklyComparisonView(
            thisWeekCount: 2,
            lastWeekCount: 4,
            thisWeekAverage: 55.0,
            lastWeekAverage: 70.0,
            percentChange: -50.0
        )

        WeeklyComparisonView(
            thisWeekCount: 0,
            lastWeekCount: 0,
            thisWeekAverage: 0,
            lastWeekAverage: 0,
            percentChange: 0
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
