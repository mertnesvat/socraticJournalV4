// UserDefaultsSessionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-based implementation of SessionRepositoryProtocol
public final class UserDefaultsSessionRepository: SessionRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let sessionsKey = "com.socraticjournal.sessions"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - SessionRepositoryProtocol

    public func saveSession(_ session: BreathSession) async throws {
        var sessions = try await getAllSessions()
        sessions.insert(session, at: 0) // Most recent first
        let data = try encoder.encode(sessions)
        defaults.set(data, forKey: sessionsKey)
    }

    public func getAllSessions() async throws -> [BreathSession] {
        guard let data = defaults.data(forKey: sessionsKey) else {
            return []
        }
        do {
            return try decoder.decode([BreathSession].self, from: data)
        } catch {
            return []
        }
    }

    public func getSessions(for date: Date) async throws -> [BreathSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let sessions = try await getAllSessions()
        return sessions.filter { calendar.startOfDay(for: $0.startTime) == startOfDay }
    }

    public func getTodaySessions() async throws -> [BreathSession] {
        try await getSessions(for: Date())
    }

    public func getSessionCount() async throws -> Int {
        let sessions = try await getAllSessions()
        return sessions.count
    }

    public func clearAllSessions() async throws {
        defaults.removeObject(forKey: sessionsKey)
    }
}
