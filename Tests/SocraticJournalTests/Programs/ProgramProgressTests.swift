// ProgramProgressTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("ProgramProgress Entity Tests")
struct ProgramProgressTests {

    @Test("Progress fraction calculates correctly")
    func progressFraction() {
        let progress = ProgramProgress(
            programId: "calm-foundation",
            currentDay: 4,
            completedDays: [1, 2, 3],
            totalDays: 7
        )
        #expect(progress.progressFraction > 0.42)
        #expect(progress.progressFraction < 0.43)
    }

    @Test("Progress fraction is zero when no days completed")
    func progressFractionZero() {
        let progress = ProgramProgress(
            programId: "test",
            currentDay: 1,
            completedDays: [],
            totalDays: 7
        )
        #expect(progress.progressFraction == 0)
    }

    @Test("isComplete returns true when currentDay exceeds totalDays")
    func isComplete() {
        let progress = ProgramProgress(
            programId: "test",
            currentDay: 8,
            completedDays: [1, 2, 3, 4, 5, 6, 7],
            totalDays: 7
        )
        #expect(progress.isComplete)
    }

    @Test("isComplete returns false when program is in progress")
    func isNotComplete() {
        let progress = ProgramProgress(
            programId: "test",
            currentDay: 3,
            completedDays: [1, 2],
            totalDays: 7
        )
        #expect(!progress.isComplete)
    }

    @Test("isDayCompleted checks completed days array")
    func isDayCompleted() {
        let progress = ProgramProgress(
            programId: "test",
            currentDay: 4,
            completedDays: [1, 2, 3],
            totalDays: 7
        )
        #expect(progress.isDayCompleted(1))
        #expect(progress.isDayCompleted(2))
        #expect(progress.isDayCompleted(3))
        #expect(!progress.isDayCompleted(4))
        #expect(!progress.isDayCompleted(5))
    }
}

@Suite("ProgramProgress Repository Tests")
struct ProgramProgressRepositoryTests {

    @Test("Start program creates new progress")
    func startProgram() async throws {
        let repo = MockProgramProgressRepository()

        try await repo.startProgram("calm-foundation", totalDays: 7)

        let progress = try await repo.getActiveProgram()
        #expect(progress != nil)
        #expect(progress?.programId == "calm-foundation")
        #expect(progress?.currentDay == 1)
        #expect(progress?.completedDays.isEmpty == true)
        #expect(progress?.totalDays == 7)
    }

    @Test("Complete day advances currentDay")
    func completeDay() async throws {
        let repo = MockProgramProgressRepository()
        try await repo.startProgram("calm-foundation", totalDays: 7)

        try await repo.completeDay(1, for: "calm-foundation")

        let progress = try await repo.getActiveProgram()
        #expect(progress?.currentDay == 2)
        #expect(progress?.completedDays == [1])
    }

    @Test("Complete multiple days in sequence")
    func completeMultipleDays() async throws {
        let repo = MockProgramProgressRepository()
        try await repo.startProgram("calm-foundation", totalDays: 7)

        try await repo.completeDay(1, for: "calm-foundation")
        try await repo.completeDay(2, for: "calm-foundation")
        try await repo.completeDay(3, for: "calm-foundation")

        let progress = try await repo.getActiveProgram()
        #expect(progress?.currentDay == 4)
        #expect(progress?.completedDays == [1, 2, 3])
    }

    @Test("Duplicate day completion is ignored")
    func duplicateCompletion() async throws {
        let repo = MockProgramProgressRepository()
        try await repo.startProgram("calm-foundation", totalDays: 7)

        try await repo.completeDay(1, for: "calm-foundation")
        try await repo.completeDay(1, for: "calm-foundation")

        let progress = try await repo.getActiveProgram()
        #expect(progress?.completedDays == [1])
        #expect(repo.completeDayCallCount == 2)
    }

    @Test("Abandon program clears progress")
    func abandonProgram() async throws {
        let repo = MockProgramProgressRepository()
        try await repo.startProgram("calm-foundation", totalDays: 7)
        try await repo.completeDay(1, for: "calm-foundation")

        try await repo.abandonProgram()

        let progress = try await repo.getActiveProgram()
        #expect(progress == nil)
        #expect(repo.abandonProgramCalled)
    }

    @Test("Complete day for wrong program does nothing")
    func completeDayWrongProgram() async throws {
        let repo = MockProgramProgressRepository()
        try await repo.startProgram("calm-foundation", totalDays: 7)

        try await repo.completeDay(1, for: "different-program")

        let progress = try await repo.getActiveProgram()
        #expect(progress?.completedDays.isEmpty == true)
        #expect(progress?.currentDay == 1)
    }

    @Test("Completed program returns nil from getActiveProgram")
    func completedProgramReturnsNil() async throws {
        let repo = MockProgramProgressRepository(activeProgress: ProgramProgress(
            programId: "test",
            currentDay: 8,
            completedDays: [1, 2, 3, 4, 5, 6, 7],
            totalDays: 7
        ))

        let progress = try await repo.getActiveProgram()
        #expect(progress == nil)
    }

    @Test("Error propagates when shouldFail is set")
    func errorPropagation() async throws {
        let repo = MockProgramProgressRepository()
        repo.shouldFail = true

        do {
            try await repo.startProgram("test", totalDays: 7)
            #expect(Bool(false), "Should have thrown")
        } catch {
            #expect(repo.startProgramCalled)
        }
    }
}

@Suite("BreathProgram Entity Tests")
struct BreathProgramTests {

    @Test("All programs have correct duration days")
    func allProgramsDurationDays() {
        #expect(BreathProgram.nasalBreathingReset.durationDays == 7)
        #expect(BreathProgram.stressResilience.durationDays == 10)
        #expect(BreathProgram.breathMastery.durationDays == 21)
        #expect(BreathProgram.eveningWindDown.durationDays == 7)
    }

    @Test("All programs have sequential day numbers")
    func programsHaveSequentialDays() {
        for program in BreathProgram.allPrograms {
            for (index, day) in program.days.enumerated() {
                #expect(day.dayNumber == index + 1, "Day \(day.dayNumber) in \(program.title) should be \(index + 1)")
            }
        }
    }

    @Test("All program days reference valid patterns")
    func allDaysReferenceValidPatterns() {
        for program in BreathProgram.allPrograms {
            for day in program.days {
                let pattern = BreathPattern.allPatterns.first { $0.id == day.patternId }
                #expect(pattern != nil, "Day \(day.id) in \(program.title) references invalid pattern: \(day.patternId)")
            }
        }
    }

    @Test("ProgramDay resolves pattern correctly")
    func programDayResolvesPattern() {
        let day = ProgramDay(
            id: "test-d1",
            dayNumber: 1,
            title: "Test Day",
            lesson: "Test lesson",
            patternId: "resonance",
            durationMinutes: 5,
            focusNote: "Test"
        )
        let pattern = BreathPattern.allPatterns.first { $0.id == day.patternId }
        #expect(pattern?.name == "Resonance")
    }

    @Test("Four programs exist in allPrograms")
    func fourPrograms() {
        #expect(BreathProgram.allPrograms.count == 4)
    }
}

@Suite("UserDefaults ProgramProgress Repository Tests")
struct UserDefaultsProgramProgressRepositoryTests {

    private func makeSUT() -> (UserDefaultsProgramProgressRepository, UserDefaults) {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let repo = UserDefaultsProgramProgressRepository(defaults: defaults)
        return (repo, defaults)
    }

    @Test("Start and retrieve a program")
    func startAndRetrieve() async throws {
        let (repo, _) = makeSUT()

        try await repo.startProgram("calm-foundation", totalDays: 7)
        let progress = try await repo.getActiveProgram()

        #expect(progress != nil)
        #expect(progress?.programId == "calm-foundation")
        #expect(progress?.totalDays == 7)
        #expect(progress?.currentDay == 1)
    }

    @Test("Complete a day and verify advancement")
    func completeDayAdvances() async throws {
        let (repo, _) = makeSUT()

        try await repo.startProgram("calm-foundation", totalDays: 7)
        try await repo.completeDay(1, for: "calm-foundation")

        let progress = try await repo.getActiveProgram()
        #expect(progress?.currentDay == 2)
        #expect(progress?.completedDays == [1])
        #expect(progress?.lastPracticedAt != nil)
    }

    @Test("Abandon clears progress")
    func abandonClears() async throws {
        let (repo, _) = makeSUT()

        try await repo.startProgram("calm-foundation", totalDays: 7)
        try await repo.abandonProgram()

        let progress = try await repo.getActiveProgram()
        #expect(progress == nil)
    }

    @Test("GetProgress returns nil for non-matching program")
    func getProgressNonMatching() async throws {
        let (repo, _) = makeSUT()

        try await repo.startProgram("calm-foundation", totalDays: 7)
        let progress = try await repo.getProgress(for: "sleep-reset")

        #expect(progress == nil)
    }

    @Test("GetProgress returns progress for matching program")
    func getProgressMatching() async throws {
        let (repo, _) = makeSUT()

        try await repo.startProgram("calm-foundation", totalDays: 7)
        let progress = try await repo.getProgress(for: "calm-foundation")

        #expect(progress != nil)
        #expect(progress?.programId == "calm-foundation")
    }

    @Test("Starting a new program replaces the old one")
    func replaceProgram() async throws {
        let (repo, _) = makeSUT()

        try await repo.startProgram("calm-foundation", totalDays: 7)
        try await repo.completeDay(1, for: "calm-foundation")
        try await repo.startProgram("sleep-reset", totalDays: 7)

        let progress = try await repo.getActiveProgram()
        #expect(progress?.programId == "sleep-reset")
        #expect(progress?.currentDay == 1)
        #expect(progress?.completedDays.isEmpty == true)
    }
}
