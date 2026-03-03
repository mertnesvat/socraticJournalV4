// BreatheViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI
import UIKit

/// Screen state for the Breathe tab
public enum BreatheScreenState: Equatable {
    case selection     // Pattern and duration picker
    case countdown     // 3-2-1 countdown before session
    case active        // Session in progress
    case summary       // Post-session summary (Feature 4)
}

/// ViewModel for the Breathe screen
@Observable
@MainActor
public final class BreatheViewModel {
    // MARK: - Public State

    /// Current screen state
    public private(set) var screenState: BreatheScreenState = .selection

    /// The session engine
    public let engine = BreathSessionEngine()

    /// Selected pattern
    public var selectedPattern: BreathPattern = .default

    /// Selected duration
    public var selectedDuration: SessionDuration = .default

    /// Countdown value (3, 2, 1, 0)
    public private(set) var countdownValue: Int = 3

    /// Whether the session is paused
    public var isPaused: Bool {
        engine.state == .paused
    }

    /// Whether to show end-session confirmation
    public var showEndConfirmation: Bool = false

    // MARK: - Haptics

    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

    /// Track the last phase to detect transitions for haptics
    private var lastPhase: SessionPhase?

    // MARK: - Actions

    /// Start the countdown leading into a session
    public func beginSession() {
        engine.configure(pattern: selectedPattern, durationSeconds: selectedDuration.seconds)
        countdownValue = 3
        screenState = .countdown
        softImpact.prepare()
        mediumImpact.prepare()
        runCountdown()
    }

    /// Toggle pause/resume during active session
    public func togglePause() {
        engine.togglePause()
    }

    /// Request to end session early (shows confirmation)
    public func requestEndSession() {
        showEndConfirmation = true
    }

    /// Confirm ending session early
    public func confirmEndSession() {
        showEndConfirmation = false
        engine.endEarly()
        screenState = .summary
    }

    /// Return to pattern selection
    public func returnToSelection() {
        engine.reset()
        screenState = .selection
        lastPhase = nil
    }

    /// Check for phase change and fire haptic
    public func checkPhaseHaptic() {
        let current = engine.currentPhase
        if let last = lastPhase, last != current {
            softImpact.impactOccurred()
        }
        lastPhase = current

        // Check if session completed
        if engine.state == .completed && screenState == .active {
            mediumImpact.impactOccurred()
            screenState = .summary
        }
    }

    // MARK: - Private

    private func runCountdown() {
        Task {
            for value in stride(from: 3, through: 1, by: -1) {
                countdownValue = value
                softImpact.impactOccurred()
                try? await Task.sleep(for: .seconds(1))
            }
            countdownValue = 0
            // Start the actual session
            engine.start()
            lastPhase = engine.currentPhase
            screenState = .active
        }
    }
}
#endif
