// StreakProgressView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Visual streak display with progress towards next milestone
public struct StreakProgressView: View {
    let currentStreak: Int
    let longestStreak: Int
    let nextMilestone: Int
    let progress: Double

    @State private var animatedProgress: Double = 0

    public init(currentStreak: Int, longestStreak: Int, nextMilestone: Int, progress: Double) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.nextMilestone = nextMilestone
        self.progress = progress
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Streak Progress")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            // Main streak display
            HStack(spacing: 24) {
                // Current streak with flame
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(streakColor.opacity(0.15))
                            .frame(width: 80, height: 80)

                        VStack(spacing: 2) {
                            Image(systemName: currentStreak > 0 ? "flame.fill" : "flame")
                                .font(.title)
                                .foregroundStyle(streakColor)

                            Text("\(currentStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }

                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Progress towards next milestone
                VStack(alignment: .leading, spacing: 8) {
                    if currentStreak < nextMilestone {
                        Text("Next milestone: \(nextMilestone) days")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(uiColor: .systemGray5))
                                    .frame(height: 12)

                                // Progress fill
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [streakColor.opacity(0.8), streakColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * animatedProgress, height: 12)
                            }
                        }
                        .frame(height: 12)

                        let daysRemaining = nextMilestone - currentStreak
                        Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") to go")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Milestone reached!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.green)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                // Best streak
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.15))
                            .frame(width: 80, height: 80)

                        VStack(spacing: 2) {
                            Image(systemName: "trophy.fill")
                                .font(.title)
                                .foregroundStyle(.yellow)

                            Text("\(longestStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }

                    Text("Best")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Streak breakdown
            streakBreakdown
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
    }

    private var streakBreakdown: some View {
        HStack(spacing: 16) {
            ForEach(0..<7, id: \.self) { index in
                let dayIndex = 6 - index
                let isActive = dayIndex < currentStreak

                VStack(spacing: 4) {
                    Circle()
                        .fill(isActive ? streakColor : Color(uiColor: .systemGray4))
                        .frame(width: 24, height: 24)
                        .overlay {
                            if isActive {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }

                    Text(dayLabel(for: dayIndex))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }

    private func dayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: -index, to: Date()) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private var streakColor: Color {
        switch currentStreak {
        case 0: return .gray
        case 1..<3: return .orange
        case 3..<7: return .orange
        case 7..<14: return .red
        default: return .red
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakProgressView(
            currentStreak: 5,
            longestStreak: 12,
            nextMilestone: 7,
            progress: 5.0 / 7.0
        )

        StreakProgressView(
            currentStreak: 0,
            longestStreak: 0,
            nextMilestone: 3,
            progress: 0
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
