// TodayView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Today tab: a glanceable daily dashboard
public struct TodayView: View {
    @State private var viewModel: TodayViewModel

    /// Callback to switch to the Breathe tab
    private let onStartBreathing: () -> Void

    /// Callback to open Settings
    private let onOpenSettings: () -> Void

    public init(
        sessionRepository: SessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        onStartBreathing: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: TodayViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository
        ))
        self.onStartBreathing = onStartBreathing
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.sectionGap) {
                // Streak ring section
                streakSection
                    .padding(.top, AppSpacing.heroTopPadding)

                // Weekly progress
                weeklyProgressSection

                // Today's session status card
                sessionStatusCard

                // Quick Start CTA
                AccentPillButton(viewModel.ctaButtonText, icon: "wind") {
                    onStartBreathing()
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                // Tip of the day
                tipOfTheDayCard

                // Reminder status
                reminderStatusSection

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

    // MARK: - Streak Ring

    private var streakSection: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                GeometricRing(
                    progress: viewModel.streakRingProgress,
                    size: 180,
                    lineWidth: 20,
                    accentColor: viewModel.streakInfo.isAtRisk
                        ? AppColors.warning
                        : AppColors.accent,
                    trackColor: AppColors.surface
                )

                VStack(spacing: 4) {
                    Text("\(viewModel.streakInfo.currentStreak)")
                        .font(AppTypography.stat)
                        .foregroundStyle(
                            viewModel.streakInfo.isAtRisk
                                ? AppColors.warning
                                : AppColors.textPrimary
                        )

                    if viewModel.isFirstTime {
                        Text("start your streak")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    } else if viewModel.streakInfo.isAtRisk {
                        Text("streak at risk")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.warning)
                    } else {
                        Text("day streak")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Progress

    private var weeklyProgressSection: some View {
        VStack(spacing: AppSpacing.xs) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(AppColors.surface)
                        .frame(height: 8)

                    // Fill
                    Capsule()
                        .fill(AppColors.accent.opacity(0.7))
                        .frame(
                            width: geometry.size.width * viewModel.weeklyProgress.progress,
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(viewModel.weeklyProgress.minutesCompleted) / \(viewModel.weeklyProgress.goalMinutes) min this week")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                Text("\(viewModel.weeklyProgress.sessionsThisWeek) sessions")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Session Status Card

    private var sessionStatusCard: some View {
        HStack(spacing: AppSpacing.md) {
            if viewModel.hasSessionToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's session complete")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)

                    if let session = viewModel.todaySession {
                        Text("\(session.patternName) -- \(session.shortDurationLabel) -- \(session.formattedTimeOfDay)")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.textTertiary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isFirstTime ? "Welcome to Breath Pacer" : "No session yet today")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("5 minutes is all it takes")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Tip of the Day

    private var tipOfTheDayCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeaderView("Did You Know", showTopBorder: false)

            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: "book.closed")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.accent.opacity(0.6))
                    .padding(.top, 2)

                Text(viewModel.tipOfTheDay.text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Reminder Status

    private var reminderStatusSection: some View {
        Group {
            if viewModel.reminderEnabled {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textTertiary)

                    Text("Reminder at \(viewModel.reminderTimeFormatted)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
            } else {
                Button {
                    onOpenSettings()
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "bell")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.textTertiary)

                        Text("Set a daily reminder")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

#Preview {
    TodayView(
        sessionRepository: UserDefaultsSessionRepository(),
        settingsRepository: UserDefaultsSettingsRepository(),
        onStartBreathing: {},
        onOpenSettings: {}
    )
    .environment(ThemeManager.shared)
}
#endif
