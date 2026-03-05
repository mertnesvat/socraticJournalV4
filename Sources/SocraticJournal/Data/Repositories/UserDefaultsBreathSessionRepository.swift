// UserDefaultsBreathSessionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-backed implementation of BreathSessionRepositoryProtocol
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
        let allSessions = try await getAllSessions()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return allSessions.filter { $0.startedAt >= startOfDay && $0.startedAt < endOfDay }
    }

    public func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession] {
        let allSessions = try await getAllSessions()
        let start = Calendar.current.startOfDay(for: from)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: to))!
        return allSessions.filter { $0.startedAt >= start && $0.startedAt < end }
    }

    public func getTotalMinutesToday() async throws -> Double {
        let todaySessions = try await getSessionsForDate(Date())
        return todaySessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    public func getStreak() async throws -> Int {
        let allSessions = try await getAllSessions()
        guard !allSessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasSession = allSessions.contains { session in
                calendar.isDate(session.startedAt, inSameDayAs: checkDate)
            }

            if hasSession {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Aggregate Queries

    public func getAllSessions() async throws -> [BreathSession] {
        guard let data = defaults.data(forKey: sessionsKey) else { return [] }
        do {
            return try decoder.decode([BreathSession].self, from: data)
        } catch {
            return []
        }
    }

    public func getTotalMinutes() async throws -> Double {
        let sessions = try await getAllSessions()
        return sessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    public func getTotalSessions() async throws -> Int {
        let sessions = try await getAllSessions()
        return sessions.count
    }

    public func getLongestStreak() async throws -> Int {
        let allSessions = try await getAllSessions()
        guard !allSessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueDays = Set(allSessions.map { calendar.startOfDay(for: $0.startedAt) })
        let sortedDays = uniqueDays.sorted()

        var longest = 1
        var current = 1

        for i in 1..<sortedDays.count {
            let diff = calendar.dateComponents([.day], from: sortedDays[i - 1], to: sortedDays[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }

    public func getSessionsByPattern() async throws -> [String: [BreathSession]] {
        let sessions = try await getAllSessions()
        return Dictionary(grouping: sessions, by: { $0.patternId })
    }

    public func getSessionsForMonth(year: Int, month: Int) async throws -> [BreathSession] {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = month
        startComponents.day = 1

        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return []
        }

        let allSessions = try await getAllSessions()
        return allSessions.filter { $0.startedAt >= startDate && $0.startedAt < endDate }
    }

}
