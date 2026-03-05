// MockProgramProgressRepository.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock program progress repository for testing
public final class MockProgramProgressRepository: ProgramProgressRepositoryProtocol, @unchecked Sendable {
    // MARK: - State

    public var activeProgress: ProgramProgress?
    public var shouldFail: Bool = false
    public var failError: Error = NSError(domain: "MockError", code: -1)

    // MARK: - Call Tracking

    public private(set) var getActiveProgramCalled: Bool = false
    public private(set) var getActiveProgramCallCount: Int = 0
    public private(set) var startProgramCalled: Bool = false
    public private(set) var startProgramCallCount: Int = 0
    public private(set) var lastStartedProgramId: String?
    public private(set) var completeDayCalled: Bool = false
    public private(set) var completeDayCallCount: Int = 0
    public private(set) var lastCompletedDay: Int?
    public private(set) var abandonProgramCalled: Bool = false
    public private(set) var abandonProgramCallCount: Int = 0

    // MARK: - Init

    public init(activeProgress: ProgramProgress? = nil) {
        self.activeProgress = activeProgress
    }

    // MARK: - Protocol Methods

    public func getActiveProgram() async throws -> ProgramProgress? {
        getActiveProgramCalled = true
        getActiveProgramCallCount += 1
        if shouldFail { throw failError }
        guard let progress = activeProgress else { return nil }
        return progress.isComplete ? nil : progress
    }

    public func startProgram(_ programId: String, totalDays: Int) async throws {
        startProgramCalled = true
        startProgramCallCount += 1
        lastStartedProgramId = programId
        if shouldFail { throw failError }
        activeProgress = ProgramProgress(
            programId: programId,
            currentDay: 1,
            completedDays: [],
            totalDays: totalDays,
            startedAt: Date()
        )
    }

    public func completeDay(_ day: Int, for programId: String) async throws {
        completeDayCalled = true
        completeDayCallCount += 1
        lastCompletedDay = day
        if shouldFail { throw failError }

        guard var progress = activeProgress, progress.programId == programId else { return }
        guard !progress.completedDays.contains(day) else { return }

        progress.completedDays.append(day)
        progress.completedDays.sort()
        progress.lastPracticedAt = Date()

        if day == progress.currentDay {
            progress.currentDay = day + 1
        }
        activeProgress = progress
    }

    public func abandonProgram() async throws {
        abandonProgramCalled = true
        abandonProgramCallCount += 1
        if shouldFail { throw failError }
        activeProgress = nil
    }

    public func getProgress(for programId: String) async throws -> ProgramProgress? {
        if shouldFail { throw failError }
        guard let progress = activeProgress, progress.programId == programId else { return nil }
        return progress
    }

    // MARK: - Test Helpers

    public func reset() {
        activeProgress = nil
        shouldFail = false
        getActiveProgramCalled = false
        getActiveProgramCallCount = 0
        startProgramCalled = false
        startProgramCallCount = 0
        lastStartedProgramId = nil
        completeDayCalled = false
        completeDayCallCount = 0
        lastCompletedDay = nil
        abandonProgramCalled = false
        abandonProgramCallCount = 0
    }
}
