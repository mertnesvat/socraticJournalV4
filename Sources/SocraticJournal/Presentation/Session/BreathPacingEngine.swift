// BreathPacingEngine.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UIKit

/// Core pacing engine that drives the breath animation, phase transitions,
/// and haptic feedback. Uses CADisplayLink for frame-accurate timing.
@Observable
@MainActor
public final class BreathPacingEngine {

    // MARK: - State

    /// The active breathing technique
    public private(set) var technique: BreathTechnique = .resonance

    /// Current phase within the technique
    public private(set) var currentPhase: BreathPhase = BreathTechnique.resonance.phases[0]

    /// Index of the current phase in technique.phases
    public private(set) var currentPhaseIndex: Int = 0

    /// Progress through the current phase (0.0 to 1.0)
    public private(set) var phaseProgress: Double = 0.0

    /// Seconds remaining in the current phase
    public private(set) var phaseTimeRemaining: TimeInterval = 0.0

    /// Progress through the entire session (0.0 to 1.0)
    public private(set) var sessionProgress: Double = 0.0

    /// Total elapsed time since session start (excluding paused time)
    public private(set) var elapsedTime: TimeInterval = 0.0

    /// Number of full breathing cycles completed
    public private(set) var cyclesCompleted: Int = 0

    /// Whether the session is actively running (true from start until complete/stopped)
    public private(set) var isActive: Bool = false

    /// Whether the session is paused
    public private(set) var isPaused: Bool = false

    /// Whether the session has naturally completed
    public private(set) var isComplete: Bool = false

    /// Total session length the user selected
    public private(set) var targetDuration: TimeInterval = 300

    // MARK: - Breath Position

    /// Vertical position for the mountain wave animation (0.0 to 1.0).
    /// - `.inhale`: rises 0→1 with ease-in-out
    /// - `.holdAfterInhale`: stays at 1.0
    /// - `.exhale`: falls 1→0 with ease-in-out
    /// - `.holdAfterExhale`: stays at 0.0
    public var breathPosition: Double {
        switch currentPhase.phaseType {
        case .inhale:
            return easeInOut(phaseProgress)
        case .holdAfterInhale:
            return 1.0
        case .exhale:
            return 1.0 - easeInOut(phaseProgress)
        case .holdAfterExhale:
            return 0.0
        }
    }

    // MARK: - Private State

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var phaseElapsed: TimeInterval = 0
    private var sessionStartedAt: Date?
    private var shouldEndAfterCycle: Bool = false

    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)

    // MARK: - Init

    public init() {
        lightHaptic.prepare()
        mediumHaptic.prepare()
    }

    // MARK: - Public Methods

    /// Start a new breathing session with the given technique and duration.
    /// Set `useDisplayLink` to false for unit testing (drive with `advance(by:)` instead).
    public func startSession(technique: BreathTechnique, duration: TimeInterval, useDisplayLink: Bool = true) {
        // Clean up any existing session
        displayLink?.invalidate()
        displayLink = nil

        self.technique = technique
        self.targetDuration = duration
        self.currentPhaseIndex = 0
        self.currentPhase = technique.phases[0]
        self.phaseProgress = 0.0
        self.phaseElapsed = 0.0
        self.phaseTimeRemaining = currentPhase.duration
        self.sessionProgress = 0.0
        self.elapsedTime = 0.0
        self.cyclesCompleted = 0
        self.isActive = true
        self.isPaused = false
        self.isComplete = false
        self.shouldEndAfterCycle = false
        self.sessionStartedAt = Date()
        self.lastTimestamp = 0

        guard useDisplayLink else { return }

        let link = CADisplayLink(target: DisplayLinkTarget(engine: self), selector: #selector(DisplayLinkTarget.tick(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        link.add(to: .main, forMode: .common)
        self.displayLink = link
    }

    /// Pause the session, freezing all progress.
    public func pause() {
        guard isActive, !isPaused, !isComplete else { return }
        isPaused = true
        displayLink?.isPaused = true
    }

    /// Resume from pause, continuing from the exact pause point.
    public func resume() {
        guard isActive, isPaused, !isComplete else { return }
        isPaused = false
        lastTimestamp = 0 // Reset so next tick calculates fresh delta
        displayLink?.isPaused = false
    }

    /// Stop the session and return a BreathSession record.
    @discardableResult
    public func stop() -> BreathSession {
        let session = BreathSession(
            techniqueId: technique.id,
            techniqueName: technique.name,
            startedAt: sessionStartedAt ?? Date(),
            completedAt: isComplete ? Date() : nil,
            targetDuration: targetDuration,
            cyclesCompleted: cyclesCompleted
        )

        displayLink?.invalidate()
        displayLink = nil
        isActive = false
        isPaused = false

        return session
    }

    // MARK: - Frame Update

    /// Advance the engine by a given time delta. Exposed for unit testing
    /// without a running RunLoop — drive the engine by calling this repeatedly.
    public func advance(by delta: TimeInterval) {
        guard isActive, !isPaused, !isComplete else { return }

        elapsedTime += delta

        if elapsedTime >= targetDuration {
            shouldEndAfterCycle = true
        }

        sessionProgress = min(elapsedTime / targetDuration, 1.0)

        phaseElapsed += delta

        // Process potentially multiple phase transitions in a single advance
        while phaseElapsed >= currentPhase.duration {
            if isComplete { return }
            advancePhase()
        }

        phaseProgress = phaseElapsed / currentPhase.duration
        phaseTimeRemaining = currentPhase.duration - phaseElapsed
    }

    fileprivate func handleTick(_ link: CADisplayLink) {
        guard isActive, !isPaused, !isComplete else { return }

        let delta: TimeInterval
        if lastTimestamp == 0 {
            delta = link.targetTimestamp - link.timestamp
        } else {
            delta = link.timestamp - lastTimestamp
        }
        lastTimestamp = link.timestamp

        // Clamp to prevent jumps from backgrounding
        advance(by: min(delta, 0.1))
    }

    // MARK: - Phase Advancement

    private func advancePhase() {
        // Subtract the completed phase's duration from phaseElapsed
        phaseElapsed -= currentPhase.duration

        let nextIndex = currentPhaseIndex + 1

        if nextIndex >= technique.phases.count {
            // Completed a full cycle
            cyclesCompleted += 1

            if shouldEndAfterCycle {
                // Session complete — finish at natural cycle boundary
                phaseProgress = 1.0
                phaseTimeRemaining = 0
                phaseElapsed = 0
                isComplete = true
                isActive = false
                displayLink?.invalidate()
                displayLink = nil
                mediumHaptic.impactOccurred()
                return
            }

            // Start next cycle from phase 0
            currentPhaseIndex = 0
        } else {
            currentPhaseIndex = nextIndex
        }

        currentPhase = technique.phases[currentPhaseIndex]

        // Fire haptic on phase transition
        lightHaptic.impactOccurred()
        lightHaptic.prepare()
    }

    // MARK: - Easing

    /// Smooth ease-in-out curve for natural breath animation
    private func easeInOut(_ t: Double) -> Double {
        // Sinusoidal ease-in-out: smooth and natural for breathing
        return (1.0 - cos(t * .pi)) / 2.0
    }
}

// MARK: - CADisplayLink Target

/// A reference-type target to avoid retain cycles with CADisplayLink.
/// CADisplayLink retains its target, so we use a weak reference back to the engine.
/// The tick fires on the main thread (RunLoop .common), matching @MainActor isolation.
@MainActor
private final class DisplayLinkTarget: NSObject {
    weak var engine: BreathPacingEngine?

    init(engine: BreathPacingEngine) {
        self.engine = engine
    }

    @objc func tick(_ link: CADisplayLink) {
        engine?.handleTick(link)
    }
}
#endif
