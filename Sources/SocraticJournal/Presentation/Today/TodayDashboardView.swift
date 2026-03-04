// TodayDashboardView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Today tab — daily driver with streak ring, progress, quick start, and tip of the day
public struct TodayDashboardView: View {
    @State var viewModel: TodayDashboardViewModel
    var onStartSession: () -> Void
    @State private var showSettings: Bool = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    dailyProgressRing
                    streakIndicator
                        .padding(.top, AppSpacing.md)
                    quickStartButton
                        .padding(.top, AppSpacing.lg)
                    tipOfTheDayCard
                        .padding(.top, AppSpacing.sectionGap)
                    todaysSessionsList
                        .padding(.top, AppSpacing.sectionGap)
                    reminderStatus
                        .padding(.top, AppSpacing.md)

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
            .task { await viewModel.loadData() }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    viewModel: SettingsViewModel(
                        settingsRepository: viewModel.settingsRepository
                    )
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Today")
                    .font(AppTypography.displayMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Text(dateString)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.heroTopPadding)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }

    // MARK: - Daily Progress Ring

    private var dailyProgressRing: some View {
        VStack(spacing: AppSpacing.sm) {
            GeometricRing(
                progress: viewModel.dailyProgress,
                size: 200,
                lineWidth: 28,
                accentColor: viewModel.goalReached ? AppColors.success : AppColors.accent
            )
            .overlay {
                VStack(spacing: 2) {
                    Text(String(format: "%.0f", viewModel.totalMinutesToday))
                        .font(AppTypography.stat)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("minutes today")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Text("of \(viewModel.dailyGoalMinutes) min goal")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Streak Indicator

    private var streakIndicator: some View {
        HStack(spacing: AppSpacing.xs) {
            if viewModel.streak > 0 {
                Image(systemName: "flame.fill")
                    .foregroundStyle(AppColors.accent)
                Text("\(viewModel.streak) day streak")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                Text("Start your streak today")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Quick Start

    private var quickStartButton: some View {
        AccentPillButton("Start Session", icon: "play.fill") {
            onStartSession()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Tip of the Day

    @ViewBuilder
    private var tipOfTheDayCard: some View {
        if let tip = viewModel.tipOfTheDay {
            VStack(spacing: 0) {
                SectionHeaderView("Tip of the Day", showTopBorder: false)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(tip.category.rawValue)
                        .font(AppTypography.badge)
                        .foregroundStyle(AppColors.textOnAccent)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(Capsule().fill(AppColors.accent))

                    Text(tip.title)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(tip.body)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(AppSpacing.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.surfaceElevated)
                )
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }

    // MARK: - Today's Sessions

    @ViewBuilder
    private var todaysSessionsList: some View {
        let sessions = viewModel.todaysSessions
        if !sessions.isEmpty {
            VStack(spacing: 0) {
                SectionHeaderView("Today's Sessions")

                VStack(spacing: 0) {
                    ForEach(sessions.reversed()) { session in
                        sessionRow(session)
                        if session.id != sessions.first?.id {
                            HairlineDivider()
                                .padding(.leading, AppSpacing.screenPadding)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }

    private func sessionRow(_ session: BreathSession) -> some View {
        let technique = BreathTechnique.allTechniques.first { $0.id == session.techniqueId }
        return HStack {
            Text(technique?.name ?? "Session")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("\(session.formattedDuration) \u{00B7} \(session.formattedTime)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Reminder Status

    private var reminderStatus: some View {
        Group {
            if let time = viewModel.reminderTime {
                Text("Reminder set for \(time)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            } else {
                Button {
                    showSettings = true
                } label: {
                    Text("Set a daily reminder")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

#endif
