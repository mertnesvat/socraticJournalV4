// ProgressHistoryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Weekly analytics with bar chart, pattern distribution, and session history
public struct ProgressHistoryView: View {
    @State private var viewModel: ProgressViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol? = nil
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

                    // HRV insights — only when authorized and data available
                    if viewModel.showHRVInsights, let hrv = viewModel.weeklyHRVAverage {
                        HairlineDivider()
                        hrvInsightsSection(average: hrv)
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
        .applyTheme(from: themeManager)
        .task { await viewModel.loadData() }
    }

    private func hrvInsightsSection(average: Double) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("HEALTH INSIGHTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.0f ms", average))
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("avg HRV · 7 days")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Text("Higher HRV and BOLT scores both reflect a calmer, stronger nervous system.")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)
            }
            .padding(AppSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.accent.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.md)
        }
    }
}
#endif
