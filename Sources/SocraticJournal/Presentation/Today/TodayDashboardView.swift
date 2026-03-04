// TodayDashboardView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Today tab dashboard showing daily progress, techniques, and session history
public struct TodayDashboardView: View {
    @State private var viewModel: TodayDashboardViewModel

    /// Callback to navigate to a breathing session with a pre-selected technique
    let onStartSession: (BreathTechnique) -> Void

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        onStartSession: @escaping (BreathTechnique) -> Void
    ) {
        _viewModel = State(initialValue: TodayDashboardViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository
        ))
        self.onStartSession = onStartSession
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
                // Hero: Daily Progress
                DailyProgressCard(
                    greeting: viewModel.greeting,
                    streak: viewModel.streak,
                    todayMinutes: viewModel.todayMinutes,
                    dailyGoalMinutes: viewModel.dailyGoalMinutes
                )

                // Quick Start
                SectionHeaderView("Start Breathing")

                TechniqueCard(
                    technique: viewModel.quickStartTechnique,
                    backgroundColor: AppColors.cardTeal,
                    showPlayIcon: true,
                    onTap: { onStartSession(viewModel.quickStartTechnique) }
                )
                .padding(.horizontal, AppSpacing.screenPadding)

                // Techniques
                SectionHeaderView("Techniques")
                    .padding(.top, AppSpacing.sectionGap)

                TechniqueListSection(onSelect: onStartSession)

                // Today's Sessions (hidden if empty)
                if viewModel.hasTodaySessions {
                    SectionHeaderView("Today's Sessions")
                        .padding(.top, AppSpacing.sectionGap)

                    VStack(spacing: 0) {
                        ForEach(viewModel.todaySessions) { session in
                            SessionHistoryRow(session: session)
                            if session.id != viewModel.todaySessions.last?.id {
                                HairlineDivider()
                                    .padding(.horizontal, AppSpacing.screenPadding)
                            }
                        }
                    }
                }

                // Tip of the Day
                TipOfTheDayCard()
                    .padding(.top, AppSpacing.sectionGap)
                    .padding(.bottom, AppSpacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Today Dashboard") {
    TodayDashboardView(
        sessionRepository: UserDefaultsBreathSessionRepository(),
        settingsRepository: UserDefaultsSettingsRepository(),
        onStartSession: { _ in }
    )
}
#endif
