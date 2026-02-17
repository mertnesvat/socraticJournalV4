// SwiftDataJournalRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// SwiftData implementation of JournalRepositoryProtocol
/// Provides persistent storage for journal sessions and future letters
public final class SwiftDataJournalRepository: JournalRepositoryProtocol, @unchecked Sendable {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    // MARK: - Sessions

    public func getAllSessions() async throws -> [JournalSession] {
        let descriptor = FetchDescriptor<JournalSessionModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    public func getSession(id: String) async throws -> JournalSession? {
        var descriptor = FetchDescriptor<JournalSessionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1

        let models = try modelContext.fetch(descriptor)
        return models.first?.toDomain()
    }

    public func saveSession(_ session: JournalSession) async throws {
        // Check if session already exists
        let existingDescriptor = FetchDescriptor<JournalSessionModel>(
            predicate: #Predicate { $0.id == session.id }
        )
        let existing = try modelContext.fetch(existingDescriptor).first

        if let existing = existing {
            // Update existing session
            existing.createdAt = session.createdAt
            existing.exchanges = session.exchanges.map { ExchangeModel.from(exchange: $0) }
            existing.clarityScoreData = session.clarityScore.flatMap { try? JSONEncoder().encode($0) }
            existing.wisdomQuoteData = session.wisdomQuote.flatMap { try? JSONEncoder().encode($0) }
            existing.summary = session.summary
            existing.isComplete = session.isComplete
        } else {
            // Insert new session
            let model = JournalSessionModel.from(session: session)
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    public func deleteSession(id: String) async throws {
        let descriptor = FetchDescriptor<JournalSessionModel>(
            predicate: #Predicate { $0.id == id }
        )
        let models = try modelContext.fetch(descriptor)

        for model in models {
            modelContext.delete(model)
        }

        try modelContext.save()
    }

    public func getSessions(for date: Date) async throws -> [JournalSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

        let descriptor = FetchDescriptor<JournalSessionModel>(
            predicate: #Predicate { session in
                session.createdAt >= startOfDay && session.createdAt < endOfDay
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    // MARK: - Stats

    public func getStats() async throws -> JournalStats {
        let sessions = try await getAllSessions()
        return calculateStats(from: sessions)
    }

    // MARK: - Letters

    public func getAllLetters() async throws -> [FutureLetter] {
        let descriptor = FetchDescriptor<FutureLetterModel>(
            sortBy: [SortDescriptor(\.deliveryDate, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    public func getLetters(status: FutureLetterStatus) async throws -> [FutureLetter] {
        let statusRaw = status.rawValue
        let descriptor = FetchDescriptor<FutureLetterModel>(
            predicate: #Predicate { $0.statusRawValue == statusRaw },
            sortBy: [SortDescriptor(\.deliveryDate, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    public func saveLetter(_ letter: FutureLetter) async throws {
        // Check if letter already exists
        let existingDescriptor = FetchDescriptor<FutureLetterModel>(
            predicate: #Predicate { $0.id == letter.id }
        )
        let existing = try modelContext.fetch(existingDescriptor).first

        if let existing = existing {
            // Update existing letter
            existing.content = letter.content
            existing.createdAt = letter.createdAt
            existing.deliveryDate = letter.deliveryDate
            existing.statusRawValue = letter.status.rawValue
            existing.readAt = letter.readAt
        } else {
            // Insert new letter
            let model = FutureLetterModel.from(letter: letter)
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    public func updateLetterStatus(id: String, status: FutureLetterStatus) async throws {
        let descriptor = FetchDescriptor<FutureLetterModel>(
            predicate: #Predicate { $0.id == id }
        )
        let models = try modelContext.fetch(descriptor)

        guard let model = models.first else {
            throw RepositoryError.notFound
        }

        model.statusRawValue = status.rawValue
        if status == .read && model.readAt == nil {
            model.readAt = Date()
        }

        try modelContext.save()
    }

    public func getReadyLettersCount() async throws -> Int {
        let now = Date()
        let descriptor = FetchDescriptor<FutureLetterModel>(
            predicate: #Predicate { letter in
                letter.statusRawValue == "sealed" && letter.deliveryDate <= now
            }
        )
        let models = try modelContext.fetch(descriptor)
        return models.count
    }

    // MARK: - Data Management

    public func clearAllData() async throws {
        // Delete all sessions
        let sessionDescriptor = FetchDescriptor<JournalSessionModel>()
        let sessions = try modelContext.fetch(sessionDescriptor)
        for session in sessions {
            modelContext.delete(session)
        }

        // Delete all letters
        let letterDescriptor = FetchDescriptor<FutureLetterModel>()
        let letters = try modelContext.fetch(letterDescriptor)
        for letter in letters {
            modelContext.delete(letter)
        }

        try modelContext.save()
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

            let scores = dateSessions.compactMap { $0.clarityScore?.total }
            if !scores.isEmpty {
                averageScoreByDate[dateKey] = Double(scores.reduce(0, +)) / Double(scores.count)
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

/// Repository-specific errors
public enum RepositoryError: Error {
    case notFound
    case saveFailed
    case deleteFailed
}
