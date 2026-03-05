// BreatheViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

@Suite("BreatheViewModel Tests")
@MainActor
struct BreatheViewModelTests {

    private func makeSUT(
        sessions: [BreathSession] = [],
        settings: UserSettings = .default
    ) -> (BreatheViewModel, MockBreathSessionRepository, MockSettingsRepository) {
        let sessionRepo = MockBreathSessionRepository(sessions: sessions)
        let settingsRepo = MockSettingsRepository(settings: settings)
        let viewModel = BreatheViewModel(
            sessionRepository: sessionRepo,
            settingsRepository: settingsRepo
        )
        return (viewModel, sessionRepo, settingsRepo)
    }

    @Test("Initial state: selectedPattern is Resonance")
    func initialPattern() {
        let (vm, _, _) = makeSUT()
        #expect(vm.selectedPattern.id == "resonance")
    }

    @Test("Initial state: selectedDuration is five")
    func initialDuration() {
        let (vm, _, _) = makeSUT()
        #expect(vm.selectedDuration == .five)
    }

    @Test("selectPattern changes the selected pattern")
    func selectPatternChanges() {
        let (vm, _, _) = makeSUT()
        vm.selectPattern(.box)
        #expect(vm.selectedPattern.id == "box")
    }

    @Test("selectPattern is ignored when engine is running")
    func selectPatternIgnoredWhenRunning() {
        let (vm, _, _) = makeSUT()
        vm.engine.start(pattern: .resonance, duration: 300)
        vm.selectPattern(.box)
        #expect(vm.selectedPattern.id == "resonance")
        vm.engine.stop()
    }

    @Test("actionButtonLabel returns Begin when idle")
    func actionButtonLabelIdle() {
        let (vm, _, _) = makeSUT()
        #expect(vm.actionButtonLabel == "Begin")
    }

    @Test("showStopButton is false when not running")
    func showStopButtonFalseWhenIdle() {
        let (vm, _, _) = makeSUT()
        #expect(vm.showStopButton == false)
    }

    @Test("elapsedFormatted formats correctly")
    func elapsedFormatted() {
        let (vm, _, _) = makeSUT()
        // Engine totalElapsed is 0 initially
        #expect(vm.elapsedFormatted == "0:00")
    }

    @Test("Sessions under 5 seconds are not saved")
    func shortSessionsNotSaved() {
        let (vm, sessionRepo, _) = makeSUT()
        // handleSessionFinished with engine.totalElapsed = 0 (no session run)
        // The saveSession guard checks duration > 5
        vm.handleSessionFinished()

        // Give a moment for the Task to execute
        #expect(sessionRepo.saveSessionCalled == false)
    }
}
#endif
