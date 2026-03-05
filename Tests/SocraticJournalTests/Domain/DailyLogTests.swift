// DailyLogTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("DailyLog Tests")
struct DailyLogTests {

    @Test("totalMinutes computes from sessions array")
    func totalMinutesComputation() {
        let now = Date()
        let sessions = [
            BreathSession(patternId: "resonance", startedAt: now, completedAt: now.addingTimeInterval(300), totalDuration: 300, cyclesCompleted: 27),
            BreathSession(patternId: "box", startedAt: now, completedAt: now.addingTimeInterval(600), totalDuration: 600, cyclesCompleted: 37),
        ]
        let log = DailyLog(date: now, sessions: sessions)

        // (300 + 600) / 60 = 15.0
        #expect(log.totalMinutes == 15.0)
    }

    @Test("sessionsCount matches array length")
    func sessionsCountMatchesLength() {
        let now = Date()
        let sessions = [
            BreathSession(patternId: "resonance", startedAt: now, completedAt: now.addingTimeInterval(300), totalDuration: 300, cyclesCompleted: 27),
            BreathSession(patternId: "box", startedAt: now, completedAt: now.addingTimeInterval(600), totalDuration: 600, cyclesCompleted: 37),
            BreathSession(patternId: "478", startedAt: now, completedAt: now.addingTimeInterval(120), totalDuration: 120, cyclesCompleted: 6),
        ]
        let log = DailyLog(date: now, sessions: sessions)

        #expect(log.sessionsCount == 3)
    }

    @Test("Empty sessions returns 0 minutes")
    func emptySessionsReturnsZero() {
        let log = DailyLog(date: Date(), sessions: [])

        #expect(log.totalMinutes == 0)
        #expect(log.sessionsCount == 0)
    }
}
