// StreakCalculationTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for streak calculation logic in InMemoryJournalRepository
struct StreakCalculationTests {

    // MARK: - Helpers

    /// Creates a JournalSession with createdAt set to a specific number of days ago
    private func makeSession(daysAgo: Int) -> JournalSession {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date()))!
        return JournalSession(
            id: UUID().uuidString,
            createdAt: date,
            exchanges: [],
            clarityScore: nil,
            wisdomQuote: nil,
            isComplete: true
        )
    }

    // MARK: - Current Streak Tests

    @Test("Consecutive days create a streak")
    func testConsecutiveDaysStreak() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Save sessions for today, yesterday, and 2 days ago
        try await repo.saveSession(makeSession(daysAgo: 0))  // today
        try await repo.saveSession(makeSession(daysAgo: 1))  // yesterday
        try await repo.saveSession(makeSession(daysAgo: 2))  // 2 days ago

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 3, "Current streak should be 3 for consecutive days")
        #expect(stats.longestStreak == 3, "Longest streak should also be 3")
    }

    @Test("Streak resets after a missed day")
    func testStreakResetsAfterMissedDay() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Save session for today and 2 days ago (gap at yesterday)
        try await repo.saveSession(makeSession(daysAgo: 0))  // today
        try await repo.saveSession(makeSession(daysAgo: 2))  // 2 days ago (gap at day 1)

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 1, "Current streak should be 1 since yesterday was missed")
    }

    @Test("Longest streak is remembered after current streak breaks")
    func testLongestStreakRemembered() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Create an old 5-day streak: days 10, 9, 8, 7, 6 ago
        try await repo.saveSession(makeSession(daysAgo: 10))
        try await repo.saveSession(makeSession(daysAgo: 9))
        try await repo.saveSession(makeSession(daysAgo: 8))
        try await repo.saveSession(makeSession(daysAgo: 7))
        try await repo.saveSession(makeSession(daysAgo: 6))

        // Gap at days 5, 4, 3, 2, 1 - then entry today only
        try await repo.saveSession(makeSession(daysAgo: 0))  // today

        let stats = try await repo.getStats()

        #expect(stats.longestStreak == 5, "Longest streak should be 5 from the old streak")
        #expect(stats.currentStreak == 1, "Current streak should be 1 (only today)")
    }

    @Test("Today's entry alone counts as streak of 1")
    func testTodayEntryCountsInStreak() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Only today's entry
        try await repo.saveSession(makeSession(daysAgo: 0))

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 1, "Single day entry should count as streak of 1")
        #expect(stats.longestStreak == 1, "Longest streak should also be 1")
    }

    @Test("Yesterday entry without today continues streak")
    func testYesterdayEntryWithoutToday() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Entries for yesterday and 2 days ago, but not today
        try await repo.saveSession(makeSession(daysAgo: 1))  // yesterday
        try await repo.saveSession(makeSession(daysAgo: 2))  // 2 days ago

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 2, "Streak should continue from yesterday if no entry today")
    }

    // MARK: - Gap Handling Tests

    @Test("Single day gap breaks the streak")
    func testSingleDayGapBreaksStreak() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Sessions with a gap: today, yesterday, then 3 days ago (gap at 2 days ago)
        try await repo.saveSession(makeSession(daysAgo: 0))  // today
        try await repo.saveSession(makeSession(daysAgo: 1))  // yesterday
        try await repo.saveSession(makeSession(daysAgo: 3))  // 3 days ago

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 2, "Current streak should be 2 (today and yesterday)")
        #expect(stats.longestStreak == 2, "Longest streak should be 2")
    }

    @Test("Empty repository returns zero streaks")
    func testEmptyRepositoryZeroStreaks() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 0, "Empty repo should have 0 current streak")
        #expect(stats.longestStreak == 0, "Empty repo should have 0 longest streak")
    }

    @Test("Multiple sessions same day count as single day for streak")
    func testMultipleSessionsSameDayCountAsOne() async throws {
        let repo = InMemoryJournalRepository(seedSampleData: false)

        // Multiple sessions today
        try await repo.saveSession(makeSession(daysAgo: 0))
        try await repo.saveSession(makeSession(daysAgo: 0))
        try await repo.saveSession(makeSession(daysAgo: 0))

        // One session yesterday
        try await repo.saveSession(makeSession(daysAgo: 1))

        let stats = try await repo.getStats()

        #expect(stats.currentStreak == 2, "Multiple sessions same day should count as 1 day in streak")
        #expect(stats.totalEntries == 4, "Total entries should count all sessions")
    }
}
