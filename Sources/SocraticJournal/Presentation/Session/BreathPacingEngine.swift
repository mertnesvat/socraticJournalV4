// BreathPacingEngine.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UIKit

/// Core engine that drives breath pacing — manages phase timing, circle scale, and session state
@Observable
@MainActor
public final class BreathPacingEngine {
    // MARK: - State

    private(set) var technique: BreathTechnique
    private(set) var currentPhaseIndex: Int = 0
    private(set) var phaseProgress: Double = 0.0
    private(set) var phaseTimeRemaining: TimeInterval = 0.0
    private(set) var cyclesCompleted: Int = 0
    private(set) var totalElapsedTime: TimeInterval = 0.0
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var isComplete: Bool = false
    private(set) var completedSession: BreathSession?

    let sessionDurationTarget: TimeInterval

    var currentPhase: BreathPhase {
        technique.phases[currentPhaseIndex]
    }

    // MARK: - Circle Scale

    private let minScale: Double = 0.4
    private let maxScale: Double = 1.0

    var circleScale: Double {
        let progress = phaseProgress
        switch currentPhase.phaseType {
        case .inhale:
            return lerp(minScale, maxScale, easeInOut(progress))
        case .inhaleTopUp:
            return lerp(0.7, maxScale, easeInOut(progress))
        case .exhale:
            return lerp(maxScale, minScale, easeInOut(progress))
        case .hold:
            let time = totalElapsedTime
            let oscillation = sin(time * 4) * 0.02
            let holdScale = currentPhaseIndex > 0 ? scaleAtPhaseStart() : maxScale
            return holdScale + oscillation
        }
    }

    // MARK: - Timer

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var phaseElapsed: TimeInterval = 0

    // MARK: - Haptics

    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let successNotification = UINotificationFeedbackGenerator()

    // MARK: - Init

    init(technique: BreathTechnique, durationMinutes: Int) {
        self.technique = technique
        self.sessionDurationTarget = TimeInterval(durationMinutes * 60)
        self.phaseTimeRemaining = technique.phases[0].duration
    }

    // MARK: - Control

    func start() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
        isComplete = false
        lastTimestamp = 0
        phaseElapsed = 0
        currentPhaseIndex = 0
        phaseTimeRemaining = currentPhase.duration

        softImpact.prepare()
        mediumImpact.impactOccurred()

        let link = CADisplayLink(target: DisplayLinkTarget { [weak self] in
            self?.tick()
        }, selector: #selector(DisplayLinkTarget.handleDisplayLink))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        displayLink?.isPaused = true
    }

    func resume() {
        guard isRunning, isPaused else { return }
        isPaused = false
        lastTimestamp = 0
        displayLink?.isPaused = false
    }

    @discardableResult
    func stop() -> BreathSession {
        if let existing = completedSession { return existing }

        displayLink?.invalidate()
        displayLink = nil
        isRunning = false

        successNotification.notificationOccurred(.success)

        let session = BreathSession(
            id: UUID().uuidString,
            techniqueId: technique.id,
            startedAt: Date().addingTimeInterval(-totalElapsedTime),
            completedAt: Date(),
            totalDuration: totalElapsedTime,
            cyclesCompleted: cyclesCompleted
        )
        completedSession = session
        isComplete = true
        return session
    }

    // MARK: - Timer Tick

    private func tick() {
        guard let link = displayLink else { return }

        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        let dt = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp

        totalElapsedTime += dt
        phaseElapsed += dt

        let phaseDuration = currentPhase.duration
        phaseProgress = min(phaseElapsed / phaseDuration, 1.0)
        phaseTimeRemaining = max(phaseDuration - phaseElapsed, 0)

        // Phase complete
        if phaseElapsed >= phaseDuration {
            advancePhase()
            if isComplete { return }
        }
    }

    private func advancePhase() {
        let nextIndex = currentPhaseIndex + 1

        if nextIndex >= technique.phases.count {
            // Cycle complete
            cyclesCompleted += 1
            currentPhaseIndex = 0

            // Check if session should end
            if totalElapsedTime >= sessionDurationTarget {
                let _ = stop()
                return
            }
        } else {
            currentPhaseIndex = nextIndex
        }

        phaseElapsed = 0
        phaseProgress = 0
        phaseTimeRemaining = currentPhase.duration

        // Haptic at each phase transition
        softImpact.impactOccurred()
    }

    // MARK: - Helpers

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * t
    }

    private func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    private func scaleAtPhaseStart() -> Double {
        // Determine what scale the circle was at when this phase started
        let prevIndex = currentPhaseIndex > 0 ? currentPhaseIndex - 1 : technique.phases.count - 1
        let prevPhase = technique.phases[prevIndex]
        switch prevPhase.phaseType {
        case .inhale, .inhaleTopUp:
            return maxScale
        case .exhale:
            return minScale
        case .hold:
            return scaleForHoldAfter(prevIndex)
        }
    }

    private func scaleForHoldAfter(_ index: Int) -> Double {
        // Look back further to find a non-hold phase
        let prevPrev = index > 0 ? index - 1 : technique.phases.count - 1
        let pp = technique.phases[prevPrev]
        switch pp.phaseType {
        case .inhale, .inhaleTopUp: return maxScale
        case .exhale: return minScale
        default: return maxScale
        }
    }
}

/// Helper to bridge CADisplayLink callbacks to a closure
private final class DisplayLinkTarget: NSObject {
    let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    @objc func handleDisplayLink() {
        callback()
    }
}
#endif
