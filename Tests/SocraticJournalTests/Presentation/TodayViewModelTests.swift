// TodayViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

@Suite("TodayViewModel Tests")
@MainActor
struct TodayViewModelTests {

    private func makeSUT(
        sessions: [BreathSession] = [],
        streak: Int = 0,
        settings: UserSettings = .default
    ) -> (TodayViewModel, MockBreathSessionRepository, MockSettingsRepository) {
        let sessionRepo = MockBreathSessionRepository(sessions: sessions)
        sessionRepo.streakValue = streak
        let settingsRepo = MockSettingsRepository(settings: settings)
        let viewModel = TodayViewModel(
            sessionRepository: sessionRepo,
            settingsRepository: settingsRepo
        )
        return (viewModel, sessionRepo, settingsRepo)
    }

    @Test("greeting returns correct greeting for time of day")
    func greetingCorrectForTimeOfDay() {
        let (vm, _, _) = makeSUT()
        let greeting = vm.greeting
        // Should be one of the three greetings
        let validGreetings = ["Good morning.", "Good afternoon.", "Good evening."]
        #expect(validGreetings.contains(greeting))
    }

    @Test("dateString is non-empty")
    func dateStringNonEmpty() {
        let (vm, _, _) = makeSUT()
        #expect(!vm.dateString.isEmpty)
    }

    @Test("goalReached when totalMinutesToday >= dailyGoalMinutes")
    func goalReachedTrue() async {
        let now = Date()
        let sessions = [
            BreathSession(patternId: "resonance", startedAt: now, completedAt: now.addingTimeInterval(300), totalDuration: 300, cyclesCompleted: 27),
        ]
        let (vm, _, _) = makeSUT(sessions: sessions, settings: UserSettings(dailyGoalMinutes: 5))

        await vm.loadData()

        // 300 seconds = 5.0 minutes >= 5 goal
        #expect(vm.goalReached)
    }

    @Test("goalReached false when totalMinutesToday < dailyGoalMinutes")
    func goalReachedFalse() async {
        let now = Date()
        let sessions = [
            BreathSession(patternId: "resonance", startedAt: now, completedAt: now.addingTimeInterval(120), totalDuration: 120, cyclesCompleted: 10),
        ]
        let (vm, _, _) = makeSUT(sessions: sessions, settings: UserSettings(dailyGoalMinutes: 5))

        await vm.loadData()

        // 120 seconds = 2.0 minutes < 5 goal
        #expect(!vm.goalReached)
    }

    @Test("loadData populates streak from repository")
    func loadDataPopulatesStreak() async {
        let (vm, _, _) = makeSUT(streak: 7)
        await vm.loadData()
        #expect(vm.streak == 7)
    }

    @Test("patternName returns correct name for known pattern IDs")
    func patternNameKnown() {
        let (vm, _, _) = makeSUT()
        #expect(vm.patternName(for: "resonance") == "Resonance")
        #expect(vm.patternName(for: "box") == "Box")
        #expect(vm.patternName(for: "478") == "4-7-8")
        #expect(vm.patternName(for: "wim") == "Tummo / Power")
    }

    @Test("patternName returns raw ID for unknown pattern IDs")
    func patternNameUnknown() {
        let (vm, _, _) = makeSUT()
        #expect(vm.patternName(for: "unknown_pattern") == "unknown_pattern")
    }

    @Test("sessionDurationFormatted formats minutes correctly")
    func sessionDurationFormatted() {
        let (vm, _, _) = makeSUT()
        let now = Date()
        let session = BreathSession(
            patternId: "resonance",
            startedAt: now,
            completedAt: now.addingTimeInterval(312),
            totalDuration: 312,
            cyclesCompleted: 28
        )
        #expect(vm.sessionDurationFormatted(session) == "5 min")
    }
}
#endif
