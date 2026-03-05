// TodayView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Today dashboard with greeting, streak, week grid, and session history
public struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var showSettings = false
    @Environment(ThemeManager.self) private var themeManager

    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    /// Callback to switch to the Breathe tab with a pre-selected pattern and duration
    var onNavigateToBreathe: ((_ patternId: String, _ durationMinutes: Int) -> Void)?

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol,
        onNavigateToBreathe: ((_ patternId: String, _ durationMinutes: Int) -> Void)? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self.onNavigateToBreathe = onNavigateToBreathe
        _viewModel = State(initialValue: TodayViewModel(
            sessionRepository: sessionRepository,
            settingsRepository: settingsRepository
        ))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Date header
                    dateHeader
                    HairlineDivider()

                    // Suggested pattern card
                    SuggestedPatternCard(
                        recommendation: viewModel.recommendation
                    ) {
                        onNavigateToBreathe?(
                            viewModel.recommendation.patternId,
                            viewModel.recommendation.suggestedDurationMinutes
                        )
                    }
                    HairlineDivider()

                    // Streak + Week grid
                    streakAndWeekSection
                    HairlineDivider()

                    // Today's sessions
                    todaySessionsSection
                    HairlineDivider()

                    // Daily goal progress
                    goalProgressSection
                    HairlineDivider()

                    // See Progress link
                    seeProgressLink

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
            .task { await viewModel.loadData() }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    viewModel: SettingsViewModel(
                        settingsRepository: settingsRepository,
                        notificationService: notificationService,
                        analyticsService: analyticsService
                    )
                )
                .environment(themeManager)
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "progress" {
                    SessionProgressView(
                        viewModel: ProgressViewModel(
                            sessionRepository: viewModel.sessionRepository
                        )
                    )
                }
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.dateString.uppercased())
                        .font(.system(size: 11))
                        .tracking(1.2)
                        .foregroundStyle(AppColors.textTertiary)

                    Text(viewModel.greeting)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                        .tracking(-0.3)
                }

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.cardPadding)
    }

    // MARK: - Streak + Week

    private var streakAndWeekSection: some View {
        HStack(spacing: 0) {
            // Streak
            VStack(alignment: .leading, spacing: 8) {
                Text("STREAK")
                    .font(.system(size: 11))
                    .tracking(1.0)
                    .foregroundStyle(AppColors.textTertiary)

                Text("\(viewModel.streak)")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text("days")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.cardPadding)

            HairlineDivider(axis: .vertical)
                .frame(height: 100)

            // Week grid
            VStack(alignment: .leading, spacing: 8) {
                Text("THIS WEEK")
                    .font(.system(size: 11))
                    .tracking(1.0)
                    .foregroundStyle(AppColors.textTertiary)

                HStack(spacing: 6) {
                    ForEach(viewModel.weekDays) { day in
                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(dayColor(for: day))
                                .frame(width: 26, height: 26)
                                .overlay {
                                    if day.completed {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(
                                            day.isToday ? AppColors.accent : Color.clear,
                                            lineWidth: day.isToday ? 2 : 0
                                        )
                                )

                            Text(day.label)
                                .font(.system(size: 8))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }
                }
            }
            .padding(AppSpacing.cardPadding)
        }
    }

    private func dayColor(for day: TodayViewModel.WeekDay) -> Color {
        if day.completed { return AppColors.accent }
        if day.isFuture { return AppColors.surface }
        if day.isToday { return viewModel.goalReached ? AppColors.accent : AppColors.surface }
        return AppColors.surface
    }

    // MARK: - Today's Sessions

    private var todaySessionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("TODAY'S PRACTICE")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, AppSpacing.cardPadding)

            if viewModel.todaySessions.isEmpty {
                HStack(spacing: 14) {
                    Circle()
                        .stroke(AppColors.border, lineWidth: 1.5)
                        .frame(width: 22, height: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("No sessions yet today")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Head to Breathe to start")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .padding(.bottom, AppSpacing.cardPadding)
            } else {
                ForEach(viewModel.todaySessions) { session in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 22, height: 22)
                            .overlay {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(viewModel.sessionDurationFormatted(session)) · \(viewModel.patternName(for: session.patternId))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            Text(session.startedAt.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.textTertiary)
                        }

                        Spacer()
                    }
                }
                .padding(.bottom, AppSpacing.cardPadding)
            }
        }
        .padding(.horizontal, AppSpacing.cardPadding)
    }

    // MARK: - See Progress

    private var seeProgressLink: some View {
        NavigationLink(value: "progress") {
            HStack {
                Text("See Progress")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.accent)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.cardPadding)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Goal Progress

    private var goalProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("DAILY GOAL")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)

            HStack(spacing: AppSpacing.sm) {
                GeometricRing(
                    progress: min(viewModel.totalMinutesToday / Double(viewModel.dailyGoalMinutes), 1.0),
                    size: 48,
                    lineWidth: 6
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.1f / %d min", viewModel.totalMinutesToday, viewModel.dailyGoalMinutes))
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(viewModel.goalReached ? "Goal reached" : "Keep going")
                        .font(.system(size: 11))
                        .foregroundStyle(viewModel.goalReached ? AppColors.accent : AppColors.textTertiary)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
    }
}

#Preview {
    TodayView(
        sessionRepository: UserDefaultsBreathSessionRepository(),
        settingsRepository: UserDefaultsSettingsRepository(),
        notificationService: LocalNotificationService(),
        analyticsService: PreviewAnalyticsService(),
        onNavigateToBreathe: { _, _ in }
    )
    .environment(ThemeManager.shared)
}

private final class PreviewAnalyticsService: AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {}
    func setUserProperty(_ name: String, value: String?) {}
}
#endif
