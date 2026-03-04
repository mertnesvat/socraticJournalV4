// TodayDashboardViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("TodayDashboardViewModel Tests")
struct TodayDashboardViewModelTests {

    // MARK: - Load Data Success

    @Suite("Load Data Success")
    struct LoadDataSuccessTests {

        @Test("loadData sets streak from repository")
        @MainActor
        func loadDataSetsStreak() async {
            let sessionRepo = MockBreathSessionRepository()
            sessionRepo.streakToReturn = 7
            let settingsRepo = MockSettingsRepository()
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.streak == 7)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.error == nil)
        }

        @Test("loadData sets daily goal from settings")
        @MainActor
        func loadDataSetsDailyGoal() async {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository(settings: UserSettings(dailyGoalMinutes: 10))
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.dailyGoalMinutes == 10)
        }

        @Test("loadData calculates today's minutes from sessions")
        @MainActor
        func loadDataCalculatesTodayMinutes() async {
            let sessionRepo = MockBreathSessionRepository()
            let now = Date()
            // 5-minute session
            sessionRepo.savedSessions = [
                BreathSession(
                    techniqueId: "resonance",
                    techniqueName: "Resonance Breathing",
                    startedAt: now,
                    completedAt: now.addingTimeInterval(300),
                    targetDuration: 300,
                    cyclesCompleted: 5
                )
            ]
            let settingsRepo = MockSettingsRepository()
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.todayMinutes == 5.0)
        }

        @Test("loadData with no sessions shows empty state")
        @MainActor
        func loadDataEmptySessions() async {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository()
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.todaySessions.isEmpty)
            #expect(viewModel.hasTodaySessions == false)
            #expect(viewModel.todayMinutes == 0)
            #expect(viewModel.streak == 0)
        }

        @Test("loadData resolves lastUsedTechnique from settings")
        @MainActor
        func loadDataResolvesLastUsedTechnique() async {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository(
                settings: UserSettings(lastUsedTechniqueId: "box")
            )
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.lastUsedTechnique?.id == "box")
            #expect(viewModel.quickStartTechnique.id == "box")
        }

        @Test("loadData falls back to default technique when no lastUsed")
        @MainActor
        func loadDataFallsBackToDefault() async {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository(
                settings: UserSettings(defaultTechniqueId: "coherent", lastUsedTechniqueId: nil)
            )
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.lastUsedTechnique?.id == "coherent")
        }
    }

    // MARK: - Load Data Error

    @Suite("Load Data Error")
    struct LoadDataErrorTests {

        @Test("loadData sets error when session repository fails")
        @MainActor
        func loadDataSetsErrorOnSessionRepoFailure() async {
            let sessionRepo = MockBreathSessionRepository()
            sessionRepo.shouldFail = true
            let settingsRepo = MockSettingsRepository()
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.error != nil)
            #expect(viewModel.isLoading == false)
        }

        @Test("loadData sets error when settings repository fails")
        @MainActor
        func loadDataSetsErrorOnSettingsRepoFailure() async {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository()
            settingsRepo.shouldFail = true
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            await viewModel.loadData()

            #expect(viewModel.error != nil)
            #expect(viewModel.isLoading == false)
        }
    }

    // MARK: - Greeting

    @Suite("Greeting Computation")
    struct GreetingTests {

        @Test("quickStartTechnique defaults to resonance when no lastUsed")
        @MainActor
        func quickStartDefaultsToResonance() {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository()
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            // Before loading, lastUsedTechnique is nil
            #expect(viewModel.quickStartTechnique.id == "resonance")
        }

        @Test("hasTodaySessions is false when empty")
        @MainActor
        func hasTodaySessionsFalseWhenEmpty() {
            let sessionRepo = MockBreathSessionRepository()
            let settingsRepo = MockSettingsRepository()
            let viewModel = TodayDashboardViewModel(
                sessionRepository: sessionRepo,
                settingsRepository: settingsRepo
            )

            #expect(viewModel.hasTodaySessions == false)
        }
    }

    // MARK: - Tip of the Day

    @Suite("TipOfTheDayCard Content")
    struct TipOfTheDayTests {

        @Test("Tips array has at least 15 tips")
        func tipsArrayHasEnoughContent() {
            #expect(TipOfTheDayCard.tips.count >= 15)
        }

        @Test("All tips are non-empty strings")
        func allTipsAreNonEmpty() {
            for tip in TipOfTheDayCard.tips {
                #expect(!tip.isEmpty)
            }
        }
    }
}
