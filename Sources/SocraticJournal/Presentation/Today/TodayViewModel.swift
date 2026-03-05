// TodayViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Today dashboard tab
@Observable
@MainActor
public final class TodayViewModel {
    // MARK: - State

    private(set) var streak: Int = 0
    private(set) var todaySessions: [BreathSession] = []
    private(set) var totalMinutesToday: Double = 0
    private(set) var weekDays: [WeekDay] = []
    private(set) var dailyGoalMinutes: Int = 5
    private(set) var isLoading: Bool = false
    private(set) var latestBOLTScore: BOLTScore?

    var goalReached: Bool {
        totalMinutesToday >= Double(dailyGoalMinutes)
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning." }
        if hour < 17 { return "Good afternoon." }
        return "Good evening."
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
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
            streak = try await sessionRepository.getStreak()
            todaySessions = try await sessionRepository.getSessionsForDate(Date())
            totalMinutesToday = try await sessionRepository.getTotalMinutesToday()
            let settings = try await settingsRepository.getSettings()
            dailyGoalMinutes = settings.dailyGoalMinutes
            latestBOLTScore = try await sessionRepository.getLatestBOLTScore()
            weekDays = buildWeekDays()
        } catch {
            // Silently handle — dashboard degrades gracefully
        }
        isLoading = false
    }

    // MARK: - Week Days

    struct WeekDay: Identifiable {
        let id: Int
        let label: String
        let completed: Bool
        let isToday: Bool
        let isFuture: Bool
    }

    private func buildWeekDays() -> [WeekDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) // 1=Sun
        let sundayOffset = -(weekday - 1)

        return (0..<7).map { dayIndex in
            let date = calendar.date(byAdding: .day, value: sundayOffset + dayIndex, to: today)!
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today
            let labels = ["S", "M", "T", "W", "T", "F", "S"]

            // Check if there were sessions on this day
            let hasSessions = !isFuture && todaySessions.isEmpty == false && isToday
                ? goalReached
                : !isFuture && !isToday // Simplified — mark past days before today as completed for streak continuity

            return WeekDay(
                id: dayIndex,
                label: labels[dayIndex],
                completed: dayIndex < (weekday - 1) && streak > 0 && (weekday - 1 - dayIndex) <= streak,
                isToday: isToday,
                isFuture: isFuture
            )
        }
    }

    func patternName(for patternId: String) -> String {
        BreathPattern.allPatterns.first { $0.id == patternId }?.name ?? patternId
    }

    func sessionDurationFormatted(_ session: BreathSession) -> String {
        let minutes = Int(session.totalDuration) / 60
        return "\(minutes) min"
    }
}
#endif
