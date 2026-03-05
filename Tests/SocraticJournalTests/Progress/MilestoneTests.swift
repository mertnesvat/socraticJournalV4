// MilestoneTests.swift
// SocraticJournalTests

import Testing
import Foundation
@testable import SocraticJournal

@Suite("Milestone Tests")
struct MilestoneTests {

    // MARK: - Helpers

    private func makeSession(
        patternId: String = "resonance",
        startedAt: Date = Date(),
        durationSeconds: Double = 600
    ) -> BreathSession {
        BreathSession(
            patternId: patternId,
            startedAt: startedAt,
            completedAt: startedAt.addingTimeInterval(durationSeconds),
            totalDuration: durationSeconds,
            cyclesCompleted: Int(durationSeconds / 60)
        )
    }

    private func makeSessionAtHour(_ hour: Int, patternId: String = "resonance", durationSeconds: Double = 600) -> BreathSession {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = 0
        let date = calendar.date(from: components)!
        return makeSession(patternId: patternId, startedAt: date, durationSeconds: durationSeconds)
    }

    // MARK: - Entity

    @Test("All milestones has 10 entries")
    func allMilestonesCount() {
        #expect(Milestone.allMilestones.count == 10)
    }

    @Test("All milestones start locked")
    func allStartLocked() {
        for m in Milestone.allMilestones {
            #expect(m.isUnlocked == false)
            #expect(m.unlockedAt == nil)
        }
    }

    @Test("Milestone IDs are unique")
    func uniqueIds() {
        let ids = Milestone.allMilestones.map { $0.id }
        #expect(Set(ids).count == ids.count)
    }

    // MARK: - First Breath

    @Test("First Breath unlocks with 1 session")
    @MainActor
    func firstBreath() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSession()]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "first_breath" }
        #expect(milestone?.isUnlocked == true)
        #expect(milestone?.unlockedAt != nil)
    }

    @Test("First Breath stays locked with 0 sessions")
    @MainActor
    func firstBreathLocked() async throws {
        let repo = MockBreathSessionRepository()
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "first_breath" }
        #expect(milestone?.isUnlocked == false)
    }

    // MARK: - Century

    @Test("Century unlocks at 100 total minutes")
    @MainActor
    func century() async throws {
        let repo = MockBreathSessionRepository()
        // 10 sessions of 10 minutes each = 100 minutes
        for _ in 0..<10 {
            repo.sessions.append(makeSession(durationSeconds: 600))
        }
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "century" }
        #expect(milestone?.isUnlocked == true)
    }

    @Test("Century stays locked under 100 minutes")
    @MainActor
    func centuryLocked() async throws {
        let repo = MockBreathSessionRepository()
        // 9 sessions of 10 minutes = 90 minutes
        for _ in 0..<9 {
            repo.sessions.append(makeSession(durationSeconds: 600))
        }
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "century" }
        #expect(milestone?.isUnlocked == false)
    }

    // MARK: - Dawn Breather

    @Test("Dawn Breather unlocks with session before 7 AM")
    @MainActor
    func dawnBreather() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSessionAtHour(5)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "dawn_breather" }
        #expect(milestone?.isUnlocked == true)
    }

    @Test("Dawn Breather stays locked with session at 7 AM")
    @MainActor
    func dawnBreatherLocked() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSessionAtHour(7)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "dawn_breather" }
        #expect(milestone?.isUnlocked == false)
    }

    // MARK: - Night Owl

    @Test("Night Owl unlocks with session at 10 PM")
    @MainActor
    func nightOwl() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSessionAtHour(22)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "night_owl" }
        #expect(milestone?.isUnlocked == true)
    }

    @Test("Night Owl stays locked with session at 9 PM")
    @MainActor
    func nightOwlLocked() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSessionAtHour(21)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "night_owl" }
        #expect(milestone?.isUnlocked == false)
    }

    // MARK: - Marathon

    @Test("Marathon unlocks with 20-minute session")
    @MainActor
    func marathon() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSession(durationSeconds: 1200)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "marathon" }
        #expect(milestone?.isUnlocked == true)
    }

    @Test("Marathon stays locked with 19-minute session")
    @MainActor
    func marathonLocked() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSession(durationSeconds: 1140)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "marathon" }
        #expect(milestone?.isUnlocked == false)
    }

    // MARK: - Pattern Explorer

    @Test("Pattern Explorer unlocks when all 8 patterns used")
    @MainActor
    func patternExplorer() async throws {
        let repo = MockBreathSessionRepository()
        let patternIds = ["resonance", "box", "478", "coherent", "energize", "sleep", "wimhof", "balance"]
        for pid in patternIds {
            repo.sessions.append(makeSession(patternId: pid))
        }
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "pattern_explorer" }
        #expect(milestone?.isUnlocked == true)
    }

    @Test("Pattern Explorer stays locked with only 7 patterns")
    @MainActor
    func patternExplorerLocked() async throws {
        let repo = MockBreathSessionRepository()
        let patternIds = ["resonance", "box", "478", "coherent", "energize", "sleep", "wimhof"]
        for pid in patternIds {
            repo.sessions.append(makeSession(patternId: pid))
        }
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let milestone = vm.milestones.first { $0.id == "pattern_explorer" }
        #expect(milestone?.isUnlocked == false)
    }

    // MARK: - Milestones count after load

    @Test("Milestones array always has 10 entries")
    @MainActor
    func milestonesAlwaysTen() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSession()]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        #expect(vm.milestones.count == 10)
    }
}
