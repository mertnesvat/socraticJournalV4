// BreathSessionRepositoryTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("BreathSessionRepository Tests")
struct BreathSessionRepositoryTests {

    private func makeSUT() -> UserDefaultsBreathSessionRepository {
        let suiteName = "com.breathe.tests.\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        return UserDefaultsBreathSessionRepository(defaults: suite)
    }

    private func makeSession(
        patternId: String = "resonance",
        startedAt: Date = Date(),
        duration: TimeInterval = 300,
        cycles: Int = 27
    ) -> BreathSession {
        BreathSession(
            patternId: patternId,
            startedAt: startedAt,
            completedAt: startedAt.addingTimeInterval(duration),
            totalDuration: duration,
            cyclesCompleted: cycles
        )
    }

    @Test("Save and retrieve session for same date")
    func saveAndRetrieve() async throws {
        let repo = makeSUT()
        let now = Date()
        let session = makeSession(startedAt: now)

        try await repo.saveSession(session)
        let retrieved = try await repo.getSessionsForDate(now)

        #expect(retrieved.count == 1)
        #expect(retrieved.first?.id == session.id)
    }

    @Test("getSessionsForDate returns only sessions for that day")
    func sessionsFilteredByDate() async throws {
        let repo = makeSUT()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todaySession = makeSession(startedAt: today)
        let yesterdaySession = makeSession(patternId: "box", startedAt: yesterday)

        try await repo.saveSession(todaySession)
        try await repo.saveSession(yesterdaySession)

        let todaySessions = try await repo.getSessionsForDate(today)
        let yesterdaySessions = try await repo.getSessionsForDate(yesterday)

        #expect(todaySessions.count == 1)
        #expect(todaySessions.first?.id == todaySession.id)
        #expect(yesterdaySessions.count == 1)
        #expect(yesterdaySessions.first?.id == yesterdaySession.id)
    }

    @Test("getSessionsForDateRange returns correct range")
    func sessionsForDateRange() async throws {
        let repo = makeSUT()
        let calendar = Calendar.current
        let today = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        let session1 = makeSession(startedAt: today)
        let session2 = makeSession(startedAt: twoDaysAgo)
        let session3 = makeSession(startedAt: threeDaysAgo)

        try await repo.saveSession(session1)
        try await repo.saveSession(session2)
        try await repo.saveSession(session3)

        // Range: twoDaysAgo..today — should include session1 and session2 but not session3
        let rangeSessions = try await repo.getSessionsForDateRange(from: twoDaysAgo, to: today)
        #expect(rangeSessions.count == 2)
    }

    @Test("getTotalMinutesToday sums correctly")
    func totalMinutesToday() async throws {
        let repo = makeSUT()
        let now = Date()

        // Two 5-minute sessions today
        try await repo.saveSession(makeSession(startedAt: now, duration: 300))
        try await repo.saveSession(makeSession(startedAt: now.addingTimeInterval(600), duration: 300))

        let totalMinutes = try await repo.getTotalMinutesToday()
        #expect(totalMinutes == 10.0)
    }

    @Test("getStreak returns 0 with no sessions")
    func streakWithNoSessions() async throws {
        let repo = makeSUT()
        let streak = try await repo.getStreak()
        #expect(streak == 0)
    }

    @Test("getStreak returns 1 when today has a session")
    func streakWithTodaySession() async throws {
        let repo = makeSUT()
        try await repo.saveSession(makeSession(startedAt: Date()))
        let streak = try await repo.getStreak()
        #expect(streak == 1)
    }

    @Test("Streak counts consecutive days")
    func streakConsecutiveDays() async throws {
        let repo = makeSUT()
        let calendar = Calendar.current
        let today = Date()

        // Sessions on today, yesterday, and 2 days ago
        try await repo.saveSession(makeSession(startedAt: today))
        try await repo.saveSession(makeSession(startedAt: calendar.date(byAdding: .day, value: -1, to: today)!))
        try await repo.saveSession(makeSession(startedAt: calendar.date(byAdding: .day, value: -2, to: today)!))

        let streak = try await repo.getStreak()
        #expect(streak == 3)
    }
}
