// ProgressViewModelTests.swift
// SocraticJournalTests

import Testing
import Foundation
@testable import SocraticJournal

@Suite("ProgressViewModel Tests")
struct ProgressViewModelTests {

    // MARK: - Helpers

    private func makeSession(
        patternId: String = "resonance",
        daysAgo: Int = 0,
        durationMinutes: Double = 10
    ) -> BreathSession {
        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        return BreathSession(
            patternId: patternId,
            startedAt: startDate,
            completedAt: startDate.addingTimeInterval(durationMinutes * 60),
            totalDuration: durationMinutes * 60,
            cyclesCompleted: Int(durationMinutes)
        )
    }

    // MARK: - Empty State

    @Test("Empty repository shows isEmpty true")
    @MainActor
    func emptyState() async throws {
        let repo = MockBreathSessionRepository()
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        #expect(vm.isEmpty == true)
        #expect(vm.totalSessions == 0)
        #expect(vm.totalMinutes == 0)
        #expect(vm.patternBreakdown.isEmpty)
    }

    // MARK: - Lifetime Stats

    @Test("Loads lifetime stats correctly")
    @MainActor
    func lifetimeStats() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [
            makeSession(patternId: "resonance", daysAgo: 0, durationMinutes: 10),
            makeSession(patternId: "box", daysAgo: 1, durationMinutes: 5),
            makeSession(patternId: "resonance", daysAgo: 2, durationMinutes: 15),
        ]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        #expect(vm.isEmpty == false)
        #expect(vm.totalSessions == 3)
        #expect(vm.totalMinutes == 30.0)
    }

    // MARK: - Pattern Breakdown

    @Test("Pattern breakdown groups and sorts by minutes")
    @MainActor
    func patternBreakdown() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [
            makeSession(patternId: "resonance", daysAgo: 0, durationMinutes: 20),
            makeSession(patternId: "box", daysAgo: 0, durationMinutes: 5),
            makeSession(patternId: "resonance", daysAgo: 1, durationMinutes: 10),
        ]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        #expect(vm.patternBreakdown.count == 2)
        // Resonance should be first (30 min total)
        #expect(vm.patternBreakdown[0].patternId == "resonance")
        #expect(vm.patternBreakdown[0].totalMinutes == 30.0)
        #expect(vm.patternBreakdown[0].sessionCount == 2)
        #expect(vm.patternBreakdown[0].proportion == 1.0)
        // Box second (5 min)
        #expect(vm.patternBreakdown[1].patternId == "box")
        #expect(vm.patternBreakdown[1].totalMinutes == 5.0)
        #expect(vm.patternBreakdown[1].sessionCount == 1)
    }

    // MARK: - Monthly Heatmap

    @Test("Monthly data includes correct number of day cells")
    @MainActor
    func monthlyDayData() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [
            makeSession(patternId: "resonance", daysAgo: 0, durationMinutes: 10),
        ]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        // Should have day cells (leading blanks + days in month)
        #expect(vm.monthlyDayData.count > 28)
        // At least one cell should be current month
        let currentMonthCells = vm.monthlyDayData.filter { $0.isCurrentMonth }
        #expect(currentMonthCells.count >= 28)
        #expect(currentMonthCells.count <= 31)
    }

    @Test("Monthly data marks today correctly")
    @MainActor
    func monthlyTodayMarker() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSession(daysAgo: 0, durationMinutes: 5)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        let todayCells = vm.monthlyDayData.filter { $0.isToday }
        #expect(todayCells.count == 1)
    }

    // MARK: - Month Navigation

    @Test("Month navigation changes displayed month")
    @MainActor
    func monthNavigation() async throws {
        let repo = MockBreathSessionRepository()
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()
        let initialMonth = vm.displayedMonthFormatted

        await vm.navigateMonth(by: -1)
        let previousMonth = vm.displayedMonthFormatted

        #expect(initialMonth != previousMonth)
    }

    // MARK: - Heat Intensity

    @Test("Heat intensity thresholds are correct")
    @MainActor
    func heatIntensity() async throws {
        let repo = MockBreathSessionRepository()
        let vm = ProgressViewModel(sessionRepository: repo)

        // Test intensity through DayCell
        let noneCell = ProgressViewModel.DayCell(id: "test-0", day: 1, isCurrentMonth: true, isToday: false, totalMinutes: 0)
        let lightCell = ProgressViewModel.DayCell(id: "test-1", day: 2, isCurrentMonth: true, isToday: false, totalMinutes: 3)
        let moderateCell = ProgressViewModel.DayCell(id: "test-2", day: 3, isCurrentMonth: true, isToday: false, totalMinutes: 10)
        let deepCell = ProgressViewModel.DayCell(id: "test-3", day: 4, isCurrentMonth: true, isToday: false, totalMinutes: 20)

        #expect(noneCell.intensity == .none)
        #expect(lightCell.intensity == .light)
        #expect(moderateCell.intensity == .moderate)
        #expect(deepCell.intensity == .deep)
    }

    // MARK: - Formatted Values

    @Test("Total minutes formatted correctly")
    @MainActor
    func formattedMinutes() async throws {
        let repo = MockBreathSessionRepository()
        repo.sessions = [makeSession(durationMinutes: 25)]
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        #expect(vm.totalMinutesFormatted == "25")
    }

    // MARK: - Error Handling

    @Test("Error state is set on repository failure")
    @MainActor
    func errorHandling() async throws {
        let repo = MockBreathSessionRepository()
        repo.shouldThrow = true
        let vm = ProgressViewModel(sessionRepository: repo)

        await vm.loadData()

        #expect(vm.error != nil)
        #expect(vm.isLoading == false)
    }
}
