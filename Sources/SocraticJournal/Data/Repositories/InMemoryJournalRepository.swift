// InMemoryJournalRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// In-memory implementation of JournalRepositoryProtocol
/// For development and testing - will be replaced with Firebase
public final class InMemoryJournalRepository: JournalRepositoryProtocol, @unchecked Sendable {
    private let dataSource: InMemoryDataSource

    public init() {
        self.dataSource = InMemoryDataSource()
    }

    // MARK: - Sessions

    public func getAllSessions() async throws -> [JournalSession] {
        await dataSource.getAllSessions()
    }

    public func getSession(id: String) async throws -> JournalSession? {
        await dataSource.getSession(id: id)
    }

    public func saveSession(_ session: JournalSession) async throws {
        await dataSource.saveSession(session)
    }

    public func deleteSession(id: String) async throws {
        await dataSource.deleteSession(id: id)
    }

    public func getSessions(for date: Date) async throws -> [JournalSession] {
        await dataSource.getSessions(for: date)
    }

    // MARK: - Stats

    public func getStats() async throws -> JournalStats {
        let sessions = await dataSource.getAllSessions()
        return calculateStats(from: sessions)
    }

    // MARK: - Letters

    public func getAllLetters() async throws -> [FutureLetter] {
        await dataSource.getAllLetters()
    }

    public func getLetters(status: FutureLetterStatus) async throws -> [FutureLetter] {
        await dataSource.getLetters(status: status)
    }

    public func saveLetter(_ letter: FutureLetter) async throws {
        await dataSource.saveLetter(letter)
    }

    public func updateLetterStatus(id: String, status: FutureLetterStatus) async throws {
        await dataSource.updateLetterStatus(id: id, status: status)
    }

    public func getReadyLettersCount() async throws -> Int {
        await dataSource.getReadyLettersCount()
    }

    // MARK: - Private Helpers

    private func calculateStats(from sessions: [JournalSession]) -> JournalStats {
        let calendar = Calendar.current
        let now = Date()

        // Group sessions by date
        var sessionsByDate: [String: [JournalSession]] = [:]
        for session in sessions {
            let key = JournalStats.dateKey(for: session.createdAt)
            sessionsByDate[key, default: []].append(session)
        }

        // Calculate session count by date
        var sessionCountByDate: [String: Int] = [:]
        var averageScoreByDate: [String: Double] = [:]

        for (dateKey, dateSessions) in sessionsByDate {
            sessionCountByDate[dateKey] = dateSessions.count

            let scores = dateSessions.compactMap { $0.clarityScore?.score }
            if !scores.isEmpty {
                averageScoreByDate[dateKey] = scores.reduce(0, +) / Double(scores.count)
            }
        }

        // Calculate streaks
        let (currentStreak, longestStreak) = calculateStreaks(sessionsByDate: sessionsByDate, calendar: calendar, now: now)

        // Calculate this week's entries
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        let thisWeekEntries = sessions.filter { session in
            session.createdAt >= startOfWeek
        }.count

        return JournalStats(
            totalEntries: sessions.count,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            thisWeekEntries: thisWeekEntries,
            sessionCountByDate: sessionCountByDate,
            averageScoreByDate: averageScoreByDate
        )
    }

    private func calculateStreaks(
        sessionsByDate: [String: [JournalSession]],
        calendar: Calendar,
        now: Date
    ) -> (current: Int, longest: Int) {
        guard !sessionsByDate.isEmpty else { return (0, 0) }

        // Get all dates with sessions, sorted
        let sortedDates = sessionsByDate.keys
            .compactMap { dateKey -> Date? in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.date(from: dateKey)
            }
            .sorted()

        guard !sortedDates.isEmpty else { return (0, 0) }

        var currentStreak = 0
        var longestStreak = 0
        var streak = 1

        // Calculate longest streak
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]

            if let daysDiff = calendar.dateComponents([.day], from: previousDate, to: currentDate).day,
               daysDiff == 1 {
                streak += 1
            } else {
                longestStreak = max(longestStreak, streak)
                streak = 1
            }
        }
        longestStreak = max(longestStreak, streak)

        // Calculate current streak
        let today = calendar.startOfDay(for: now)
        let todayKey = JournalStats.dateKey(for: today)
        let yesterdayKey = JournalStats.dateKey(for: calendar.date(byAdding: .day, value: -1, to: today) ?? today)

        if sessionsByDate[todayKey] != nil {
            currentStreak = 1
            var checkDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today

            while sessionsByDate[JournalStats.dateKey(for: checkDate)] != nil {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            }
        } else if sessionsByDate[yesterdayKey] != nil {
            // Streak from yesterday
            currentStreak = 1
            var checkDate = calendar.date(byAdding: .day, value: -2, to: today) ?? today

            while sessionsByDate[JournalStats.dateKey(for: checkDate)] != nil {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            }
        }

        return (currentStreak, longestStreak)
    }
}
