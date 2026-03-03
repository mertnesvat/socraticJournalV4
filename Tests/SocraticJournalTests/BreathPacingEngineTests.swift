// BreathPacingEngineTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for the BreathPacingEngine — core timing, phase progression, and state management
@Suite("Breath Pacing Engine Tests")
struct BreathPacingEngineTests {

    // Helper to create engine and start a session without CADisplayLink
    @MainActor
    private func makeEngine(
        technique: BreathTechnique = .resonance,
        duration: TimeInterval = 300
    ) -> BreathPacingEngine {
        let engine = BreathPacingEngine()
        engine.startSession(technique: technique, duration: duration, useDisplayLink: false)
        return engine
    }

    // MARK: - Initial State

    @Suite("Initial State")
    struct InitialStateTests {

        @Test("Engine starts with correct initial state")
        @MainActor
        func initialState() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            #expect(engine.technique == .resonance)
            #expect(engine.currentPhaseIndex == 0)
            #expect(engine.currentPhase.phaseType == .inhale)
            #expect(engine.phaseProgress == 0.0)
            #expect(engine.elapsedTime == 0.0)
            #expect(engine.cyclesCompleted == 0)
            #expect(engine.isActive)
            #expect(!engine.isPaused)
            #expect(!engine.isComplete)
            #expect(engine.targetDuration == 300)
            #expect(engine.sessionProgress == 0.0)
        }

        @Test("Breath position starts at 0 for inhale phase")
        @MainActor
        func breathPositionStartsAtZero() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)
            #expect(engine.breathPosition == 0.0)
        }

        @Test("Phase time remaining equals phase duration at start")
        @MainActor
        func phaseTimeRemainingAtStart() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)
            #expect(engine.phaseTimeRemaining == 5.5)
        }
    }

    // MARK: - Phase Progression

    @Suite("Phase Progression")
    struct PhaseProgressionTests {

        @Test("Advancing within a phase updates progress")
        @MainActor
        func advanceWithinPhase() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 2.75) // Half of 5.5s inhale
            #expect(engine.phaseProgress > 0.49)
            #expect(engine.phaseProgress < 0.51)
            #expect(engine.currentPhase.phaseType == .inhale)
        }

        @Test("Completing inhale phase advances to exhale for resonance")
        @MainActor
        func inhaleToExhaleResonance() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            // Advance past the 5.5s inhale
            engine.advance(by: 5.5)
            #expect(engine.currentPhase.phaseType == .exhale)
            #expect(engine.currentPhaseIndex == 1)
        }

        @Test("Box breathing cycles through all 4 phases")
        @MainActor
        func boxBreathingAllPhases() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .box, duration: 300, useDisplayLink: false)

            // Phase 0: inhale (4s)
            #expect(engine.currentPhase.phaseType == .inhale)
            engine.advance(by: 4.0)

            // Phase 1: holdAfterInhale (4s)
            #expect(engine.currentPhase.phaseType == .holdAfterInhale)
            engine.advance(by: 4.0)

            // Phase 2: exhale (4s)
            #expect(engine.currentPhase.phaseType == .exhale)
            engine.advance(by: 4.0)

            // Phase 3: holdAfterExhale (4s)
            #expect(engine.currentPhase.phaseType == .holdAfterExhale)
        }

        @Test("4-7-8 technique cycles through 3 phases")
        @MainActor
        func fourSevenEightPhases() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .fourSevenEight, duration: 300, useDisplayLink: false)

            // Phase 0: inhale (4s)
            #expect(engine.currentPhase.phaseType == .inhale)
            engine.advance(by: 4.0)

            // Phase 1: holdAfterInhale (7s)
            #expect(engine.currentPhase.phaseType == .holdAfterInhale)
            engine.advance(by: 7.0)

            // Phase 2: exhale (8s)
            #expect(engine.currentPhase.phaseType == .exhale)
        }

        @Test("Completing a full cycle increments cyclesCompleted")
        @MainActor
        func cycleCompletion() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            #expect(engine.cyclesCompleted == 0)

            // Complete one cycle: 5.5s inhale + 5.5s exhale = 11s
            engine.advance(by: 5.5) // inhale complete
            engine.advance(by: 5.5) // exhale complete

            #expect(engine.cyclesCompleted == 1)
            // Should be back to inhale
            #expect(engine.currentPhase.phaseType == .inhale)
            #expect(engine.currentPhaseIndex == 0)
        }

        @Test("Multiple cycles count correctly")
        @MainActor
        func multipleCycles() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .coherent, duration: 300, useDisplayLink: false)

            // Each cycle is 12s (6+6)
            // Complete 3 cycles
            for _ in 0..<3 {
                engine.advance(by: 6.0) // inhale
                engine.advance(by: 6.0) // exhale
            }

            #expect(engine.cyclesCompleted == 3)
        }

        @Test("Box breathing cycle counts correctly")
        @MainActor
        func boxCycleCount() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .box, duration: 300, useDisplayLink: false)

            // One box cycle = 16s (4+4+4+4)
            engine.advance(by: 4.0) // inhale
            engine.advance(by: 4.0) // hold
            engine.advance(by: 4.0) // exhale
            engine.advance(by: 4.0) // hold

            #expect(engine.cyclesCompleted == 1)
        }
    }

    // MARK: - Breath Position

    @Suite("Breath Position")
    struct BreathPositionTests {

        @Test("Breath position is 0 at start of inhale")
        @MainActor
        func breathPositionStartInhale() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)
            #expect(engine.breathPosition == 0.0)
        }

        @Test("Breath position rises during inhale")
        @MainActor
        func breathPositionRisesDuringInhale() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 2.75) // Mid-inhale
            #expect(engine.breathPosition > 0.3)
            #expect(engine.breathPosition < 0.7)
        }

        @Test("Breath position is 1.0 during holdAfterInhale")
        @MainActor
        func breathPositionDuringHoldAfterInhale() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .box, duration: 300, useDisplayLink: false)

            engine.advance(by: 4.0) // Complete inhale → now in holdAfterInhale
            #expect(engine.currentPhase.phaseType == .holdAfterInhale)
            #expect(engine.breathPosition == 1.0)

            engine.advance(by: 2.0) // Mid-hold
            #expect(engine.breathPosition == 1.0)
        }

        @Test("Breath position falls during exhale")
        @MainActor
        func breathPositionFallsDuringExhale() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 5.5) // Complete inhale → exhale
            #expect(engine.currentPhase.phaseType == .exhale)

            engine.advance(by: 2.75) // Mid-exhale
            #expect(engine.breathPosition > 0.3)
            #expect(engine.breathPosition < 0.7)
        }

        @Test("Breath position is 0.0 during holdAfterExhale")
        @MainActor
        func breathPositionDuringHoldAfterExhale() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .box, duration: 300, useDisplayLink: false)

            engine.advance(by: 4.0) // inhale
            engine.advance(by: 4.0) // holdAfterInhale
            engine.advance(by: 4.0) // exhale → now in holdAfterExhale
            #expect(engine.currentPhase.phaseType == .holdAfterExhale)
            #expect(engine.breathPosition == 0.0)
        }

        @Test("Resonance breathing produces 0→1→0 wave (no holds)")
        @MainActor
        func resonanceWavePattern() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            // Start: 0
            #expect(engine.breathPosition == 0.0)

            // Mid-inhale: rising
            engine.advance(by: 2.75)
            let midInhale = engine.breathPosition
            #expect(midInhale > 0.0)
            #expect(midInhale < 1.0)

            // End inhale → start exhale
            engine.advance(by: 2.75)
            #expect(engine.currentPhase.phaseType == .exhale)

            // Mid-exhale: falling
            engine.advance(by: 2.75)
            let midExhale = engine.breathPosition
            #expect(midExhale > 0.0)
            #expect(midExhale < 1.0)
        }
    }

    // MARK: - Pause / Resume

    @Suite("Pause and Resume")
    struct PauseResumeTests {

        @Test("Pause freezes all state")
        @MainActor
        func pauseFreezesState() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 2.0)
            let progressBeforePause = engine.phaseProgress
            let elapsedBeforePause = engine.elapsedTime

            engine.pause()
            #expect(engine.isPaused)

            // Attempting to advance while paused should do nothing
            engine.advance(by: 5.0)
            #expect(engine.phaseProgress == progressBeforePause)
            #expect(engine.elapsedTime == elapsedBeforePause)
        }

        @Test("Resume continues from exact pause point")
        @MainActor
        func resumeFromPausePoint() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 2.0)
            let elapsedBeforePause = engine.elapsedTime
            engine.pause()
            engine.resume()

            #expect(!engine.isPaused)

            engine.advance(by: 1.0)
            // Should have advanced by exactly 1s from the pause point
            #expect(abs(engine.elapsedTime - (elapsedBeforePause + 1.0)) < 0.001)
        }

        @Test("Pause on inactive engine does nothing")
        @MainActor
        func pauseWhenInactive() {
            let engine = BreathPacingEngine()
            engine.pause()
            #expect(!engine.isPaused)
        }

        @Test("Double pause does nothing")
        @MainActor
        func doublePause() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)
            engine.pause()
            engine.pause() // Should be idempotent
            #expect(engine.isPaused)
        }
    }

    // MARK: - Session Completion

    @Suite("Session Completion")
    struct SessionCompletionTests {

        @Test("Session completes at end of cycle boundary after target duration")
        @MainActor
        func completesAtCycleBoundary() {
            let engine = BreathPacingEngine()
            // Resonance cycle = 11s. Target 11s = exactly 1 cycle
            engine.startSession(technique: .resonance, duration: 11.0, useDisplayLink: false)

            engine.advance(by: 5.5) // inhale complete
            #expect(!engine.isComplete)

            engine.advance(by: 5.5) // exhale complete — cycle done, elapsed >= target
            #expect(engine.isComplete)
            #expect(!engine.isActive)
            #expect(engine.cyclesCompleted == 1)
        }

        @Test("Session never cuts mid-phase — finishes current cycle")
        @MainActor
        func neverCutsMidPhase() {
            let engine = BreathPacingEngine()
            // Resonance cycle = 11s. Target 8s = mid-exhale, should finish the cycle
            engine.startSession(technique: .resonance, duration: 8.0, useDisplayLink: false)

            engine.advance(by: 5.5) // inhale complete — elapsed 5.5, past nothing yet
            #expect(!engine.isComplete)

            // Elapsed is now 5.5 + 2.5 = 8.0, target reached, but mid-exhale
            engine.advance(by: 2.5)
            #expect(!engine.isComplete) // Should NOT complete mid-phase

            // Finish the exhale phase
            engine.advance(by: 3.0)
            #expect(engine.isComplete)
            #expect(engine.cyclesCompleted == 1)
        }

        @Test("Session completion for box breathing finishes full cycle")
        @MainActor
        func boxBreathingCompletion() {
            let engine = BreathPacingEngine()
            // Box cycle = 16s. Target 5s = way before cycle end
            engine.startSession(technique: .box, duration: 5.0, useDisplayLink: false)

            engine.advance(by: 4.0) // inhale
            engine.advance(by: 4.0) // hold
            #expect(!engine.isComplete) // Need to finish cycle

            engine.advance(by: 4.0) // exhale
            engine.advance(by: 4.0) // hold → cycle complete
            #expect(engine.isComplete)
            #expect(engine.cyclesCompleted == 1)
        }

        @Test("Completed engine ignores further advances")
        @MainActor
        func completedEngineIgnoresAdvances() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 11.0, useDisplayLink: false)

            engine.advance(by: 5.5)
            engine.advance(by: 5.5) // Complete
            #expect(engine.isComplete)

            let cyclesBefore = engine.cyclesCompleted
            engine.advance(by: 100.0) // Should be ignored
            #expect(engine.cyclesCompleted == cyclesBefore)
        }
    }

    // MARK: - Stop & BreathSession

    @Suite("Stop and Session Record")
    struct StopAndSessionTests {

        @Test("Stop returns BreathSession with correct technique info")
        @MainActor
        func stopReturnsCorrectTechniqueInfo() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .box, duration: 300, useDisplayLink: false)

            engine.advance(by: 16.0) // One cycle
            let session = engine.stop()

            #expect(session.techniqueId == "box")
            #expect(session.techniqueName == "Box Breathing")
            #expect(session.targetDuration == 300)
        }

        @Test("Stop mid-session returns nil completedAt")
        @MainActor
        func stopMidSessionNoCompletedAt() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 30.0)
            let session = engine.stop()

            #expect(session.completedAt == nil)
            #expect(!session.isCompleted)
        }

        @Test("Stop after natural completion returns completedAt")
        @MainActor
        func stopAfterCompletionHasCompletedAt() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 11.0, useDisplayLink: false)

            engine.advance(by: 5.5)
            engine.advance(by: 5.5) // Complete

            let session = engine.stop()
            #expect(session.completedAt != nil)
            #expect(session.isCompleted)
            #expect(session.cyclesCompleted == 1)
        }

        @Test("Stop sets isActive to false")
        @MainActor
        func stopSetsInactive() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)
            _ = engine.stop()
            #expect(!engine.isActive)
        }

        @Test("Cycle count is accurate in session record")
        @MainActor
        func cycleCountAccurate() {
            let engine = BreathPacingEngine()
            // Coherent cycle = 12s, target = 36s → 3 cycles
            engine.startSession(technique: .coherent, duration: 36.0, useDisplayLink: false)

            for _ in 0..<3 {
                engine.advance(by: 6.0) // inhale
                engine.advance(by: 6.0) // exhale
            }

            let session = engine.stop()
            #expect(session.cyclesCompleted == 3)
        }
    }

    // MARK: - Session Progress

    @Suite("Session Progress")
    struct SessionProgressTests {

        @Test("Session progress tracks elapsed vs target")
        @MainActor
        func sessionProgressTracking() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 100.0, useDisplayLink: false)

            engine.advance(by: 0.016) // Small advance to ensure we have a valid state
            engine.advance(by: 50.0 - 0.016)
            // Should be ~50%
            #expect(engine.sessionProgress > 0.49)
            #expect(engine.sessionProgress < 0.51)
        }

        @Test("Session progress caps at 1.0")
        @MainActor
        func sessionProgressCapsAtOne() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 10.0, useDisplayLink: false)

            // Advance way past target (session won't complete until cycle ends)
            engine.advance(by: 5.5)
            // Now elapsed is 5.5 out of 10 target, but session progress should be building
            engine.advance(by: 5.0) // elapsed = 10.5, > target
            #expect(engine.sessionProgress == 1.0)
        }

        @Test("Elapsed time tracks accurately through phases")
        @MainActor
        func elapsedTimeAccurate() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 5.5)
            engine.advance(by: 3.0)
            #expect(abs(engine.elapsedTime - 8.5) < 0.01)
        }
    }

    // MARK: - All Techniques

    @Suite("All Techniques Work Correctly")
    struct AllTechniquesTests {

        @Test("Resonance: 2-phase cycle works")
        @MainActor
        func resonanceCycle() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            #expect(engine.technique.phases.count == 2)
            engine.advance(by: 5.5)
            #expect(engine.currentPhase.phaseType == .exhale)
            engine.advance(by: 5.5)
            #expect(engine.cyclesCompleted == 1)
            #expect(engine.currentPhase.phaseType == .inhale)
        }

        @Test("Coherent: 2-phase cycle works")
        @MainActor
        func coherentCycle() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .coherent, duration: 300, useDisplayLink: false)

            #expect(engine.technique.phases.count == 2)
            engine.advance(by: 6.0)
            #expect(engine.currentPhase.phaseType == .exhale)
            engine.advance(by: 6.0)
            #expect(engine.cyclesCompleted == 1)
        }

        @Test("Box: 4-phase cycle works")
        @MainActor
        func boxCycle() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .box, duration: 300, useDisplayLink: false)

            #expect(engine.technique.phases.count == 4)
            engine.advance(by: 4.0) // inhale
            engine.advance(by: 4.0) // hold
            engine.advance(by: 4.0) // exhale
            engine.advance(by: 4.0) // hold
            #expect(engine.cyclesCompleted == 1)
        }

        @Test("4-7-8: 3-phase cycle works")
        @MainActor
        func fourSevenEightCycle() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .fourSevenEight, duration: 300, useDisplayLink: false)

            #expect(engine.technique.phases.count == 3)
            engine.advance(by: 4.0)  // inhale
            #expect(engine.currentPhase.phaseType == .holdAfterInhale)
            engine.advance(by: 7.0)  // hold
            #expect(engine.currentPhase.phaseType == .exhale)
            engine.advance(by: 8.0)  // exhale
            #expect(engine.cyclesCompleted == 1)
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {

        @Test("Very small delta still advances correctly")
        @MainActor
        func verySmallDelta() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            // Simulate 60fps for half a second
            for _ in 0..<30 {
                engine.advance(by: 1.0 / 60.0)
            }

            #expect(abs(engine.elapsedTime - 0.5) < 0.01)
            #expect(engine.phaseProgress > 0.0)
        }

        @Test("Large delta advances correctly through multiple phases")
        @MainActor
        func largeDeltaAdvances() {
            let engine = BreathPacingEngine()
            // Resonance cycle = 11s, target = 22s
            engine.startSession(technique: .resonance, duration: 22.0, useDisplayLink: false)

            // Advance by 22s in one step: elapsed hits target immediately,
            // then completes at first cycle boundary
            engine.advance(by: 22.0)
            #expect(engine.isComplete)
            #expect(engine.cyclesCompleted >= 1)
        }

        @Test("Starting a new session resets all state")
        @MainActor
        func restartResetsState() {
            let engine = BreathPacingEngine()
            engine.startSession(technique: .resonance, duration: 300, useDisplayLink: false)

            engine.advance(by: 5.5)
            engine.advance(by: 5.5)
            #expect(engine.cyclesCompleted == 1)

            // Start a new session
            engine.startSession(technique: .box, duration: 180, useDisplayLink: false)
            #expect(engine.cyclesCompleted == 0)
            #expect(engine.elapsedTime == 0)
            #expect(engine.technique == .box)
            #expect(engine.targetDuration == 180)
            #expect(engine.currentPhase.phaseType == .inhale)
        }
    }
}
