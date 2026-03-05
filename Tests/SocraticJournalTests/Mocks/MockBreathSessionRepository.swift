// MockBreathSessionRepository.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock breath session repository for testing
public final class MockBreathSessionRepository: BreathSessionRepositoryProtocol, @unchecked Sendable {
    // MARK: - State

    public var sessions: [BreathSession] = []
    public var shouldFail: Bool = false
    public var failError: Error = NSError(domain: "MockError", code: -1)
    public var streakValue: Int = 0

    // MARK: - Call Tracking

    public private(set) var saveSessionCalled: Bool = false
    public private(set) var saveSessionCallCount: Int = 0
    public private(set) var lastSavedSession: BreathSession?

    // MARK: - Init

    public init(sessions: [BreathSession] = []) {
        self.sessions = sessions
    }

    // MARK: - Protocol Methods

    public func saveSession(_ session: BreathSession) async throws {
        saveSessionCalled = true
        saveSessionCallCount += 1
        lastSavedSession = session

        if shouldFail { throw failError }

        sessions.append(session)
    }

    public func getSessionsForDate(_ date: Date) async throws -> [BreathSession] {
        if shouldFail { throw failError }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return sessions.filter { $0.startedAt >= startOfDay && $0.startedAt < endOfDay }
    }

    public func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession] {
        if shouldFail { throw failError }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: from)
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!
        return sessions.filter { $0.startedAt >= start && $0.startedAt < end }
    }

    public func getTotalMinutesToday() async throws -> Double {
        if shouldFail { throw failError }

        let todaySessions = try await getSessionsForDate(Date())
        return todaySessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    public func getStreak() async throws -> Int {
        if shouldFail { throw failError }
        return streakValue
    }

    // MARK: - All Sessions

    public func getAllSessions() async throws -> [BreathSession] {
        if shouldFail { throw failError }
        return sessions.sorted { $0.startedAt > $1.startedAt }
    }

    // MARK: - BOLT Score

    public var boltScores: [BOLTScore] = []

    public func saveBOLTScore(_ score: BOLTScore) async throws {
        if shouldFail { throw failError }
        boltScores.append(score)
    }

    public func getBOLTScores() async throws -> [BOLTScore] {
        if shouldFail { throw failError }
        return boltScores
    }

    public func getLatestBOLTScore() async throws -> BOLTScore? {
        if shouldFail { throw failError }
        return boltScores.max(by: { $0.recordedAt < $1.recordedAt })
    }

    // MARK: - Test Helpers

    public func reset() {
        sessions = []
        shouldFail = false
        streakValue = 0
        saveSessionCalled = false
        saveSessionCallCount = 0
        lastSavedSession = nil
        boltScores = []
    }
}
