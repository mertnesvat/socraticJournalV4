// TrainingViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UIKit

/// State machine for step-by-step training exercise flow
@Observable
@MainActor
public final class TrainingViewModel {
    // MARK: - State

    let exercise: TrainingData.Exercise
    private(set) var currentStepIndex: Int = 0
    private(set) var timerValue: TimeInterval = 0
    private(set) var isTimerRunning: Bool = false
    private(set) var tapCount: Int = 0
    private(set) var responses: [Int: String] = [:] // stepId -> response
    private(set) var holdTimes: [TimeInterval] = [] // for CO₂ builder
    private(set) var ratingValue: Int = 0
    private(set) var isComplete: Bool = false

    var currentStep: TrainingData.Step? {
        guard currentStepIndex < exercise.steps.count else { return nil }
        return exercise.steps[currentStepIndex]
    }

    var totalSteps: Int { exercise.steps.count }

    // MARK: - Timer

    private var timerTask: Task<Void, Never>?

    // MARK: - Init

    init(exercise: TrainingData.Exercise) {
        self.exercise = exercise
    }

    // MARK: - Actions

    func advance() {
        stopTimer()
        if currentStepIndex + 1 < exercise.steps.count {
            currentStepIndex += 1
            timerValue = 0
            tapCount = 0
            handleStepEntry()
        }
    }

    func startAutoAdvance(seconds: TimeInterval) {
        timerTask = Task {
            try? await Task.sleep(for: .seconds(seconds))
            if !Task.isCancelled {
                advance()
            }
        }
    }

    func startCountdown(seconds: TimeInterval) {
        timerValue = seconds
        isTimerRunning = true
        timerTask = Task {
            while timerValue > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                if !Task.isCancelled {
                    timerValue = max(0, timerValue - 0.1)
                }
            }
            if !Task.isCancelled {
                isTimerRunning = false
                fireHaptic()
                advance()
            }
        }
    }

    func startCountUp(maxSeconds: TimeInterval) {
        timerValue = 0
        isTimerRunning = true
        timerTask = Task {
            while timerValue < maxSeconds && !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                if !Task.isCancelled {
                    timerValue += 0.1
                }
            }
            if !Task.isCancelled {
                isTimerRunning = false
                fireHaptic()
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        isTimerRunning = false
    }

    func tapStop() {
        stopTimer()
        holdTimes.append(timerValue)
        fireHaptic()
        // Brief display, then advance
        Task {
            try? await Task.sleep(for: .seconds(2))
            advance()
        }
    }

    func tapBreathCount() {
        tapCount += 1
        fireHaptic()
    }

    func selectResponse(_ response: String, forStep stepId: Int) {
        responses[stepId] = response
        advance()
    }

    func selectRating(_ value: Int) {
        ratingValue = value
    }

    func submitRating() {
        advance()
    }

    func panicStop() {
        stopTimer()
        // Pre-select "Very difficult" and advance
        if let step = currentStep {
            responses[step.id] = "Very difficult"
        }
        advance()
    }

    func startCountdownForTapCounter(seconds: TimeInterval) {
        timerValue = seconds
        isTimerRunning = true
        tapCount = 0
        timerTask = Task {
            while timerValue > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                if !Task.isCancelled {
                    timerValue = max(0, timerValue - 0.1)
                }
            }
            if !Task.isCancelled {
                isTimerRunning = false
                fireHaptic()
                advance()
            }
        }
    }

    func markComplete() {
        isComplete = true
        TrainingData.incrementCompletion(for: exercise.id)
    }

    // MARK: - Step Entry

    func handleStepEntry() {
        guard let step = currentStep else { return }
        switch step.type {
        case .instruction(_, let autoAdvance):
            if let seconds = autoAdvance {
                startAutoAdvance(seconds: seconds)
            }
        case .timerCountdown(_, let seconds, _):
            startCountdown(seconds: seconds)
        case .timerCountUp(_, let maxSeconds, _):
            startCountUp(maxSeconds: maxSeconds)
        case .tapCounter(_, let seconds):
            startCountdownForTapCounter(seconds: seconds)
        case .result:
            markComplete()
        default:
            break
        }
    }

    // MARK: - Result Helpers

    /// Breath awareness BPM (taps x2 for 30-second window)
    var breathBPM: Int { tapCount * 2 }

    /// CO₂ builder average hold time
    var averageHoldTime: TimeInterval {
        guard !holdTimes.isEmpty else { return 0 }
        return holdTimes.reduce(0, +) / Double(holdTimes.count)
    }

    /// CO₂ builder trend
    var co2Trend: String {
        guard holdTimes.count >= 2 else { return "" }
        let diff = holdTimes.last! - holdTimes.first!
        if diff > 3 { return "Your holds got longer \u{2014} CO\u{2082} tolerance improves even within a single exercise." }
        if diff < -3 { return "Shorter toward the end \u{2014} this is common. Try slower, gentler breathing between rounds next time." }
        return "Consistent holds \u{2014} your tolerance is stable. Regular practice will extend these over weeks."
    }

    var co2TrendColorHex: String {
        guard holdTimes.count >= 2 else { return "7A6E60" }
        let diff = holdTimes.last! - holdTimes.first!
        if diff > 3 { return "2D5F5D" }
        if diff < -3 { return "7A6030" }
        return "7A6E60"
    }

    // MARK: - Haptics

    private func fireHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
#endif
