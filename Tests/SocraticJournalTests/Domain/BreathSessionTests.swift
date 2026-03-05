// BreathSessionTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("BreathSession Tests")
struct BreathSessionTests {

    @Test("Codable encoding and decoding round-trip")
    func codableRoundTrip() throws {
        let now = Date()
        let session = BreathSession(
            id: "test-123",
            patternId: "resonance",
            startedAt: now,
            completedAt: now.addingTimeInterval(300),
            totalDuration: 300,
            cyclesCompleted: 27
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(BreathSession.self, from: data)

        #expect(decoded.id == session.id)
        #expect(decoded.patternId == session.patternId)
        #expect(decoded.totalDuration == session.totalDuration)
        #expect(decoded.cyclesCompleted == session.cyclesCompleted)
    }

    @Test("date computed property returns start of day")
    func dateReturnsStartOfDay() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 3
        components.day = 5
        components.hour = 14
        components.minute = 30
        let startedAt = calendar.date(from: components)!

        let session = BreathSession(
            patternId: "resonance",
            startedAt: startedAt,
            completedAt: startedAt.addingTimeInterval(300),
            totalDuration: 300,
            cyclesCompleted: 27
        )

        let expectedStartOfDay = calendar.startOfDay(for: startedAt)
        #expect(session.date == expectedStartOfDay)
    }

    @Test("Session with zero duration")
    func zeroDuration() {
        let now = Date()
        let session = BreathSession(
            patternId: "box",
            startedAt: now,
            completedAt: now,
            totalDuration: 0,
            cyclesCompleted: 0
        )

        #expect(session.totalDuration == 0)
        #expect(session.cyclesCompleted == 0)
    }

    @Test("Session IDs are unique when using default initializer")
    func sessionIDUniqueness() {
        let now = Date()
        let session1 = BreathSession(
            patternId: "resonance",
            startedAt: now,
            completedAt: now.addingTimeInterval(300),
            totalDuration: 300,
            cyclesCompleted: 27
        )
        let session2 = BreathSession(
            patternId: "resonance",
            startedAt: now,
            completedAt: now.addingTimeInterval(300),
            totalDuration: 300,
            cyclesCompleted: 27
        )

        #expect(session1.id != session2.id)
    }
}
