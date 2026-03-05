// WeeklyBarChart.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 7-day bar chart with goal line
struct WeeklyBarChart: View {
    let days: [ProgressViewModel.DayMinutes]
    let dailyGoalMinutes: Int

    private let chartHeight: CGFloat = 120
    private let barWidth: CGFloat = 8

    private var maxValue: Double {
        let maxDay = days.map(\.minutes).max() ?? 0
        return max(maxDay, Double(dailyGoalMinutes), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("THIS WEEK")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)

            ZStack(alignment: .leading) {
                // Goal line
                VStack {
                    Spacer()
                        .frame(height: chartHeight * (1.0 - Double(dailyGoalMinutes) / maxValue))

                    HStack(spacing: 4) {
                        Text("Goal")
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.textTertiary)

                        GeometryReader { geo in
                            Path { path in
                                let y: CGFloat = 0
                                var x: CGFloat = 0
                                while x < geo.size.width {
                                    path.move(to: CGPoint(x: x, y: y))
                                    path.addLine(to: CGPoint(x: min(x + 4, geo.size.width), y: y))
                                    x += 8
                                }
                            }
                            .stroke(AppColors.border, lineWidth: 1)
                        }
                        .frame(height: 1)
                    }

                    Spacer()
                }
                .frame(height: chartHeight)

                // Bars
                HStack(spacing: 0) {
                    ForEach(days) { day in
                        VStack(spacing: 0) {
                            // Minutes label
                            if day.minutes > 0 {
                                Text(String(format: "%.0f", day.minutes))
                                    .font(.system(size: 9))
                                    .foregroundStyle(AppColors.accent)
                                    .frame(height: 14)
                            } else {
                                Spacer().frame(height: 14)
                            }

                            // Bar area
                            VStack {
                                Spacer()

                                if day.minutes > 0 {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(AppColors.accent)
                                        .frame(
                                            width: barWidth,
                                            height: max(4, chartHeight * (day.minutes / maxValue))
                                        )
                                }
                            }
                            .frame(height: chartHeight)

                            // Day label
                            Text(day.label)
                                .font(.system(size: 9))
                                .foregroundStyle(AppColors.textTertiary)
                                .frame(height: 16)

                            // Today indicator
                            if day.isToday {
                                Circle()
                                    .fill(AppColors.accent)
                                    .frame(width: 4, height: 4)
                            } else {
                                Spacer().frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.md)
    }
}
#endif
