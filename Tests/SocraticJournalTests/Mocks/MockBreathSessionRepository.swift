// MockBreathSessionRepository.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock repository for testing breath session save/load operations
final class MockBreathSessionRepository: BreathSessionRepositoryProtocol, @unchecked Sendable {
    var savedSessions: [BreathSession] = []
    var streakToReturn: Int = 0
    var totalMinutesToReturn: Double = 0
    var shouldFail: Bool = false
    var saveCallCount: Int = 0

    enum MockError: Error {
        case forced
    }

    func saveSession(_ session: BreathSession) async throws {
        if shouldFail { throw MockError.forced }
        saveCallCount += 1
        savedSessions.append(session)
    }

    func getSessions(for date: Date) async throws -> [BreathSession] {
        if shouldFail { throw MockError.forced }
        return savedSessions
    }

    func getAllSessions() async throws -> [BreathSession] {
        if shouldFail { throw MockError.forced }
        return savedSessions
    }

    func getSessionsInRange(from: Date, to: Date) async throws -> [BreathSession] {
        if shouldFail { throw MockError.forced }
        return savedSessions
    }

    func getCurrentStreak() async throws -> Int {
        if shouldFail { throw MockError.forced }
        return streakToReturn
    }

    func getTotalMinutesBreathed() async throws -> Double {
        if shouldFail { throw MockError.forced }
        return totalMinutesToReturn
    }

    func getTotalSessions() async throws -> Int {
        if shouldFail { throw MockError.forced }
        return savedSessions.count
    }
}
