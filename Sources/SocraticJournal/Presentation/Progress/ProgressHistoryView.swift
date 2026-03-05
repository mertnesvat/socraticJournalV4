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
}
#endif
