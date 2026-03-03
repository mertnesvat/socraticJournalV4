// StreakCalculator.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Calculates streak and weekly stats from session history
public struct StreakCalculator: Sendable {

    /// Streak state information
    public struct StreakInfo: Sendable, Equatable {
        public let currentStreak: Int
        public let longestStreak: Int
        public let isAtRisk: Bool   // grace window active
        public let lastSessionDate: Date?
    }

    /// Weekly progress information
    public struct WeeklyProgress: Sendable, Equatable {
        public let minutesCompleted: Int
        public let goalMinutes: Int
        public let sessionsThisWeek: Int

        public var progress: Double {
            guard goalMinutes > 0 else { return 0 }
            return min(Double(minutesCompleted) / Double(goalMinutes), 1.0)
        }
    }

    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    // MARK: - Streak Calculation

    /// Calculate current streak from session history
    /// Uses 1-day grace window: missing one day puts streak "at risk" but does not break it
    public func calculateStreak(from sessions: [BreathSession]) -> StreakInfo {
        // Get unique dates with qualifying sessions (>= 60 seconds)
        let qualifyingDates = uniqueDates(from: sessions.filter { $0.countsForStreak })
        guard !qualifyingDates.isEmpty else {
            return StreakInfo(currentStreak: 0, longestStreak: 0, isAtRisk: false, lastSessionDate: nil)
        }

        let sortedDates = qualifyingDates.sorted(by: >)  // most recent first
        let today = calendar.startOfDay(for: Date())
        let longest = calculateLongestStreak(dates: Set(qualifyingDates))

        // Check if the most recent session was today or yesterday
        guard let mostRecent = sortedDates.first else {
            return StreakInfo(currentStreak: 0, longestStreak: longest, isAtRisk: false, lastSessionDate: nil)
        }

        let daysSinceLast = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0

        if daysSinceLast > 2 {
            // More than 2 days gap -- streak is broken
            return StreakInfo(currentStreak: 0, longestStreak: longest, isAtRisk: false, lastSessionDate: mostRecent)
        }

        let isAtRisk = daysSinceLast == 2  // missed yesterday, grace window today
        let isGrace = daysSinceLast == 1    // did yesterday but not today yet (normal)

        // Count consecutive days backwards from most recent session date
        var streak = 1
        var previousDate = mostRecent

        for date in sortedDates.dropFirst() {
            let daysBetween = calendar.dateComponents([.day], from: date, to: previousDate).day ?? 0
            if daysBetween == 1 {
                streak += 1
                previousDate = date
            } else if daysBetween == 2 {
                // One gap day (grace window consumed in the past)
                streak += 1
                previousDate = date
            } else {
                break
            }
        }

        // If today has no session but yesterday does, streak is still valid (grace)
        // If two days ago was last session, streak is "at risk"
        return StreakInfo(
            currentStreak: streak,
            longestStreak: max(longest, streak),
            isAtRisk: isAtRisk,
            lastSessionDate: mostRecent
        )
    }

    // MARK: - Weekly Goal

    /// Calculate weekly progress (week starts Sunday)
    public func calculateWeeklyProgress(from sessions: [BreathSession], goalMinutes: Int) -> WeeklyProgress {
        let today = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return WeeklyProgress(minutesCompleted: 0, goalMinutes: goalMinutes, sessionsThisWeek: 0)
        }

        let weekSessions = sessions.filter { $0.startTime >= weekStart }
        let totalSeconds = weekSessions.reduce(0.0) { $0 + $1.totalDurationSeconds }
        let totalMinutes = Int(totalSeconds / 60)

        return WeeklyProgress(
            minutesCompleted: totalMinutes,
            goalMinutes: goalMinutes,
            sessionsThisWeek: weekSessions.count
        )
    }

    // MARK: - Total Stats

    /// Calculate total minutes breathed all time
    public func totalMinutes(from sessions: [BreathSession]) -> Int {
        let totalSeconds = sessions.reduce(0.0) { $0 + $1.totalDurationSeconds }
        return Int(totalSeconds / 60)
    }

    // MARK: - Helpers

    private func uniqueDates(from sessions: [BreathSession]) -> [Date] {
        let dateSet = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        return Array(dateSet)
    }

    private func calculateLongestStreak(dates: Set<Date>) -> Int {
        guard !dates.isEmpty else { return 0 }
        let sortedDates = dates.sorted()
        var longest = 1
        var current = 1

        for i in 1..<sortedDates.count {
            let daysBetween = calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            if daysBetween == 1 {
                current += 1
                longest = max(longest, current)
            } else if daysBetween > 1 {
                current = 1
            }
        }
        return longest
    }
}
