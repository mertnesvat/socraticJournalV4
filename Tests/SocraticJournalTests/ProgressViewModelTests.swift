// ProgressViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("ProgressViewModel Tests")
struct ProgressViewModelTests {

    // MARK: - Load Data Success

    @Suite("Load Data Success")
    struct LoadDataSuccessTests {

        @Test("loadData sets total minutes from repository")
        @MainActor
        func loadDataSetsTotalMinutes() async {
            let repo = MockBreathSessionRepository()
            repo.totalMinutesToReturn = 42.5
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.totalMinutes == 42.5)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.error == nil)
        }

        @Test("loadData sets total sessions from repository")
        @MainActor
        func loadDataSetsTotalSessions() async {
            let repo = MockBreathSessionRepository()
            let now = Date()
            repo.savedSessions = [
                BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                              startedAt: now, completedAt: now.addingTimeInterval(300),
                              targetDuration: 300, cyclesCompleted: 5),
                BreathSession(techniqueId: "box", techniqueName: "Box",
                              startedAt: now, completedAt: now.addingTimeInterval(240),
                              targetDuration: 300, cyclesCompleted: 4)
            ]
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.totalSessions == 2)
        }

        @Test("loadData sets streak from repository")
        @MainActor
        func loadDataSetsStreak() async {
            let repo = MockBreathSessionRepository()
            repo.streakToReturn = 5
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.streak == 5)
        }

        @Test("loadData loads all sessions")
        @MainActor
        func loadDataLoadsAllSessions() async {
            let repo = MockBreathSessionRepository()
            let now = Date()
            repo.savedSessions = [
                BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                              startedAt: now, completedAt: now.addingTimeInterval(300),
                              targetDuration: 300, cyclesCompleted: 5)
            ]
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.allSessions.count == 1)
            #expect(viewModel.hasData == true)
        }

        @Test("loadData with no sessions shows empty state")
        @MainActor
        func loadDataEmptySessions() async {
            let repo = MockBreathSessionRepository()
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.allSessions.isEmpty)
            #expect(viewModel.hasData == false)
            #expect(viewModel.totalMinutes == 0)
            #expect(viewModel.totalSessions == 0)
            #expect(viewModel.streak == 0)
        }
    }

    // MARK: - Load Data Error

    @Suite("Load Data Error")
    struct LoadDataErrorTests {

        @Test("loadData sets error when repository fails")
        @MainActor
        func loadDataSetsError() async {
            let repo = MockBreathSessionRepository()
            repo.shouldFail = true
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.error != nil)
            #expect(viewModel.isLoading == false)
        }

        @Test("isLoading is false after error")
        @MainActor
        func isLoadingFalseAfterError() async {
            let repo = MockBreathSessionRepository()
            repo.shouldFail = true
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.isLoading == false)
        }
    }

    // MARK: - Computed Properties

    @Suite("Computed Properties")
    struct ComputedPropertyTests {

        @Test("formattedTotalMinutes returns whole number string")
        @MainActor
        func formattedTotalMinutesReturnsWholeNumber() async {
            let repo = MockBreathSessionRepository()
            repo.totalMinutesToReturn = 42.7
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.formattedTotalMinutes == "42")
        }

        @Test("formattedTotalMinutes returns 0 for no sessions")
        @MainActor
        func formattedTotalMinutesZero() {
            let repo = MockBreathSessionRepository()
            let viewModel = ProgressViewModel(repository: repo)

            #expect(viewModel.formattedTotalMinutes == "0")
        }

        @Test("sessionsByDate groups sessions by calendar day")
        @MainActor
        func sessionsByDateGroupsCorrectly() async {
            let repo = MockBreathSessionRepository()
            let calendar = Calendar.current
            let now = Date()
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

            repo.savedSessions = [
                BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                              startedAt: now, completedAt: now.addingTimeInterval(300),
                              targetDuration: 300, cyclesCompleted: 5),
                BreathSession(techniqueId: "box", techniqueName: "Box",
                              startedAt: now.addingTimeInterval(-3600),
                              completedAt: now.addingTimeInterval(-3600 + 180),
                              targetDuration: 300, cyclesCompleted: 3),
                BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                              startedAt: yesterday, completedAt: yesterday.addingTimeInterval(600),
                              targetDuration: 600, cyclesCompleted: 10)
            ]
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            let grouped = viewModel.sessionsByDate
            #expect(grouped.count == 2)
            // Most recent date first
            #expect(grouped.first?.date == calendar.startOfDay(for: now))
        }

        @Test("sessionsByDate is empty when no sessions")
        @MainActor
        func sessionsByDateEmpty() {
            let repo = MockBreathSessionRepository()
            let viewModel = ProgressViewModel(repository: repo)

            #expect(viewModel.sessionsByDate.isEmpty)
        }

        @Test("currentMonthSessionsByDay filters to current month")
        @MainActor
        func currentMonthSessionsByDayFilters() async {
            let repo = MockBreathSessionRepository()
            let calendar = Calendar.current
            let now = Date()

            // Session today (current month)
            let todaySession = BreathSession(
                techniqueId: "resonance", techniqueName: "Resonance",
                startedAt: now, completedAt: now.addingTimeInterval(300),
                targetDuration: 300, cyclesCompleted: 5
            )

            // Session from 2 months ago (should be excluded)
            let oldDate = calendar.date(byAdding: .month, value: -2, to: now)!
            let oldSession = BreathSession(
                techniqueId: "box", techniqueName: "Box",
                startedAt: oldDate, completedAt: oldDate.addingTimeInterval(300),
                targetDuration: 300, cyclesCompleted: 5
            )

            repo.savedSessions = [todaySession, oldSession]
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            let monthSessions = viewModel.currentMonthSessionsByDay
            #expect(monthSessions.count == 1)
            #expect(monthSessions[calendar.startOfDay(for: now)]?.count == 1)
        }

        @Test("hasData is true when sessions exist")
        @MainActor
        func hasDataTrue() async {
            let repo = MockBreathSessionRepository()
            let now = Date()
            repo.savedSessions = [
                BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                              startedAt: now, completedAt: now.addingTimeInterval(300),
                              targetDuration: 300, cyclesCompleted: 5)
            ]
            let viewModel = ProgressViewModel(repository: repo)

            await viewModel.loadData()

            #expect(viewModel.hasData == true)
        }

        @Test("hasData is false when no sessions")
        @MainActor
        func hasDataFalse() {
            let repo = MockBreathSessionRepository()
            let viewModel = ProgressViewModel(repository: repo)

            #expect(viewModel.hasData == false)
        }
    }
}
