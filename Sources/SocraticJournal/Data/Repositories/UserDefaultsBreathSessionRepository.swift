// UserDefaultsBreathSessionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-based implementation of BreathSessionRepositoryProtocol
public final class UserDefaultsBreathSessionRepository: BreathSessionRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let sessionsKey = "breath.sessions"
    private let calendar = Calendar.current

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - BreathSessionRepositoryProtocol

    public func saveSession(_ session: BreathSession) async throws {
        var sessions = try loadSessions()
        sessions.append(session)
        let data = try encoder.encode(sessions)
        defaults.set(data, forKey: sessionsKey)
    }

    public func getSessions(for date: Date) async throws -> [BreathSession] {
        let sessions = try loadSessions()
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        return sessions.filter { session in
            session.startedAt >= startOfDay && session.startedAt < endOfDay
        }
    }

    public func getAllSessions() async throws -> [BreathSession] {
        try loadSessions()
    }

    public func getSessionsInRange(from startDate: Date, to endDate: Date) async throws -> [BreathSession] {
        let sessions = try loadSessions()
        let start = calendar.startOfDay(for: startDate)
        guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) else {
            return []
        }
        return sessions.filter { session in
            session.startedAt >= start && session.startedAt < end
        }
    }

    public func getCurrentStreak() async throws -> Int {
        let sessions = try loadSessions()
        let completedSessions = sessions.filter { $0.isCompleted }

        guard !completedSessions.isEmpty else { return 0 }

        // Collect unique calendar days with completed sessions
        var daysWithSessions = Set<Date>()
        for session in completedSessions {
            let day = calendar.startOfDay(for: session.startedAt)
            daysWithSessions.insert(day)
        }

        // Count consecutive days backwards from today
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        while daysWithSessions.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    public func getTotalMinutesBreathed() async throws -> Double {
        let sessions = try loadSessions()
        let totalSeconds = sessions.reduce(0.0) { $0 + $1.actualDuration }
        return totalSeconds / 60.0
    }

    public func getTotalSessions() async throws -> Int {
        let sessions = try loadSessions()
        return sessions.count
    }

    // MARK: - Private

    private func loadSessions() throws -> [BreathSession] {
        guard let data = defaults.data(forKey: sessionsKey) else {
            return []
        }
        do {
            return try decoder.decode([BreathSession].self, from: data)
        } catch {
            // If decoding fails, return empty array
            return []
        }
    }
}
