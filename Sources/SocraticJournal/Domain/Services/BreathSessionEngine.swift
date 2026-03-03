// BreathSessionEngine.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// State of the session engine
public enum SessionState: Sendable, Equatable {
    case idle
    case active
    case paused
    case completed
}

/// The core breath session engine managing phase transitions, timing, and breath counting
@Observable
@MainActor
public final class BreathSessionEngine {
    // MARK: - Public State

    /// Current engine state
    public private(set) var state: SessionState = .idle

    /// The breath pattern being used
    public private(set) var pattern: BreathPattern = .default

    /// Target session duration in seconds
    public private(set) var targetDuration: TimeInterval = 300 // 5 minutes

    /// Current phase of the breath cycle
    public private(set) var currentPhase: SessionPhase = .inhale

    /// Progress within the current phase (0.0 to 1.0)
    public private(set) var phaseProgress: Double = 0.0

    /// Time remaining in current phase (seconds)
    public private(set) var phaseTimeRemaining: TimeInterval = 0.0

    /// Total breaths completed in this session
    public private(set) var breathsCompleted: Int = 0

    /// Total elapsed time in the session (seconds)
    public private(set) var totalElapsed: TimeInterval = 0.0

    /// Overall session progress (0.0 to 1.0)
    public var sessionProgress: Double {
        guard targetDuration > 0 else { return 0 }
        return min(totalElapsed / targetDuration, 1.0)
    }

    /// Time remaining in the session
    public var sessionTimeRemaining: TimeInterval {
        max(targetDuration - totalElapsed, 0)
    }

    /// The completed session record (available after state == .completed)
    public private(set) var completedSession: BreathSession?

    // MARK: - Private State

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var phaseElapsed: TimeInterval = 0
    private var currentPhaseIndex: Int = 0
    private var sessionStartTime: Date?
    private var isFinishingBreath: Bool = false

    // MARK: - Configuration

    /// Configure the engine with a pattern and duration before starting
    public func configure(pattern: BreathPattern, durationSeconds: TimeInterval) {
        guard state == .idle || state == .completed else { return }
        self.pattern = pattern
        self.targetDuration = durationSeconds
        reset()
    }

    // MARK: - Control

    /// Start the session
    public func start() {
        guard state == .idle else { return }
        sessionStartTime = Date()
        state = .active
        currentPhaseIndex = 0
        let phases = pattern.phases
        if let firstPhase = phases.first {
            currentPhase = firstPhase.phase
            phaseTimeRemaining = firstPhase.duration
        }
        startDisplayLink()
    }

    /// Pause the session
    public func pause() {
        guard state == .active else { return }
        state = .paused
        stopDisplayLink()
    }

    /// Resume after pause
    public func resume() {
        guard state == .paused else { return }
        state = .active
        startDisplayLink()
    }

    /// Toggle pause/resume
    public func togglePause() {
        if state == .active {
            pause()
        } else if state == .paused {
            resume()
        }
    }

    /// End the session early
    public func endEarly() {
        completeSession()
    }

    /// Reset the engine to idle state
    public func reset() {
        stopDisplayLink()
        state = .idle
        currentPhase = .inhale
        phaseProgress = 0.0
        phaseTimeRemaining = 0.0
        breathsCompleted = 0
        totalElapsed = 0.0
        phaseElapsed = 0.0
        currentPhaseIndex = 0
        isFinishingBreath = false
        completedSession = nil
        sessionStartTime = nil
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        stopDisplayLink()
        lastTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        guard state == .active else { return }

        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        let dt = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp

        update(deltaTime: dt)
    }

    // MARK: - Core Update Loop

    private func update(deltaTime dt: TimeInterval) {
        totalElapsed += dt
        phaseElapsed += dt

        let phases = pattern.phases
        guard !phases.isEmpty else { return }

        let currentPhaseDuration = phases[currentPhaseIndex].duration

        // Update phase progress
        if currentPhaseDuration > 0 {
            phaseProgress = min(phaseElapsed / currentPhaseDuration, 1.0)
            phaseTimeRemaining = max(currentPhaseDuration - phaseElapsed, 0)
        }

        // Check for phase transition
        if phaseElapsed >= currentPhaseDuration {
            let overflow = phaseElapsed - currentPhaseDuration
            advancePhase()
            phaseElapsed = overflow
        }

        // Check for session completion
        if totalElapsed >= targetDuration && !isFinishingBreath {
            // Mark that we need to finish the current breath cycle
            isFinishingBreath = true
        }

        // If finishing breath and we've returned to the start of a new cycle
        if isFinishingBreath && currentPhaseIndex == 0 && phaseElapsed < 0.1 {
            completeSession()
        }
    }

    private func advancePhase() {
        let phases = pattern.phases
        let nextIndex = currentPhaseIndex + 1

        if nextIndex >= phases.count {
            // Completed one full breath cycle
            currentPhaseIndex = 0
            breathsCompleted += 1

            // If we were finishing the breath, session ends now
            if isFinishingBreath {
                completeSession()
                return
            }
        } else {
            currentPhaseIndex = nextIndex
        }

        currentPhase = phases[currentPhaseIndex].phase
        phaseTimeRemaining = phases[currentPhaseIndex].duration
        phaseProgress = 0.0
    }

    // MARK: - Session Completion

    private func completeSession() {
        guard state != .completed else { return }
        stopDisplayLink()
        state = .completed

        let endTime = Date()
        completedSession = BreathSession(
            patternId: pattern.id,
            patternName: pattern.name,
            startTime: sessionStartTime ?? endTime.addingTimeInterval(-totalElapsed),
            endTime: endTime,
            totalDurationSeconds: totalElapsed,
            breathsCompleted: breathsCompleted
        )
    }

    nonisolated func cleanup() {
        // Called externally before deallocation if needed
    }
}
#endif
