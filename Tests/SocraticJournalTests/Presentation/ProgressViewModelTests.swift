// ProgressViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

@Suite("ProgressViewModel Tests")
@MainActor
struct ProgressViewModelTests {

    // MARK: - Helpers

    private func makeSession(
        patternId: String = "resonance",
        daysAgo: Int = 0,
        hour: Int = 8,
        durationMinutes: Double = 5
    ) -> BreathSession {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        let startedAt = calendar.date(byAdding: .hour, value: hour, to: date)!
        let totalDuration = durationMinutes * 60
        return BreathSession(
            patternId: patternId,
            startedAt: startedAt,
            completedAt: startedAt.addingTimeInterval(totalDuration),
            totalDuration: totalDuration,
            cyclesCompleted: Int(durationMinutes) * 5
        )
    }

    private func makeViewModel(sessions: [BreathSession] = [], dailyGoal: Int = 5) -> (ProgressViewModel, MockBreathSessionRepository, MockSettingsRepository) {
        let repo = MockBreathSessionRepository(sessions: sessions)
        let settingsRepo = MockSettingsRepository()
        settingsRepo.settings.dailyGoalMinutes = dailyGoal
        let vm = ProgressViewModel(sessionRepository: repo, settingsRepository: settingsRepo)
        return (vm, repo, settingsRepo)
    }

    // MARK: - Weekly Totals

    @Test("Weekly total minutes computed correctly from sessions across 7 days")
    func weeklyTotalMinutes() async {
        let sessions = [
            makeSession(daysAgo: 0, durationMinutes: 5),
            makeSession(daysAgo: 1, durationMinutes: 10),
            makeSession(daysAgo: 3, durationMinutes: 3),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.totalMinutes == 18.0)
        #expect(vm.totalSessions == 3)
    }

    @Test("Weekly total with zero sessions returns all zeros")
    func weeklyTotalZeroSessions() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadData()

        #expect(vm.totalMinutes == 0)
        #expect(vm.totalSessions == 0)
        #expect(vm.averagePerDay == 0)
    }

    @Test("Average per day calculation — total minutes / 7")
    func averagePerDay() async {
        // 14 minutes over 7 days = 2.0 min/day
        let sessions = [
            makeSession(daysAgo: 0, durationMinutes: 7),
            makeSession(daysAgo: 2, durationMinutes: 7),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.averagePerDay == 2.0)
    }

    // MARK: - Pattern Distribution

    @Test("Pattern distribution percentage calculation")
    func patternDistributionPercentage() async {
        let sessions = [
            makeSession(patternId: "resonance", daysAgo: 0),
            makeSession(patternId: "resonance", daysAgo: 1),
            makeSession(patternId: "resonance", daysAgo: 2),
            makeSession(patternId: "box", daysAgo: 0),
            makeSession(patternId: "box", daysAgo: 1),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.patternStats.count == 2)
        let resonance = vm.patternStats.first { $0.id == "resonance" }
        let box = vm.patternStats.first { $0.id == "box" }
        #expect(resonance?.percentage == 60)
        #expect(box?.percentage == 40)
    }

    @Test("Pattern distribution sorted by most-used first")
    func patternDistributionSorted() async {
        let sessions = [
            makeSession(patternId: "box", daysAgo: 0),
            makeSession(patternId: "box", daysAgo: 1),
            makeSession(patternId: "box", daysAgo: 2),
            makeSession(patternId: "resonance", daysAgo: 0),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.patternStats.first?.id == "box")
        #expect(vm.patternStats.first?.count == 3)
    }

    // MARK: - Date Grouping

    @Test("Session date grouping — sessions on same day grouped together")
    func sessionDateGrouping() async {
        let sessions = [
            makeSession(daysAgo: 0, hour: 8),
            makeSession(daysAgo: 0, hour: 18),
            makeSession(daysAgo: 1, hour: 10),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.dateGroups.count == 2)
        #expect(vm.dateGroups.first?.sessions.count == 2) // today
        #expect(vm.dateGroups.last?.sessions.count == 1) // yesterday
    }

    @Test("Date group labels — today and yesterday")
    func dateGroupLabels() async {
        let sessions = [
            makeSession(daysAgo: 0),
            makeSession(daysAgo: 1),
            makeSession(daysAgo: 3),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.dateGroups.count == 3)
        #expect(vm.dateGroups[0].label == "TODAY")
        #expect(vm.dateGroups[1].label == "YESTERDAY")
        // Third group should be a formatted date (not empty)
        #expect(!vm.dateGroups[2].label.isEmpty)
        #expect(vm.dateGroups[2].label != "TODAY")
        #expect(vm.dateGroups[2].label != "YESTERDAY")
    }

    // MARK: - Summary Stats Edge Cases

    @Test("Summary stats with sessions spanning multiple days")
    func summaryStatsMultipleDays() async {
        let sessions = [
            makeSession(daysAgo: 0, durationMinutes: 5),
            makeSession(daysAgo: 1, durationMinutes: 10),
            makeSession(daysAgo: 2, durationMinutes: 3),
            makeSession(daysAgo: 5, durationMinutes: 7),
        ]
        let (vm, _, _) = makeViewModel(sessions: sessions)
        await vm.loadData()

        #expect(vm.totalMinutes == 25.0)
        #expect(vm.totalSessions == 4)
        let expected = 25.0 / 7.0
        #expect(abs(vm.averagePerDay - expected) < 0.01)
    }

    // MARK: - Formatting

    @Test("patternName returns correct name for known pattern IDs")
    func patternNameKnown() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.patternName(for: "resonance") == "Resonance")
        #expect(vm.patternName(for: "box") == "Box")
    }

    @Test("patternName returns raw ID for unknown pattern IDs")
    func patternNameUnknown() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.patternName(for: "unknown_pattern") == "unknown_pattern")
    }

    @Test("patternInitial returns first letter")
    func patternInitial() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.patternInitial(for: "resonance") == "R")
        #expect(vm.patternInitial(for: "box") == "B")
    }

    @Test("sessionDurationFormatted formats correctly")
    func sessionDurationFormatted() {
        let (vm, _, _) = makeViewModel()
        let session300 = makeSession(durationMinutes: 5)
        #expect(vm.sessionDurationFormatted(session300) == "5 min")

        let session312 = BreathSession(
            patternId: "resonance",
            startedAt: Date(),
            completedAt: Date().addingTimeInterval(312),
            totalDuration: 312,
            cyclesCompleted: 28
        )
        #expect(vm.sessionDurationFormatted(session312) == "5 min 12s")
    }

    @Test("sessionTimeFormatted returns HH:mm format")
    func sessionTimeFormatted() {
        let (vm, _, _) = makeViewModel()
        let session = makeSession()
        let result = vm.sessionTimeFormatted(session)
        // Should be in HH:mm format (non-empty, contains ":")
        #expect(!result.isEmpty)
        #expect(result.contains(":"))
    }
}
#endif
