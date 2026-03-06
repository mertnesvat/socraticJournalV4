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
        settingsRepository: SettingsRepositoryProtocol
    ) {
        _viewModel = State(initialValue: ProgressViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository
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

                    // Apple Health cumulative minutes (hidden when unavailable or zero)
                    if let hkMinutes = viewModel.totalHealthKitMinutes, hkMinutes > 0 {
                        healthKitMinutesRow(minutes: hkMinutes)
                        HairlineDivider()
                    }

                    // Weekly bar chart
                    WeeklyBarChart(
                        days: viewModel.weeklyMinutes,
                        dailyGoalMinutes: viewModel.dailyGoalMinutes
                    )
                    HairlineDivider()

                    // Pattern distribution
                    PatternDistribution(stats: viewModel.patternStats)
                    HairlineDivider()

                    // Session history
                    SessionHistoryList(
                        dateGroups: viewModel.dateGroups,
                        viewModel: viewModel
                    )

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

    // MARK: - HealthKit Row

    private func healthKitMinutesRow(minutes: Double) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.accent2.opacity(0.8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("HEALTH")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(AppColors.textTertiary)

                    Text(String(format: "%.0f min total", minutes))
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

            Spacer()

            Text("All time · Apple Health")
                .font(.system(size: 10))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppSpacing.cardPadding)
    }
}
#endif
