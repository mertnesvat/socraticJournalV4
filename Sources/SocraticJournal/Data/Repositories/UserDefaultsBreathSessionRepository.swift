// UserDefaultsBreathSessionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-backed implementation of BreathSessionRepositoryProtocol.
/// Defaults to the App Group shared suite so the widget extension can read session data.
public final class UserDefaultsBreathSessionRepository: BreathSessionRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let sessionsKey = "com.breathe.sessions"
    private let boltKey = "com.breathe.bolt"

    public init(defaults: UserDefaults = .appGroup) {
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

    // MARK: - BOLT Score

    public func saveBOLTScore(_ score: BOLTScore) async throws {
        var scores = try await getBOLTScores()
        scores.append(score)
        let data = try encoder.encode(scores)
        defaults.set(data, forKey: boltKey)
    }

    public func getBOLTScores() async throws -> [BOLTScore] {
        guard let data = defaults.data(forKey: boltKey) else { return [] }
        do {
            return try decoder.decode([BOLTScore].self, from: data)
        } catch {
            return []
        }
    }

    public func getLatestBOLTScore() async throws -> BOLTScore? {
        let scores = try await getBOLTScores()
        return scores.max(by: { $0.recordedAt < $1.recordedAt })
    }

    // MARK: - All Sessions

    public func getAllSessions() async throws -> [BreathSession] {
        guard let data = defaults.data(forKey: sessionsKey) else { return [] }
        do {
            return try decoder.decode([BreathSession].self, from: data)
                .sorted { $0.startedAt > $1.startedAt }
        } catch {
            return []
        }
    }
}
