// BreathPacingEngine.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI
import UIKit

/// Core pacing engine that drives the breath session timing and animation state
@Observable
@MainActor
public final class BreathPacingEngine {
    // MARK: - State

    private(set) var technique: BreathTechnique
    private(set) var currentPhaseIndex: Int = 0
    private(set) var phaseProgress: Double = 0.0
    private(set) var phaseTimeRemaining: TimeInterval = 0
    private(set) var cyclesCompleted: Int = 0
    private(set) var totalElapsedTime: TimeInterval = 0
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var isComplete: Bool = false
    let sessionDurationTarget: TimeInterval

    /// The current phase of the breath cycle
    var currentPhase: BreathPhase {
        technique.phases[currentPhaseIndex]
    }

    /// Mountain wave progress: 0.0 at cycle start, 1.0 at cycle end
    var cycleProgress: Double {
        let cycleDuration = technique.cycleDuration
        guard cycleDuration > 0 else { return 0 }
        let elapsed = elapsedInCurrentCycle
        return elapsed / cycleDuration
    }

    /// Computed scale for a breathing circle (alternative visualization)
    var circleScale: Double {
        let phase = currentPhase
        let progress = easeInOut(phaseProgress)

        switch phase.phaseType {
        case .inhale:
            return lerp(0.4, 1.0, progress)
        case .exhale:
            return lerp(1.0, 0.4, progress)
        case .hold:
            let time = totalElapsedTime
            return 1.0 + sin(time * 4) * 0.02
        }
    }

    // MARK: - Private

    private var timer: Timer?
    private var phaseStartTime: TimeInterval = 0
    private var lastTickTime: TimeInterval = 0
    private var elapsedInCurrentCycle: TimeInterval = 0
    private let hapticSoft = UIImpactFeedbackGenerator(style: .soft)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)
    private let hapticSuccess = UINotificationFeedbackGenerator()

    // MARK: - Init

    public init(technique: BreathTechnique, durationMinutes: Int) {
        self.technique = technique
        self.sessionDurationTarget = TimeInterval(durationMinutes * 60)
        self.phaseTimeRemaining = technique.phases.first?.duration ?? 0
        hapticSoft.prepare()
        hapticMedium.prepare()
        hapticSuccess.prepare()
    }

    // MARK: - Control

    public func start() {
        isRunning = true
        isPaused = false
        isComplete = false
        lastTickTime = CACurrentMediaTime()
        phaseStartTime = 0

        hapticMedium.impactOccurred()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    public func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    public func resume() {
        isPaused = false
        lastTickTime = CACurrentMediaTime()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    public func stop() -> BreathSession {
        timer?.invalidate()
        timer = nil
        isRunning = false

        return BreathSession(
            techniqueId: technique.id,
            startedAt: Date().addingTimeInterval(-totalElapsedTime),
            completedAt: Date(),
            totalDuration: totalElapsedTime,
            cyclesCompleted: cyclesCompleted
        )
    }

    // MARK: - Tick

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = now - lastTickTime
        lastTickTime = now

        totalElapsedTime += dt
        phaseStartTime += dt
        elapsedInCurrentCycle += dt

        let phaseDuration = currentPhase.duration
        phaseProgress = min(phaseStartTime / phaseDuration, 1.0)
        phaseTimeRemaining = max(phaseDuration - phaseStartTime, 0)

        // Check if phase is complete
        if phaseStartTime >= phaseDuration {
            advancePhase()
        }

        // Check if session target reached (finish current cycle)
        if totalElapsedTime >= sessionDurationTarget && currentPhaseIndex == 0 && phaseStartTime < 0.1 {
            completeSession()
        }
    }

    private func advancePhase() {
        let nextIndex = currentPhaseIndex + 1

        if nextIndex >= technique.phases.count {
            // Cycle complete
            cyclesCompleted += 1
            currentPhaseIndex = 0
            elapsedInCurrentCycle = 0

            // Check if we should end after this cycle
            if totalElapsedTime >= sessionDurationTarget {
                completeSession()
                return
            }
        } else {
            currentPhaseIndex = nextIndex
        }

        phaseStartTime = 0
        phaseProgress = 0
        phaseTimeRemaining = currentPhase.duration

        // Haptic on phase transition
        hapticSoft.impactOccurred()
    }

    private func completeSession() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isComplete = true
        hapticSuccess.notificationOccurred(.success)
    }

    // MARK: - Math Helpers

    private func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * t
    }
}
#endif
