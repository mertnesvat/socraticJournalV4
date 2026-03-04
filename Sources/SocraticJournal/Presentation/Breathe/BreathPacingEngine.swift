// BreathPacingEngine.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UIKit

@Observable
@MainActor
final class BreathPacingEngine {
    var pattern: BreathPattern
    var currentPhaseIndex: Int = 0
    var phaseProgress: Double = 0
    var phaseTimeRemaining: TimeInterval = 0
    var isRunning: Bool = false
    var totalElapsedTime: TimeInterval = 0
    var sessionDurationTarget: TimeInterval = 300 // 5 min default
    var cyclesCompleted: Int = 0
    var hapticEnabled: Bool = true

    var currentPhase: BreathPhase {
        pattern.phases[currentPhaseIndex]
    }

    private var displayLink: CADisplayLink?
    private var phaseStartTime: CFTimeInterval = 0
    private var sessionStartDate: Date?

    init(pattern: BreathPattern = .resonance) {
        self.pattern = pattern
        self.phaseTimeRemaining = pattern.phases.first?.duration ?? 0
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        currentPhaseIndex = 0
        phaseProgress = 0
        totalElapsedTime = 0
        cyclesCompleted = 0
        sessionStartDate = Date()
        phaseTimeRemaining = currentPhase.duration

        startDisplayLink()
        fireHaptic(.medium)
    }

    func pause() {
        isRunning = false
        stopDisplayLink()
    }

    func resume() {
        guard !isRunning else { return }
        isRunning = true
        startDisplayLink()
    }

    func stop() -> BreathSession? {
        isRunning = false
        stopDisplayLink()

        guard let startDate = sessionStartDate, totalElapsedTime > 0 else { return nil }
        let session = BreathSession(
            patternId: pattern.id,
            startedAt: startDate,
            completedAt: Date(),
            totalDuration: totalElapsedTime,
            cyclesCompleted: cyclesCompleted
        )
        reset()
        return session
    }

    func reset() {
        isRunning = false
        stopDisplayLink()
        currentPhaseIndex = 0
        phaseProgress = 0
        totalElapsedTime = 0
        cyclesCompleted = 0
        sessionStartDate = nil
        phaseTimeRemaining = pattern.phases.first?.duration ?? 0
    }

    func selectPattern(_ newPattern: BreathPattern) {
        reset()
        pattern = newPattern
        phaseTimeRemaining = newPattern.phases.first?.duration ?? 0
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        stopDisplayLink()
        phaseStartTime = CACurrentMediaTime()
        let link = CADisplayLink(target: DisplayLinkTarget { [weak self] in
            self?.tick()
        }, selector: #selector(DisplayLinkTarget.update))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func tick() {
        guard isRunning else { return }

        let now = CACurrentMediaTime()
        let elapsed = now - phaseStartTime
        let duration = currentPhase.duration

        phaseProgress = min(elapsed / duration, 1.0)
        phaseTimeRemaining = max(0, duration - elapsed)
        totalElapsedTime += displayLink?.duration ?? (1.0 / 60.0)

        if elapsed >= duration {
            advancePhase()
        }

        // Check session completion
        if totalElapsedTime >= sessionDurationTarget && currentPhaseIndex == 0 && phaseProgress < 0.1 {
            let _ = stop()
        }
    }

    private func advancePhase() {
        let nextIndex = currentPhaseIndex + 1
        if nextIndex >= pattern.phases.count {
            currentPhaseIndex = 0
            cyclesCompleted += 1
        } else {
            currentPhaseIndex = nextIndex
        }
        phaseProgress = 0
        phaseStartTime = CACurrentMediaTime()
        phaseTimeRemaining = currentPhase.duration

        if hapticEnabled {
            fireHaptic(.soft)
        }
    }

    private func fireHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// Helper class to work with CADisplayLink without @objc on the engine
private class DisplayLinkTarget {
    let callback: () -> Void
    init(callback: @escaping () -> Void) { self.callback = callback }
    @objc func update() { callback() }
}
#endif
