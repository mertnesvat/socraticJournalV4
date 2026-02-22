// MockStreakRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of StreakRepositoryProtocol
/// Tracks answer streaks in memory starting from 0
public final class MockStreakRepository: StreakRepositoryProtocol, @unchecked Sendable {
    private let userId = "user-current"
    private var streak: AnswerStreak
    private var history: [AnswerStreak] = []

    public init() {
        self.streak = AnswerStreak(userId: "user-current")
    }

    // MARK: - StreakRepositoryProtocol

    public func getCurrentStreak() async -> AnswerStreak {
        return streak
    }

    public func recordAnswer() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if already answered today
        if let lastDate = streak.lastAnswerDate,
           calendar.startOfDay(for: lastDate) == today {
            return
        }

        // Check if streak continues from yesterday
        let isConsecutive: Bool
        if let lastDate = streak.lastAnswerDate {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            isConsecutive = calendar.startOfDay(for: lastDate) == yesterday
        } else {
            isConsecutive = false
        }

        if isConsecutive {
            streak.currentStreak += 1
        } else {
            // Save previous streak to history if it was meaningful
            if streak.currentStreak > 0 {
                history.append(streak)
            }
            streak.currentStreak = 1
            streak.streakStartDate = today
        }

        streak.lastAnswerDate = today
        if streak.currentStreak > streak.longestStreak {
            streak.longestStreak = streak.currentStreak
        }
    }

    public func getStreakHistory() async -> [AnswerStreak] {
        return history
    }
}
