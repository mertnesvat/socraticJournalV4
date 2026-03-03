// TodayDashboardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

public struct TodayDashboardView: View {
    let breathSessionRepository: BreathSessionRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    let analyticsService: AnalyticsServiceProtocol

    @State private var viewModel: TodayDashboardViewModel
    @State private var showSettings = false
    @Environment(ThemeManager.self) private var themeManager

    public init(
        breathSessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.breathSessionRepository = breathSessionRepository
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self._viewModel = State(initialValue: TodayDashboardViewModel(
            breathSessionRepository: breathSessionRepository,
            settingsRepository: settingsRepository
        ))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Today")
                            .font(AppTypography.display2)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(formattedDate)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.top, AppSpacing.heroTopPadding)

                    // Daily progress
                    DailyProgressCard(
                        totalMinutes: viewModel.totalMinutesToday,
                        sessionsCount: viewModel.sessionsCount,
                        goalProgress: viewModel.goalProgress,
                        dailyGoalMinutes: viewModel.dailyGoalMinutes
                    )

                    // Technique cards
                    SectionHeaderView("Techniques", showTopBorder: false)

                    ForEach(BreathTechnique.allTechniques) { technique in
                        NavigationLink {
                            BreathSessionSetupView(
                                technique: technique,
                                breathSessionRepository: breathSessionRepository,
                                analyticsService: analyticsService
                            )
                        } label: {
                            techniqueCard(technique)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        })
                    }

                    // Today's sessions
                    if !viewModel.todaySessions.isEmpty {
                        SectionHeaderView("Today's Sessions")

                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.todaySessions.enumerated()), id: \.element.id) { index, session in
                                SessionHistoryRow(
                                    techniqueName: viewModel.techniqueName(for: session),
                                    duration: session.totalDuration,
                                    startedAt: session.startedAt
                                )
                                if index < viewModel.todaySessions.count - 1 {
                                    HairlineDivider()
                                }
                            }
                        }
                    }

                    // Streak
                    StreakIndicator(streak: viewModel.streak)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sectionGap)
            }
            .background(AppColors.background)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    viewModel: SettingsViewModel(
                        settingsRepository: settingsRepository,
                        notificationService: notificationService,
                        analyticsService: analyticsService
                    )
                )
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
            }
            .onAppear {
                Task { await viewModel.load() }
            }
        }
    }

    @ViewBuilder
    private func techniqueCard(_ technique: BreathTechnique) -> some View {
        let bgColor: Color = {
            switch technique.id {
            case "resonant": return AppColors.cardTeal
            case "box": return AppColors.surface
            case "478": return AppColors.cardYellow
            default: return AppColors.surfaceElevated
            }
        }()

        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(technique.name)
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(technique.subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                Text(timingString(for: technique))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                Text(technique.difficulty.rawValue.capitalized)
                    .font(AppTypography.captionBold)
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppColors.accent.opacity(0.12)))
                    .padding(.top, AppSpacing.xxs)
            }

            Spacer()

            Image(systemName: "play.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppColors.accent)
        }
        .padding(AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(technique.id == "box" ? AppColors.border : Color.clear, lineWidth: AppSpacing.gridGutter)
        )
    }

    private func timingString(for technique: BreathTechnique) -> String {
        technique.phases.map { phase in
            let seconds = phase.duration
            if seconds == floor(seconds) {
                return "\(Int(seconds))s"
            } else {
                return String(format: "%.1fs", seconds)
            }
        }
        .joined(separator: " · ")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}
#endif
