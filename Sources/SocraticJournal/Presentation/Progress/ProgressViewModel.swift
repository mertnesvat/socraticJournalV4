// ProgressViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// ViewModel for the Progress / Session History screen
@Observable
@MainActor
public final class ProgressViewModel {
    // MARK: - Lifetime Stats State

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

    // MARK: - Monthly Heatmap State

    private(set) var displayedMonth: Date = Date()
    private(set) var monthlyDayData: [DayCell] = []

    // MARK: - Pattern Breakdown State

    private(set) var patternBreakdown: [PatternStat] = []

    // MARK: - Types

    struct DayBar: Identifiable {
        let id: Int
        let label: String
        let minutes: Double
        let isToday: Bool
    }

    struct DayCell: Identifiable {
        let id: String
        let day: Int
        let isCurrentMonth: Bool
        let isToday: Bool
        let totalMinutes: Double

        var intensity: HeatIntensity {
            if totalMinutes <= 0 { return .none }
            if totalMinutes < 5 { return .light }
            if totalMinutes < 15 { return .moderate }
            return .deep
        }
    }

    enum HeatIntensity {
        case none
        case light
        case moderate
        case deep
    }

    struct PatternStat: Identifiable {
        let id: String
        let patternId: String
        let patternName: String
        let tagColorHex: String
        let totalMinutes: Double
        let sessionCount: Int
        /// Proportion of total minutes relative to the most-used pattern (0...1)
        let proportion: Double
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
            try await loadMonthData()
            try await loadPatternBreakdown()
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func navigateMonth(by offset: Int) async {
        let calendar = Calendar.current
        guard let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else { return }
        displayedMonth = newMonth
        do {
            try await loadMonthData()
        } catch {
            self.error = error
        }
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

    var displayedMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    // MARK: - Private — Weekly Bars

    private func buildWeeklyBars() async throws -> [DayBar] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the start of the current week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1=Sun, 2=Mon, ... 7=Sat
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

    // MARK: - Private — Monthly Heatmap

    private func loadMonthData() async throws {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: displayedMonth)
        let month = calendar.component(.month, from: displayedMonth)

        let sessions = try await sessionRepository.getSessionsForMonth(year: year, month: month)

        // Build a dictionary of day -> total minutes
        var minutesByDay: [Int: Double] = [:]
        for session in sessions {
            let day = calendar.component(.day, from: session.startedAt)
            minutesByDay[day, default: 0] += session.totalDuration / 60.0
        }

        // Determine calendar layout
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let firstOfMonth = calendar.date(from: components) else {
            monthlyDayData = []
            return
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30
        // weekday: 1=Sun ... 7=Sat  ->  we want S M T W T F S (Sun=0)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1-based, Sunday=1
        let leadingBlanks = firstWeekday - 1 // Sunday-based grid: S=0 blanks, M=1 blank, etc.

        let today = Date()
        let todayDay = calendar.component(.day, from: today)
        let todayMonth = calendar.component(.month, from: today)
        let todayYear = calendar.component(.year, from: today)
        let isCurrentMonth = (year == todayYear && month == todayMonth)

        var cells: [DayCell] = []

        // Leading blank cells
        for i in 0..<leadingBlanks {
            cells.append(DayCell(
                id: "blank-\(i)",
                day: 0,
                isCurrentMonth: false,
                isToday: false,
                totalMinutes: 0
            ))
        }

        // Day cells
        for day in 1...daysInMonth {
            cells.append(DayCell(
                id: "\(year)-\(month)-\(day)",
                day: day,
                isCurrentMonth: true,
                isToday: isCurrentMonth && day == todayDay,
                totalMinutes: minutesByDay[day] ?? 0
            ))
        }

        monthlyDayData = cells
    }

    // MARK: - Private — Pattern Breakdown

    private func loadPatternBreakdown() async throws {
        let grouped = try await sessionRepository.getSessionsByPattern()

        let allPatterns = BreathPattern.allPatterns
        let patternMap = Dictionary(uniqueKeysWithValues: allPatterns.map { ($0.id, $0) })

        var stats: [(id: String, name: String, colorHex: String, minutes: Double, count: Int)] = []

        for (patternId, sessions) in grouped {
            let pattern = patternMap[patternId]
            let name = pattern?.name ?? patternId
            let colorHex = pattern?.tagColorHex ?? "2D5F5D"
            let minutes = sessions.reduce(0.0) { $0 + $1.totalDuration } / 60.0
            stats.append((id: patternId, name: name, colorHex: colorHex, minutes: minutes, count: sessions.count))
        }

        // Sort by total minutes descending
        stats.sort { $0.minutes > $1.minutes }

        let maxMinutes = stats.first?.minutes ?? 1.0

        patternBreakdown = stats.map { stat in
            PatternStat(
                id: stat.id,
                patternId: stat.id,
                patternName: stat.name,
                tagColorHex: stat.colorHex,
                totalMinutes: stat.minutes,
                sessionCount: stat.count,
                proportion: maxMinutes > 0 ? stat.minutes / maxMinutes : 0
            )
        }
    }
}
