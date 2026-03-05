// MockBreathSessionRepository.swift
// SocraticJournalTests

import Foundation
@testable import SocraticJournal

final class MockBreathSessionRepository: BreathSessionRepositoryProtocol, @unchecked Sendable {
    var sessions: [BreathSession] = []
    var shouldThrow = false

    private func throwIfNeeded() throws {
        if shouldThrow { throw MockError.intentional }
    }

    enum MockError: Error {
        case intentional
    }

    func saveSession(_ session: BreathSession) async throws {
        try throwIfNeeded()
        sessions.append(session)
    }

    func getSessionsForDate(_ date: Date) async throws -> [BreathSession] {
        try throwIfNeeded()
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
    }

    func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession] {
        try throwIfNeeded()
        let start = Calendar.current.startOfDay(for: from)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: to))!
        return sessions.filter { $0.startedAt >= start && $0.startedAt < end }
    }

    func getTotalMinutesToday() async throws -> Double {
        try throwIfNeeded()
        let todaySessions = try await getSessionsForDate(Date())
        return todaySessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    func getStreak() async throws -> Int {
        try throwIfNeeded()
        return 0
    }

    func getAllSessions() async throws -> [BreathSession] {
        try throwIfNeeded()
        return sessions
    }

    func getTotalMinutes() async throws -> Double {
        try throwIfNeeded()
        return sessions.reduce(0) { $0 + $1.totalDuration } / 60.0
    }

    func getTotalSessions() async throws -> Int {
        try throwIfNeeded()
        return sessions.count
    }

    func getLongestStreak() async throws -> Int {
        try throwIfNeeded()
        return 3
    }

    func getSessionsByPattern() async throws -> [String: [BreathSession]] {
        try throwIfNeeded()
        return Dictionary(grouping: sessions, by: { $0.patternId })
    }

    func getSessionsForMonth(year: Int, month: Int) async throws -> [BreathSession] {
        try throwIfNeeded()
        let calendar = Calendar.current
        return sessions.filter {
            let comp = calendar.dateComponents([.year, .month], from: $0.startedAt)
            return comp.year == year && comp.month == month
        }
    }
}
