// ProgressDashboardViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Progress tab
@Observable
@MainActor
public final class ProgressDashboardViewModel {
    // MARK: - State

    private(set) var totalMinutes: Double = 0
    private(set) var totalSessions: Int = 0
    private(set) var bestStreak: Int = 0
    private(set) var monthSessions: [Date: Double] = [:] // date → minutes
    private(set) var recentSessions: [(date: String, sessions: [BreathSession])] = []
    private(set) var isLoading: Bool = false

    private let sessionRepository: BreathSessionRepositoryProtocol

    public init(sessionRepository: BreathSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    public func loadData() async {
        isLoading = true

        do {
            totalMinutes = try await sessionRepository.getTotalMinutesAllTime()
            totalSessions = try await sessionRepository.getTotalSessionCount()
            bestStreak = try await sessionRepository.getBestStreak()

            // Load this month's sessions for heatmap
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let monthSessionList = try await sessionRepository.getSessionsForDateRange(from: startOfMonth, to: endOfMonth)

            var dayMinutes: [Date: Double] = [:]
            for session in monthSessionList {
                let day = calendar.startOfDay(for: session.startedAt)
                dayMinutes[day, default: 0] += session.totalDuration / 60.0
            }
            monthSessions = dayMinutes

            // Load recent sessions (last 30 days) grouped by date
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
            let allRecent = try await sessionRepository.getSessionsForDateRange(from: thirtyDaysAgo, to: now)
            let grouped = Dictionary(grouping: allRecent) { session in
                calendar.startOfDay(for: session.startedAt)
            }

            let formatter = DateFormatter()
            let today = calendar.startOfDay(for: now)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            recentSessions = grouped.keys.sorted(by: >).map { date in
                let label: String
                if calendar.isDate(date, inSameDayAs: today) {
                    label = "Today"
                } else if calendar.isDate(date, inSameDayAs: yesterday) {
                    label = "Yesterday"
                } else {
                    formatter.dateFormat = "EEEE, d MMM"
                    label = formatter.string(from: date)
                }
                return (date: label, sessions: grouped[date]!.sorted { $0.startedAt > $1.startedAt })
            }
        } catch {
            // Fail silently
        }

        isLoading = false
    }
}
#endif
