// ProgressViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Progress / Session History screen
@Observable
@MainActor
public final class ProgressViewModel {
    // MARK: - State

    private(set) var totalMinutes: Double = 0
    private(set) var totalSessions: Int = 0
    private(set) var longestStreak: Int = 0
    private(set) var weeklyBarData: [DayBar] = []
    private(set) var weeklyTotalMinutes: Double = 0
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    var isEmpty: Bool {
        totalSessions == 0
    }

    // MARK: - Types

    struct DayBar: Identifiable {
        let id: Int
        let label: String
        let minutes: Double
        let isToday: Bool
    }

    // MARK: - Dependencies

    private let sessionRepository: BreathSessionRepositoryProtocol

    // MARK: - Init

    public init(sessionRepository: BreathSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    // MARK: - Actions

    func loadData() async {
        isLoading = true
        error = nil
        do {
            totalMinutes = try await sessionRepository.getTotalMinutes()
            totalSessions = try await sessionRepository.getTotalSessions()
            longestStreak = try await sessionRepository.getLongestStreak()
            weeklyBarData = try await buildWeeklyBars()
            weeklyTotalMinutes = weeklyBarData.reduce(0) { $0 + $1.minutes }
        } catch {
            self.error = error
        }
        isLoading = false
    }

    // MARK: - Formatted Values

    var totalMinutesFormatted: String {
        if totalMinutes < 1 && totalMinutes > 0 {
            return "<1"
        }
        return "\(Int(totalMinutes))"
    }

    var weeklyMinutesFormatted: String {
        if weeklyTotalMinutes < 1 && weeklyTotalMinutes > 0 {
            return "<1"
        }
        return "\(Int(weeklyTotalMinutes))"
    }

    // MARK: - Private

    private func buildWeeklyBars() async throws -> [DayBar] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the start of the current week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1=Sun, 2=Mon, ... 7=Sat
        // We want Monday-based week
        let mondayOffset = weekday == 1 ? -6 : -(weekday - 2)
        guard let monday = calendar.date(byAdding: .day, value: mondayOffset, to: today) else {
            return []
        }

        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        var bars: [DayBar] = []

        for dayIndex in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: monday) else {
                continue
            }
            let sessions = try await sessionRepository.getSessionsForDate(date)
            let minutes = sessions.reduce(0) { $0 + $1.totalDuration } / 60.0
            let isToday = calendar.isDateInToday(date)

            bars.append(DayBar(
                id: dayIndex,
                label: labels[dayIndex],
                minutes: minutes,
                isToday: isToday
            ))
        }

        return bars
    }
}
#endif
