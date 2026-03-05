// SessionProgressView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Session history and progress analytics screen
public struct SessionProgressView: View {
    @State private var viewModel: ProgressViewModel

    public init(viewModel: ProgressViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                header
                HairlineDivider()

                if viewModel.isLoading && viewModel.isEmpty {
                    loadingState
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    // Lifetime stats
                    lifetimeStatsSection
                    HairlineDivider()

                    // Weekly bar chart
                    weeklyChartSection
                    HairlineDivider()

                    // Monthly calendar heatmap
                    monthlyHeatmapSection
                    HairlineDivider()

                    // Pattern breakdown
                    patternBreakdownSection
                }

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
        }
        .task { await viewModel.loadData() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Journey")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .tracking(-0.3)

            Text("Every breath counts")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.cardPadding)
    }

    // MARK: - Lifetime Stats

    private var lifetimeStatsSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Lifetime", showTopBorder: false)

            HStack(spacing: 0) {
                // Total minutes
                statColumn(
                    value: viewModel.totalMinutesFormatted,
                    label: "minutes"
                )

                HairlineDivider(axis: .vertical)
                    .frame(height: 70)

                // Total sessions
                statColumn(
                    value: "\(viewModel.totalSessions)",
                    label: "sessions"
                )

                HairlineDivider(axis: .vertical)
                    .frame(height: 70)

                // Longest streak
                statColumn(
                    value: "\(viewModel.longestStreak)",
                    label: "day streak"
                )
            }
            .padding(.bottom, AppSpacing.cardPadding)
        }
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 42, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label.uppercased())
                .font(.system(size: 11))
                .tracking(0.5)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Chart

    private var weeklyChartSection: some View {
        VStack(spacing: 0) {
            WeeklyBarChart(
                bars: viewModel.weeklyBarData,
                weeklyMinutesFormatted: viewModel.weeklyMinutesFormatted
            )
            .padding(.bottom, AppSpacing.cardPadding)
        }
    }

    // MARK: - Monthly Heatmap

    private var monthlyHeatmapSection: some View {
        MonthlyHeatmap(
            monthTitle: viewModel.displayedMonthFormatted,
            dayCells: viewModel.monthlyDayData,
            onPreviousMonth: {
                Task { await viewModel.navigateMonth(by: -1) }
            },
            onNextMonth: {
                Task { await viewModel.navigateMonth(by: 1) }
            }
        )
    }

    // MARK: - Pattern Breakdown

    private var patternBreakdownSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Patterns Practiced")

            if viewModel.patternBreakdown.isEmpty {
                // Empty state
                Text("Complete a session to see your pattern usage")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
                    .padding(.horizontal, AppSpacing.screenPadding)
            } else {
                ForEach(viewModel.patternBreakdown) { stat in
                    PatternBreakdownRow(stat: stat)

                    if stat.id != viewModel.patternBreakdown.last?.id {
                        HairlineDivider()
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
                .padding(.bottom, AppSpacing.sm)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer(minLength: AppSpacing.sectionGap)

            Image(systemName: "wind")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppColors.textTertiary)

            Text("Your journey begins with a single breath")
                .font(.system(size: 15, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Text("Complete your first session to see your progress here.")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)

            Spacer(minLength: AppSpacing.sectionGap)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack {
            Spacer(minLength: AppSpacing.sectionGap)
            ProgressIndicator()
            Spacer(minLength: AppSpacing.sectionGap)
        }
    }
}

/// A minimal loading indicator matching the app design
private struct ProgressIndicator: View {
    var body: some View {
        SwiftUI.ProgressView()
            .tint(AppColors.accent)
    }
}

#Preview {
    NavigationStack {
        SessionProgressView(
            viewModel: ProgressViewModel(
                sessionRepository: UserDefaultsBreathSessionRepository()
            )
        )
    }
}
#endif
