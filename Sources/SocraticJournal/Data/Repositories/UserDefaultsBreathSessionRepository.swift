// UserDefaultsBreathSessionRepository.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-based implementation of BreathSessionRepositoryProtocol
public final class UserDefaultsBreathSessionRepository: BreathSessionRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let sessionsKey = "com.breathe.sessions"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - BreathSessionRepositoryProtocol

    public func saveSession(_ session: BreathSession) async throws {
        var sessions = try await getAllSessions()
        sessions.append(session)
        let data = try encoder.encode(sessions)
        defaults.set(data, forKey: sessionsKey)
    }

    public func getSessionsForDate(_ date: Date) async throws -> [BreathSession] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return try await getSessionsForDateRange(from: startOfDay, to: endOfDay)
    }

    public func getSessionsForDateRange(from startDate: Date, to endDate: Date) async throws -> [BreathSession] {
        let sessions = try await getAllSessions()
        return sessions.filter { $0.startedAt >= startDate && $0.startedAt < endDate }
    }

    public func getTotalMinutesToday() async throws -> Double {
        let todaySessions = try await getSessionsForDate(Date())
        return todaySessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    public func getStreak() async throws -> Int {
        let sessions = try await getAllSessions()
        guard !sessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get unique dates with sessions
        let sessionDates = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })

        // Count consecutive days backwards from today (or yesterday for grace period)
        var streak = 0
        var checkDate = today

        // If no session today, check if yesterday had one (1-day grace)
        if !sessionDates.contains(today) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if sessionDates.contains(yesterday) {
                // Grace period: streak is still alive but don't count today
                checkDate = yesterday
            } else {
                return 0
            }
        }

        while sessionDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    public func getBestStreak() async throws -> Int {
        let sessions = try await getAllSessions()
        guard !sessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sessionDates = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
            .sorted()

        guard !sessionDates.isEmpty else { return 0 }

        var bestStreak = 1
        var currentStreak = 1

        for i in 1..<sessionDates.count {
            let dayDiff = calendar.dateComponents([.day], from: sessionDates[i - 1], to: sessionDates[i]).day ?? 0
            if dayDiff == 1 {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else if dayDiff > 1 {
                currentStreak = 1
            }
        }

        return bestStreak
    }

    public func getTotalMinutesAllTime() async throws -> Double {
        let sessions = try await getAllSessions()
        return sessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    public func getTotalSessionCount() async throws -> Int {
        let sessions = try await getAllSessions()
        return sessions.count
    }

    // MARK: - Private

    private func getAllSessions() async throws -> [BreathSession] {
        guard let data = defaults.data(forKey: sessionsKey) else { return [] }
        do {
            return try decoder.decode([BreathSession].self, from: data)
        } catch {
            return []
        }
    }
}
