// ProgressViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Progress & History view
@Observable
@MainActor
public final class ProgressViewModel {
    // MARK: - State

    private(set) var totalMinutes: Double = 0
    private(set) var totalSessions: Int = 0
    private(set) var averagePerDay: Double = 0
    private(set) var weeklyMinutes: [DayMinutes] = []
    private(set) var patternStats: [PatternStat] = []
    private(set) var dateGroups: [DateGroup] = []
    private(set) var recentSessions: [BreathSession] = []
    private(set) var dailyGoalMinutes: Int = 5
    private(set) var boltScores: [BOLTScore] = []
    private(set) var isLoading: Bool = false

    // MARK: - Types

    struct DayMinutes: Identifiable {
        let id: Int // 0-6 for S-M-T-W-T-F-S
        let label: String
        let minutes: Double
        let isToday: Bool
        let date: Date
    }

    struct PatternStat: Identifiable {
        let id: String // patternId
        let name: String
        let colorHex: String
        let count: Int
        let percentage: Int
    }

    struct DateGroup: Identifiable {
        let id: String // date string
        let label: String
        let sessions: [BreathSession]
    }

    // MARK: - Dependencies

    private let sessionRepository: BreathSessionRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    // MARK: - Init

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.settingsRepository = settingsRepository
    }

    // MARK: - Actions

    func loadData() async {
        isLoading = true
        do {
            let settings = try await settingsRepository.getSettings()
            dailyGoalMinutes = settings.dailyGoalMinutes

            let allSessions = try await sessionRepository.getAllSessions()
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            // 7-day window
            guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else { return }
            let weekSessions = allSessions.filter { $0.startedAt >= weekStart }

            // Summary stats
            totalMinutes = weekSessions.reduce(0) { $0 + $1.totalDuration } / 60.0
            totalSessions = weekSessions.count
            averagePerDay = totalMinutes / 7.0

            // Weekly bar chart data
            weeklyMinutes = buildWeeklyMinutes(sessions: allSessions, today: today, calendar: calendar)

            // Pattern distribution (last 7 days)
            patternStats = buildPatternStats(sessions: weekSessions)

            // Session history (last 30 sessions grouped, last 3 for summary)
            let last30 = Array(allSessions.prefix(30))
            dateGroups = buildDateGroups(sessions: last30, calendar: calendar, today: today)
            recentSessions = Array(allSessions.prefix(3))

            // BOLT score history
            boltScores = try await sessionRepository.getBOLTScores()
        } catch {
            // Degrade gracefully
        }
        isLoading = false
    }

    // MARK: - Builders

    private func buildWeeklyMinutes(sessions: [BreathSession], today: Date, calendar: Calendar) -> [DayMinutes] {
        let labels = ["S", "M", "T", "W", "T", "F", "S"]

        // Find the Sunday of the current week
        let weekday = calendar.component(.weekday, from: today) // 1=Sun
        let sundayOffset = -(weekday - 1)
        guard let sunday = calendar.date(byAdding: .day, value: sundayOffset, to: today) else { return [] }

        return (0..<7).map { dayIndex in
            let date = calendar.date(byAdding: .day, value: dayIndex, to: sunday)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let dayMinutes = sessions
                .filter { $0.startedAt >= startOfDay && $0.startedAt < endOfDay }
                .reduce(0.0) { $0 + $1.totalDuration } / 60.0

            return DayMinutes(
                id: dayIndex,
                label: labels[dayIndex],
                minutes: dayMinutes,
                isToday: calendar.isDateInToday(date),
                date: date
            )
        }
    }

    private func buildPatternStats(sessions: [BreathSession]) -> [PatternStat] {
        guard !sessions.isEmpty else { return [] }

        var counts: [String: Int] = [:]
        for session in sessions {
            counts[session.patternId, default: 0] += 1
        }

        let total = sessions.count
        return counts
            .sorted { $0.value > $1.value }
            .map { patternId, count in
                let pattern = BreathPattern.allPatterns.first { $0.id == patternId }
                return PatternStat(
                    id: patternId,
                    name: pattern?.name ?? patternId,
                    colorHex: pattern?.tagColorHex ?? "2D5F5D",
                    count: count,
                    percentage: Int(round(Double(count) / Double(total) * 100))
                )
            }
    }

    private func buildDateGroups(sessions: [BreathSession], calendar: Calendar, today: Date) -> [DateGroup] {
        guard !sessions.isEmpty else { return [] }

        var grouped: [(Date, [BreathSession])] = []
        var currentDate: Date?
        var currentGroup: [BreathSession] = []

        for session in sessions {
            let sessionDay = calendar.startOfDay(for: session.startedAt)
            if sessionDay == currentDate {
                currentGroup.append(session)
            } else {
                if let date = currentDate, !currentGroup.isEmpty {
                    grouped.append((date, currentGroup))
                }
                currentDate = sessionDay
                currentGroup = [session]
            }
        }
        if let date = currentDate, !currentGroup.isEmpty {
            grouped.append((date, currentGroup))
        }

        return grouped.map { date, sessions in
            DateGroup(
                id: date.timeIntervalSince1970.description,
                label: dateGroupLabel(for: date, calendar: calendar, today: today),
                sessions: sessions
            )
        }
    }

    private func dateGroupLabel(for date: Date, calendar: Calendar, today: Date) -> String {
        if calendar.isDateInToday(date) { return "TODAY" }
        if calendar.isDateInYesterday(date) { return "YESTERDAY" }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date).uppercased()
    }

    func patternName(for patternId: String) -> String {
        BreathPattern.allPatterns.first { $0.id == patternId }?.name ?? patternId
    }

    func patternInitial(for patternId: String) -> String {
        let name = patternName(for: patternId)
        return String(name.prefix(1))
    }

    func sessionDurationFormatted(_ session: BreathSession) -> String {
        let totalSeconds = Int(session.totalDuration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if seconds == 0 {
            return "\(minutes) min"
        }
        return "\(minutes) min \(seconds)s"
    }

    func sessionTimeFormatted(_ session: BreathSession) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: session.startedAt)
    }
}
#endif
