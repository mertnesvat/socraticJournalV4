// UserDefaultsBreathSessionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

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

    // MARK: - Private Helpers

    private func loadAllSessions() -> [BreathSession] {
        guard let data = defaults.data(forKey: sessionsKey) else { return [] }
        return (try? decoder.decode([BreathSession].self, from: data)) ?? []
    }

    private func saveAllSessions(_ sessions: [BreathSession]) throws {
        let data = try encoder.encode(sessions)
        defaults.set(data, forKey: sessionsKey)
    }

    // MARK: - Protocol

    func saveSession(_ session: BreathSession) async throws {
        var sessions = loadAllSessions()
        sessions.append(session)
        try saveAllSessions(sessions)
    }

    func getSessionsForDate(_ date: Date) async throws -> [BreathSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return loadAllSessions().filter { $0.startedAt >= startOfDay && $0.startedAt < endOfDay }
    }

    func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: from)
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!
        return loadAllSessions().filter { $0.startedAt >= start && $0.startedAt < end }
    }

    func getTotalMinutesToday() async throws -> Double {
        let todaySessions = try await getSessionsForDate(Date())
        return todaySessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    func getStreak() async throws -> Int {
        let calendar = Calendar.current
        let allSessions = loadAllSessions()

        guard !allSessions.isEmpty else { return 0 }

        // Group sessions by day
        var daysWithSessions = Set<Date>()
        for session in allSessions {
            daysWithSessions.insert(calendar.startOfDay(for: session.startedAt))
        }

        // Count consecutive days backwards from today
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while daysWithSessions.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }
}
