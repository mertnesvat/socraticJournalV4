// BreathProgressView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Progress tab showing stats, streak calendar, and session history
public struct BreathProgressView: View {
    @State private var viewModel: ProgressViewModel

    public init(repository: BreathSessionRepositoryProtocol) {
        _viewModel = State(initialValue: ProgressViewModel(repository: repository))
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                contentView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Loading State

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.accent)
            Text("Loading...")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Error State

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textTertiary)

            Text("Something went wrong")
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            Text(error.localizedDescription)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            AccentPillButton("Try Again", icon: "arrow.clockwise") {
                Task { await viewModel.loadData() }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .padding(AppSpacing.screenPadding)
    }

    // MARK: - Content

    private var contentView: some View {
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
                .padding(.bottom, AppSpacing.displayBottomMargin)

                // Stats Hero
                StatsHeroSection(
                    totalMinutes: viewModel.formattedTotalMinutes,
                    totalSessions: viewModel.totalSessions,
                    streak: viewModel.streak
                )

                // Calendar Section
                SectionHeaderView("This Month")
                    .padding(.top, AppSpacing.sectionGap)

                StreakCalendarView(sessionsByDay: viewModel.currentMonthSessionsByDay)

                // History Section
                SectionHeaderView("History")
                    .padding(.top, AppSpacing.sectionGap)

                SessionHistorySection(sessionsByDate: viewModel.sessionsByDate)

                Spacer()
                    .frame(height: AppSpacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Progress View") {
    BreathProgressView(repository: UserDefaultsBreathSessionRepository())
}
#endif
