// ProgressHistoryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Weekly analytics with bar chart, pattern distribution, and session history
public struct ProgressHistoryView: View {
    @State private var viewModel: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        healthKitService: (any HealthKitServiceProtocol)? = nil
    ) {
        _viewModel = State(initialValue: ProgressViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository,
            healthKitService: healthKitService
        ))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Summary stats
                    SummaryStatsRow(
                        totalMinutes: viewModel.totalMinutes,
                        totalSessions: viewModel.totalSessions,
                        averagePerDay: viewModel.averagePerDay
                    )
                    HairlineDivider()

                    // Weekly bar chart
                    WeeklyBarChart(
                        days: viewModel.weeklyMinutes,
                        dailyGoalMinutes: viewModel.dailyGoalMinutes
                    )
                    HairlineDivider()

                    // Pattern distribution
                    PatternDistribution(stats: viewModel.patternStats)
                    HairlineDivider()

                    // Session history (last 3 + See All)
                    RecentSessionsSection(
                        sessions: viewModel.recentSessions,
                        allDateGroups: viewModel.dateGroups,
                        viewModel: viewModel
                    )
                    HairlineDivider()

                    // BOLT history
                    BOLTHistoryList(recentScores: viewModel.recentBoltScores, allScores: viewModel.boltScores)

                    // Health insights (shown only when HealthKit is enabled and available)
                    if viewModel.healthKitEnabled && viewModel.healthKitAvailable {
                        HairlineDivider()
                        healthInsightsSection
                    }

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Progress")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .task { await viewModel.loadData() }
    }

    // MARK: - Health Insights

    private var healthInsightsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("HEALTH INSIGHTS")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.md)

            HStack(spacing: AppSpacing.sm) {
                healthTile(
                    title: "HRV",
                    subtitle: "7-day avg",
                    value: viewModel.currentHRVAvg.map { String(format: "%.0f ms", $0) },
                    trendUp: trendDirection(current: viewModel.currentHRVAvg, previous: viewModel.previousHRVAvg, higherIsBetter: true),
                    contextLabel: viewModel.currentHRVAvg.map { hrvContextLabel($0) },
                    accentColor: AppColors.accent,
                    downColor: AppColors.accent2
                )

                healthTile(
                    title: "Resting HR",
                    subtitle: "7-day avg",
                    value: viewModel.currentRHRAvg.map { String(format: "%.0f bpm", $0) },
                    trendUp: trendDirection(current: viewModel.currentRHRAvg, previous: viewModel.previousRHRAvg, higherIsBetter: false),
                    contextLabel: nil,
                    accentColor: AppColors.accent,
                    downColor: AppColors.accent2
                )
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.md)
        }
    }

    private func healthTile(
        title: String,
        subtitle: String,
        value: String?,
        trendUp: Bool?,
        contextLabel: String?,
        accentColor: Color,
        downColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(AppColors.textTertiary)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textTertiary)
            }

            if let value {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    if let up = trendUp {
                        Text(up ? "↑" : "↓")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(up ? accentColor : downColor)
                    } else {
                        Text("→")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }

                if let label = contextLabel {
                    Text(label)
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                Text("No data yet")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.cardPadding)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func trendDirection(current: Double?, previous: Double?, higherIsBetter: Bool) -> Bool? {
        guard let c = current, let p = previous else { return nil }
        let tolerance = 1.0
        if c > p + tolerance { return higherIsBetter ? true : false }
        if c < p - tolerance { return higherIsBetter ? false : true }
        return nil // stable
    }

    private func hrvContextLabel(_ ms: Double) -> String {
        switch ms {
        case 50...: return "Excellent recovery"
        case 30..<50: return "Good recovery"
        case 20..<30: return "Keep practicing"
        default: return "Rest recommended"
        }
    }
}
#endif
