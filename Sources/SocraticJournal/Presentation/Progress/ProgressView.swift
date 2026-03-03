// ProgressView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Progress tab: stats, calendar heatmap, and session history
public struct ProgressTabView: View {
    @State private var viewModel: ProgressViewModel

    public init(sessionRepository: SessionRepositoryProtocol) {
        self._viewModel = State(initialValue: ProgressViewModel(
            sessionRepository: sessionRepository
        ))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Progress")
                        .font(AppTypography.display)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)

                // Stats cards
                SectionHeaderView("Stats", showTopBorder: false)
                statsGrid
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.lg)

                // Calendar heatmap
                SectionHeaderView("Calendar")
                StreakCalendarView(
                    displayedMonth: viewModel.displayedMonth,
                    practiceDates: viewModel.practiceDates,
                    onPreviousMonth: { viewModel.previousMonth() },
                    onNextMonth: { viewModel.nextMonth() },
                    canGoForward: viewModel.canGoForward,
                    monthTitle: viewModel.displayedMonthTitle
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.lg)

                // Session history
                SectionHeaderView("Session History")
                sessionHistoryList
                    .padding(.horizontal, AppSpacing.screenPadding)

                Spacer(minLength: AppSpacing.xxl)
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
        .background(AppColors.background)
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: AppSpacing.sm),
            GridItem(.flexible(), spacing: AppSpacing.sm)
        ], spacing: AppSpacing.sm) {
            miniStatCard(value: "\(viewModel.totalMinutes)", label: "total minutes")
            miniStatCard(value: "\(viewModel.sessionsThisWeek)", label: "this week")
            miniStatCard(value: "\(viewModel.currentStreak)", label: "day streak")
            miniStatCard(value: "\(viewModel.longestStreak)", label: "best streak")
        }
    }

    private func miniStatCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.accent)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surface)
        )
    }

    // MARK: - Session History

    private var sessionHistoryList: some View {
        Group {
            if viewModel.sessions.isEmpty {
                emptyHistoryView
            } else {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    ForEach(viewModel.groupedSessions, id: \.date) { group in
                        // Date header
                        HStack {
                            Text(viewModel.formatSectionDate(group.date))
                                .font(AppTypography.captionBold)
                                .foregroundStyle(AppColors.textTertiary)
                            Spacer()
                        }
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xs)

                        // Session rows
                        ForEach(group.sessions) { session in
                            sessionRow(session)
                        }
                    }
                }
            }
        }
    }

    private func sessionRow(_ session: BreathSession) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(AppColors.accent.opacity(0.3))
                .frame(width: 8, height: 8)

            Text(session.patternName)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)

            Text("--")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)

            Text(session.shortDurationLabel)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Text(session.formattedTimeOfDay)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var emptyHistoryView: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "wind")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.textTertiary.opacity(0.5))

            Text("Complete your first session to see your history here")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, AppSpacing.xxl)
    }
}

#Preview {
    ProgressTabView(sessionRepository: UserDefaultsSessionRepository())
        .environment(ThemeManager.shared)
}
#endif
