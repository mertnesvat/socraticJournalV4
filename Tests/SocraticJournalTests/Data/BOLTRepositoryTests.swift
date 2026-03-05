// BOLTRepositoryTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("BOLT Repository Tests")
struct BOLTRepositoryTests {

    private func makeSUT() -> UserDefaultsBreathSessionRepository {
        let suiteName = "com.breathe.bolt.tests.\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        return UserDefaultsBreathSessionRepository(defaults: suite)
    }

    @Test("Save and retrieve BOLT score")
    func saveAndRetrieve() async throws {
        let repo = makeSUT()
        let score = BOLTScore(score: 25.3)

        try await repo.saveBOLTScore(score)
        let scores = try await repo.getBOLTScores()

        #expect(scores.count == 1)
        #expect(scores.first?.score == 25.3)
    }

    @Test("getLatestBOLTScore returns most recent")
    func latestScore() async throws {
        let repo = makeSUT()
        let older = BOLTScore(score: 20.0, recordedAt: Date().addingTimeInterval(-86400))
        let newer = BOLTScore(score: 30.0, recordedAt: Date())

        try await repo.saveBOLTScore(older)
        try await repo.saveBOLTScore(newer)

        let latest = try await repo.getLatestBOLTScore()
        #expect(latest?.score == 30.0)
    }

    @Test("getLatestBOLTScore returns nil when empty")
    func latestScoreNil() async throws {
        let repo = makeSUT()
        let latest = try await repo.getLatestBOLTScore()
        #expect(latest == nil)
    }

    @Test("Multiple scores persist and return in order")
    func multipleScores() async throws {
        let repo = makeSUT()

        try await repo.saveBOLTScore(BOLTScore(score: 15.0))
        try await repo.saveBOLTScore(BOLTScore(score: 20.0))
        try await repo.saveBOLTScore(BOLTScore(score: 25.0))

        let scores = try await repo.getBOLTScores()
        #expect(scores.count == 3)
    }
}
