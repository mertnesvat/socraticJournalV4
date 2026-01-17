// JournalStatsTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

struct JournalStatsTests {

    // MARK: - dateKey Tests

    @Test func testDateKeyFormat() {
        let date = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 15))!
        let key = JournalStats.dateKey(for: date)
        #expect(key == "2024-06-15")
    }

    @Test func testDateKeyFormatWithSingleDigitMonthAndDay() {
        let date = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 5))!
        let key = JournalStats.dateKey(for: date)
        #expect(key == "2024-01-05")
    }

    @Test func testDateKeyFormatConsistency() {
        let date = Date()
        let key1 = JournalStats.dateKey(for: date)
        let key2 = JournalStats.dateKey(for: date)
        #expect(key1 == key2)
    }

    // MARK: - sessionCount(for:) Tests

    @Test func testSessionCountForDateReturnsCorrectCount() {
        let today = Date()
        let key = JournalStats.dateKey(for: today)
        let stats = JournalStats(sessionCountByDate: [key: 3])
        #expect(stats.sessionCount(for: today) == 3)
    }

    @Test func testSessionCountForMissingDateReturnsZero() {
        let stats = JournalStats()
        #expect(stats.sessionCount(for: Date()) == 0)
    }

    @Test func testSessionCountForDifferentDates() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayKey = JournalStats.dateKey(for: today)
        let yesterdayKey = JournalStats.dateKey(for: yesterday)

        let stats = JournalStats(sessionCountByDate: [
            todayKey: 5,
            yesterdayKey: 2
        ])

        #expect(stats.sessionCount(for: today) == 5)
        #expect(stats.sessionCount(for: yesterday) == 2)
    }

    // MARK: - averageScore(for:) Tests

    @Test func testAverageScoreForDateReturnsCorrectValue() {
        let today = Date()
        let key = JournalStats.dateKey(for: today)
        let stats = JournalStats(averageScoreByDate: [key: 75.5])
        #expect(stats.averageScore(for: today) == 75.5)
    }

    @Test func testAverageScoreForMissingDateReturnsNil() {
        let stats = JournalStats()
        #expect(stats.averageScore(for: Date()) == nil)
    }

    @Test func testAverageScoreForDifferentDates() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayKey = JournalStats.dateKey(for: today)
        let yesterdayKey = JournalStats.dateKey(for: yesterday)

        let stats = JournalStats(averageScoreByDate: [
            todayKey: 80.0,
            yesterdayKey: 65.5
        ])

        #expect(stats.averageScore(for: today) == 80.0)
        #expect(stats.averageScore(for: yesterday) == 65.5)
    }

    // MARK: - Empty Stats Tests

    @Test func testEmptyStatsHasZeroValues() {
        let stats = JournalStats.empty
        #expect(stats.totalEntries == 0)
        #expect(stats.currentStreak == 0)
        #expect(stats.longestStreak == 0)
        #expect(stats.thisWeekEntries == 0)
        #expect(stats.sessionCountByDate.isEmpty)
        #expect(stats.averageScoreByDate.isEmpty)
    }

    @Test func testDefaultInitializerCreatesEmptyStats() {
        let stats = JournalStats()
        #expect(stats.totalEntries == 0)
        #expect(stats.currentStreak == 0)
        #expect(stats.longestStreak == 0)
        #expect(stats.thisWeekEntries == 0)
        #expect(stats.sessionCountByDate.isEmpty)
        #expect(stats.averageScoreByDate.isEmpty)
    }

    // MARK: - JournalStats Initialization Tests

    @Test func testInitializationWithAllParameters() {
        let stats = JournalStats(
            totalEntries: 10,
            currentStreak: 3,
            longestStreak: 7,
            thisWeekEntries: 5,
            sessionCountByDate: ["2024-06-15": 2],
            averageScoreByDate: ["2024-06-15": 85.0]
        )

        #expect(stats.totalEntries == 10)
        #expect(stats.currentStreak == 3)
        #expect(stats.longestStreak == 7)
        #expect(stats.thisWeekEntries == 5)
        #expect(stats.sessionCountByDate["2024-06-15"] == 2)
        #expect(stats.averageScoreByDate["2024-06-15"] == 85.0)
    }

    // MARK: - Equatable Tests

    @Test func testStatsEquality() {
        let stats1 = JournalStats(
            totalEntries: 5,
            currentStreak: 2,
            longestStreak: 4,
            thisWeekEntries: 3,
            sessionCountByDate: ["2024-06-15": 1],
            averageScoreByDate: ["2024-06-15": 70.0]
        )

        let stats2 = JournalStats(
            totalEntries: 5,
            currentStreak: 2,
            longestStreak: 4,
            thisWeekEntries: 3,
            sessionCountByDate: ["2024-06-15": 1],
            averageScoreByDate: ["2024-06-15": 70.0]
        )

        #expect(stats1 == stats2)
    }

    @Test func testStatsInequality() {
        let stats1 = JournalStats(totalEntries: 5)
        let stats2 = JournalStats(totalEntries: 10)

        #expect(stats1 != stats2)
    }

    // MARK: - Repository Integration Tests

    @Test func testEmptyRepositoryReturnsEmptyStats() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let stats = try await repo.getStats()

        #expect(stats.totalEntries == 0)
        #expect(stats.currentStreak == 0)
        #expect(stats.longestStreak == 0)
        #expect(stats.thisWeekEntries == 0)
        #expect(stats.sessionCountByDate.isEmpty)
        #expect(stats.averageScoreByDate.isEmpty)
    }

    @Test func testThisWeekEntriesCountsOnlyCurrentWeek() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let calendar = Calendar.current
        let now = Date()

        // Create session from today - should count
        let todaySession = JournalSession(
            id: "today-session",
            createdAt: now
        )
        try await repo.saveSession(todaySession)

        // Create session from 2 weeks ago - should NOT count
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now)!
        let oldSession = JournalSession(
            id: "old-session",
            createdAt: twoWeeksAgo
        )
        try await repo.saveSession(oldSession)

        let stats = try await repo.getStats()

        #expect(stats.totalEntries == 2)
        #expect(stats.thisWeekEntries == 1)
    }

    @Test func testSessionCountByDateGroupsCorrectly() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let calendar = Calendar.current
        let now = Date()

        // Create 3 sessions for today
        for i in 0..<3 {
            let session = JournalSession(
                id: "today-\(i)",
                createdAt: now
            )
            try await repo.saveSession(session)
        }

        // Create 2 sessions for yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        for i in 0..<2 {
            let session = JournalSession(
                id: "yesterday-\(i)",
                createdAt: yesterday
            )
            try await repo.saveSession(session)
        }

        let stats = try await repo.getStats()

        let todayKey = JournalStats.dateKey(for: now)
        let yesterdayKey = JournalStats.dateKey(for: yesterday)

        #expect(stats.sessionCountByDate[todayKey] == 3)
        #expect(stats.sessionCountByDate[yesterdayKey] == 2)
        #expect(stats.totalEntries == 5)
    }

    @Test func testAverageScoreByDateCalculatesMean() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let now = Date()

        // Create sessions with different clarity scores for today
        let score1 = ClarityScore(
            total: 60,
            completion: 60,
            depth: 60,
            emotional: 60,
            label: "Test",
            message: "Test message"
        )
        let score2 = ClarityScore(
            total: 80,
            completion: 80,
            depth: 80,
            emotional: 80,
            label: "Test",
            message: "Test message"
        )

        let session1 = JournalSession(
            id: "session-1",
            createdAt: now,
            clarityScore: score1
        )
        let session2 = JournalSession(
            id: "session-2",
            createdAt: now,
            clarityScore: score2
        )

        try await repo.saveSession(session1)
        try await repo.saveSession(session2)

        let stats = try await repo.getStats()
        let todayKey = JournalStats.dateKey(for: now)

        // Average of 60 and 80 should be 70
        #expect(stats.averageScoreByDate[todayKey] == 70.0)
    }

    @Test func testAverageScoreIgnoresSessionsWithoutScore() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let now = Date()

        // Session with score
        let score = ClarityScore(
            total: 90,
            completion: 90,
            depth: 90,
            emotional: 90,
            label: "Test",
            message: "Test message"
        )
        let sessionWithScore = JournalSession(
            id: "with-score",
            createdAt: now,
            clarityScore: score
        )

        // Session without score
        let sessionWithoutScore = JournalSession(
            id: "without-score",
            createdAt: now,
            clarityScore: nil
        )

        try await repo.saveSession(sessionWithScore)
        try await repo.saveSession(sessionWithoutScore)

        let stats = try await repo.getStats()
        let todayKey = JournalStats.dateKey(for: now)

        // Only the session with score should be counted in average
        #expect(stats.averageScoreByDate[todayKey] == 90.0)
        #expect(stats.sessionCountByDate[todayKey] == 2)
    }

    @Test func testNoAverageScoreWhenNoSessionsHaveScores() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let now = Date()

        // Sessions without scores
        let session1 = JournalSession(id: "no-score-1", createdAt: now)
        let session2 = JournalSession(id: "no-score-2", createdAt: now)

        try await repo.saveSession(session1)
        try await repo.saveSession(session2)

        let stats = try await repo.getStats()
        let todayKey = JournalStats.dateKey(for: now)

        #expect(stats.sessionCountByDate[todayKey] == 2)
        #expect(stats.averageScoreByDate[todayKey] == nil)
    }

    @Test func testMultipleDaysWithDifferentAverages() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        // Today: scores 50, 70 -> average 60
        let todayScore1 = ClarityScore(total: 50, completion: 50, depth: 50, emotional: 50, label: "T", message: "M")
        let todayScore2 = ClarityScore(total: 70, completion: 70, depth: 70, emotional: 70, label: "T", message: "M")

        try await repo.saveSession(JournalSession(id: "t1", createdAt: now, clarityScore: todayScore1))
        try await repo.saveSession(JournalSession(id: "t2", createdAt: now, clarityScore: todayScore2))

        // Yesterday: scores 80, 90, 100 -> average 90
        let yScore1 = ClarityScore(total: 80, completion: 80, depth: 80, emotional: 80, label: "T", message: "M")
        let yScore2 = ClarityScore(total: 90, completion: 90, depth: 90, emotional: 90, label: "T", message: "M")
        let yScore3 = ClarityScore(total: 100, completion: 100, depth: 100, emotional: 100, label: "T", message: "M")

        try await repo.saveSession(JournalSession(id: "y1", createdAt: yesterday, clarityScore: yScore1))
        try await repo.saveSession(JournalSession(id: "y2", createdAt: yesterday, clarityScore: yScore2))
        try await repo.saveSession(JournalSession(id: "y3", createdAt: yesterday, clarityScore: yScore3))

        let stats = try await repo.getStats()

        let todayKey = JournalStats.dateKey(for: now)
        let yesterdayKey = JournalStats.dateKey(for: yesterday)

        #expect(stats.averageScoreByDate[todayKey] == 60.0)
        #expect(stats.averageScoreByDate[yesterdayKey] == 90.0)
    }
}
