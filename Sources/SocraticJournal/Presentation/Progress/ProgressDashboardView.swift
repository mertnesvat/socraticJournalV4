// ProgressDashboardView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Progress tab — stats, streak calendar heatmap, and session history
public struct ProgressDashboardView: View {
    @State var viewModel: ProgressDashboardViewModel

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                if viewModel.totalSessions == 0 && !viewModel.isLoading {
                    emptyState
                } else {
                    statsRow
                        .padding(.top, AppSpacing.lg)
                    streakCalendar
                        .padding(.top, AppSpacing.sectionGap)
                    sessionHistory
                        .padding(.top, AppSpacing.sectionGap)
                }

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
        .task { await viewModel.loadData() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Progress")
                .font(AppTypography.displayMedium)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.heroTopPadding)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "wind")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary)

            Text("Complete your first session\nto see progress here")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppSpacing.xxl * 2)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppSpacing.xs) {
            miniStatCard(
                value: String(format: "%.0f", viewModel.totalMinutes),
                label: "minutes",
                backgroundColor: AppColors.cardTeal
            )
            miniStatCard(
                value: "\(viewModel.totalSessions)",
                label: "sessions",
                backgroundColor: AppColors.surface,
                hasBorder: true
            )
            miniStatCard(
                value: "\(viewModel.bestStreak)",
                label: "day streak",
                backgroundColor: AppColors.cardYellow
            )
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private func miniStatCard(value: String, label: String, backgroundColor: Color, hasBorder: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay {
            if hasBorder {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
            }
        }
    }

    // MARK: - Streak Calendar

    private var streakCalendar: some View {
        VStack(spacing: 0) {
            SectionHeaderView("This Month")
            StreakCalendarView(sessionDays: viewModel.monthSessions)
                .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Session History

    @ViewBuilder
    private var sessionHistory: some View {
        if !viewModel.recentSessions.isEmpty {
            VStack(spacing: 0) {
                SectionHeaderView("Recent Sessions")

                VStack(spacing: 0) {
                    ForEach(viewModel.recentSessions, id: \.date) { group in
                        Text(group.date)
                            .font(AppTypography.captionBold)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .padding(.top, AppSpacing.md)
                            .padding(.bottom, AppSpacing.xs)

                        ForEach(group.sessions) { session in
                            sessionRow(session)
                        }
                    }
                }
            }
        }
    }

    private func sessionRow(_ session: BreathSession) -> some View {
        let technique = BreathTechnique.allTechniques.first { $0.id == session.techniqueId }
        return HStack {
            Circle()
                .fill(AppColors.accent)
                .frame(width: 8, height: 8)
            Text(technique?.name ?? "Session")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text("\(session.formattedDuration) \u{00B7} \(session.formattedTime)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - Streak Calendar View

struct StreakCalendarView: View {
    let sessionDays: [Date: Double]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 4) {
            // Day of week headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(height: 20)
                }
            }

            // Day cells
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth(), id: \.self) { day in
                    if let day {
                        dayCellView(for: day)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
    }

    private func dayCellView(for date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let startOfDay = calendar.startOfDay(for: date)
        let minutes = sessionDays[startOfDay] ?? 0
        let hasSession = minutes > 0
        let isFuture = date > Date()

        return ZStack {
            if hasSession {
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppColors.accent.opacity(min(0.3 + minutes / 10.0 * 0.7, 1.0)))
            } else if isToday {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppColors.accent, lineWidth: 1.5)
            } else if !isFuture {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppColors.border, lineWidth: 0.5)
            }

            Text("\(calendar.component(.day, from: date))")
                .font(AppTypography.caption)
                .foregroundStyle(isFuture ? AppColors.textTertiary.opacity(0.3) : AppColors.textPrimary)
        }
        .frame(height: 36)
    }

    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        // Get weekday of first day (1 = Sunday, 2 = Monday, ... 7 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        // Convert to Monday-based offset (Monday = 0)
        let mondayOffset = (firstWeekday + 5) % 7

        let range = calendar.range(of: .day, in: .month, for: now)!

        var days: [Date?] = Array(repeating: nil, count: mondayOffset)
        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: startOfMonth) {
                days.append(date)
            }
        }
        // Pad to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }
}
#endif
