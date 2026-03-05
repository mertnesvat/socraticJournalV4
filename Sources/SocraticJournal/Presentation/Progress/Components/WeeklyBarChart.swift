// WeeklyBarChart.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Weekly bar chart showing daily breathing minutes for the current week
public struct WeeklyBarChart: View {
    let bars: [ProgressViewModel.DayBar]
    let weeklyMinutesFormatted: String

    private let barWidth: CGFloat = 28
    private let barGap: CGFloat = 8
    private let maxBarHeight: CGFloat = 120
    private let cornerRadius: CGFloat = 8

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeaderView("This Week", showTopBorder: false)

            if maxMinutes > 0 {
                chartContent
            } else {
                emptyChart
            }

            Text("\(weeklyMinutesFormatted) min this week")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Chart Content

    private var chartContent: some View {
        HStack(alignment: .bottom, spacing: barGap) {
            ForEach(bars) { bar in
                VStack(spacing: 6) {
                    barView(for: bar)
                        .frame(height: maxBarHeight)

                    Text(bar.label)
                        .font(.system(size: 11))
                        .foregroundStyle(bar.isToday ? AppColors.textPrimary : AppColors.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private func barView(for bar: ProgressViewModel.DayBar) -> some View {
        VStack {
            Spacer(minLength: 0)

            if bar.minutes > 0 {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bar.isToday ? AppColors.accent : AppColors.accent.opacity(0.6))
                    .frame(width: barWidth, height: barHeight(for: bar.minutes))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                bar.isToday ? AppColors.accent : Color.clear,
                                style: StrokeStyle(
                                    lineWidth: bar.isToday ? 2 : 0,
                                    dash: bar.isToday ? [4, 3] : []
                                )
                            )
                    )
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .frame(width: barWidth, height: 4)
            }
        }
    }

    private var emptyChart: some View {
        HStack(alignment: .bottom, spacing: barGap) {
            ForEach(bars) { bar in
                VStack(spacing: 6) {
                    VStack {
                        Spacer(minLength: 0)
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AppColors.surface)
                            .frame(width: barWidth, height: 4)
                    }
                    .frame(height: 40)

                    Text(bar.label)
                        .font(.system(size: 11))
                        .foregroundStyle(bar.isToday ? AppColors.textPrimary : AppColors.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Helpers

    private var maxMinutes: Double {
        bars.map(\.minutes).max() ?? 0
    }

    private func barHeight(for minutes: Double) -> CGFloat {
        guard maxMinutes > 0 else { return 4 }
        let proportion = minutes / maxMinutes
        let height = proportion * maxBarHeight
        return max(height, 4) // Minimum visible height
    }
}

#Preview {
    VStack {
        WeeklyBarChart(
            bars: [
                .init(id: 0, label: "M", minutes: 5, isToday: false),
                .init(id: 1, label: "T", minutes: 10, isToday: false),
                .init(id: 2, label: "W", minutes: 3, isToday: false),
                .init(id: 3, label: "T", minutes: 8, isToday: true),
                .init(id: 4, label: "F", minutes: 0, isToday: false),
                .init(id: 5, label: "S", minutes: 0, isToday: false),
                .init(id: 6, label: "S", minutes: 0, isToday: false),
            ],
            weeklyMinutesFormatted: "26"
        )
    }
    .background(AppColors.background)
}
#endif
