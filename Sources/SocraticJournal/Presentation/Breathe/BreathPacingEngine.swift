// BreathPacingEngine.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import QuartzCore

/// Core breath pacing engine that drives phase transitions and progress
@Observable
@MainActor
public final class BreathPacingEngine {
    // MARK: - State

    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var currentPhaseIndex: Int = 0
    private(set) var phaseProgress: Double = 0
    private(set) var countdown: Int = 0
    private(set) var cyclesCompleted: Int = 0
    private(set) var totalElapsed: TimeInterval = 0
    private(set) var sessionFinished: Bool = false

    var currentPhase: BreathPhase? {
        guard let pattern = pattern, currentPhaseIndex < pattern.phases.count else { return nil }
        return pattern.phases[currentPhaseIndex]
    }

    var phaseColor: String {
        guard let phase = currentPhase else { return "2D5F5D" }
        switch phase.phaseType {
        case .inhale, .inhaleTopUp: return "2D5F5D"
        case .hold: return "5A8A6A"
        case .exhale: return "C4502A"
        }
    }

    // MARK: - Configuration

    private(set) var pattern: BreathPattern?
    private(set) var targetDuration: TimeInterval = 300 // 5 minutes default

    // MARK: - Callbacks

    var onPhaseTransition: ((BreathPhaseType) -> Void)?

    // MARK: - Internal

    private var displayLink: CADisplayLink?
    private var phaseStartTime: CFTimeInterval = 0
    private var sessionStartTime: CFTimeInterval = 0
    private var pauseAccumulator: CFTimeInterval = 0
    private var pauseStartTime: CFTimeInterval = 0

    // MARK: - Actions

    func start(pattern: BreathPattern, duration: TimeInterval) {
        self.pattern = pattern
        self.targetDuration = duration
        self.currentPhaseIndex = 0
        self.phaseProgress = 0
        self.cyclesCompleted = 0
        self.totalElapsed = 0
        self.sessionFinished = false
        self.pauseAccumulator = 0
        self.isPaused = false
        self.isRunning = true

        let now = CACurrentMediaTime()
        self.sessionStartTime = now
        self.phaseStartTime = now

        if let phase = currentPhase {
            self.countdown = Int(ceil(phase.duration))
        }

        startDisplayLink()
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        pauseStartTime = CACurrentMediaTime()
        stopDisplayLink()
    }

    func resume() {
        guard isRunning, isPaused else { return }
        let pauseDuration = CACurrentMediaTime() - pauseStartTime
        pauseAccumulator += pauseDuration
        isPaused = false
        startDisplayLink()
    }

    func stop() {
        isRunning = false
        isPaused = false
        stopDisplayLink()
        phaseProgress = 0
        currentPhaseIndex = 0
        countdown = 0
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        stopDisplayLink()
        let link = CADisplayLink(target: DisplayLinkTarget { [weak self] in
            self?.tick()
        }, selector: #selector(DisplayLinkTarget.handleTick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func tick() {
        guard isRunning, !isPaused, let pattern = pattern else { return }
        let now = CACurrentMediaTime()
        let adjustedNow = now - pauseAccumulator

        // Update total session elapsed
        totalElapsed = adjustedNow - sessionStartTime

        // Check if session duration exceeded
        if totalElapsed >= targetDuration {
            sessionFinished = true
            stop()
            return
        }

        // Phase progress
        let phaseElapsed = adjustedNow - phaseStartTime
        let phase = pattern.phases[currentPhaseIndex]
        let progress = min(phaseElapsed / phase.duration, 1.0)
        phaseProgress = progress
        countdown = max(0, Int(ceil(phase.duration - phaseElapsed)))

        // Advance to next phase
        if phaseElapsed >= phase.duration {
            let nextIndex = currentPhaseIndex + 1
            if nextIndex >= pattern.phases.count {
                cyclesCompleted += 1
                currentPhaseIndex = 0
            } else {
                currentPhaseIndex = nextIndex
            }
            phaseStartTime = adjustedNow
            phaseProgress = 0
            if let newPhase = currentPhase {
                countdown = Int(ceil(newPhase.duration))
                onPhaseTransition?(newPhase.phaseType)
            }
        }
    }

}

// MARK: - DisplayLink Target (avoid retain cycle)

private final class DisplayLinkTarget: NSObject {
    let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    @objc func handleTick() {
        callback()
    }
}
#endif
