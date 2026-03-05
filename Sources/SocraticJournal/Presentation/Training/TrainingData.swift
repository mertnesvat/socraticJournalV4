// TrainingData.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Defines the 4 training exercises and their step structures
enum TrainingData {

    // MARK: - Types

    enum StepType {
        case instruction(text: String, autoAdvanceSeconds: TimeInterval?)
        case timerCountdown(text: String, seconds: TimeInterval, showPanicButton: Bool)
        case timerCountUp(text: String, maxSeconds: TimeInterval, tapToStop: Bool)
        case tapResponse(question: String, options: [String])
        case tapCounter(text: String, seconds: TimeInterval)
        case ratingScale(question: String, count: Int, lowLabel: String, highLabel: String)
        case result
    }

    struct Step: Identifiable {
        let id: Int
        let type: StepType
    }

    struct Exercise: Identifiable {
        let id: String
        let name: String
        let icon: String
        let duration: String
        let description: String
        let steps: [Step]
    }

    // MARK: - All Exercises

    static let allExercises: [Exercise] = [noseUnblocking, breathAwareness, mouthTapeReadiness, co2Builder]

    // MARK: - Exercise 1: Nose Unblocking

    static let noseUnblocking = Exercise(
        id: "nose_unblocking",
        name: "Nose Unblocking",
        icon: "wind",
        duration: "2 min",
        description: "A Buteyko technique to clear nasal congestion without medication. Works by deliberately increasing CO\u{2082} levels to trigger vasodilation in the nasal passages.",
        steps: [
            Step(id: 0, type: .instruction(text: "Take a small, gentle breath in through your nose", autoAdvanceSeconds: 3)),
            Step(id: 1, type: .instruction(text: "Let a small, gentle breath out through your nose", autoAdvanceSeconds: 3)),
            Step(id: 2, type: .instruction(text: "Pinch your nose closed with your fingers", autoAdvanceSeconds: 1)),
            Step(id: 3, type: .timerCountUp(text: "Walk around the room, holding your breath, nodding your head up and down", maxSeconds: 30, tapToStop: true)),
            Step(id: 4, type: .instruction(text: "Release your nose and breathe gently through it", autoAdvanceSeconds: 5)),
            Step(id: 5, type: .timerCountdown(text: "Breathe very gently for 30 seconds \u{2014} smaller breaths than normal", seconds: 30, showPanicButton: false)),
            Step(id: 6, type: .ratingScale(question: "How clear does your nose feel?", count: 5, lowLabel: "Still blocked", highLabel: "Completely clear")),
            Step(id: 7, type: .result),
        ]
    )

    // MARK: - Exercise 2: Breath Awareness Check

    static let breathAwareness = Exercise(
        id: "breath_awareness",
        name: "Breath Awareness",
        icon: "person.fill",
        duration: "1 min",
        description: "A quick self-assessment of your current breathing pattern. Are you breathing through your nose? Is your tongue right? Are you using your diaphragm?",
        steps: [
            Step(id: 0, type: .tapResponse(question: "Close your mouth. Is your tongue resting on the roof of your mouth, just behind your front teeth?", options: ["Yes", "No"])),
            Step(id: 1, type: .tapResponse(question: "Place one hand on your chest and one on your belly. Take a normal breath. Which hand moves more?", options: ["Chest", "Belly"])),
            Step(id: 2, type: .tapCounter(text: "Without changing anything, count your breaths for 30 seconds. Tap the circle each time you complete a breath.", seconds: 30)),
            Step(id: 3, type: .result),
        ]
    )

    // MARK: - Exercise 3: Mouth Tape Readiness

    static let mouthTapeReadiness = Exercise(
        id: "mouth_tape",
        name: "Mouth Tape Readiness",
        icon: "xmark.circle",
        duration: "3 min",
        description: "A guided introduction to mouth taping for sleep. James Nestor and Patrick McKeown both recommend this \u{2014} this exercise tests your nasal breathing comfort.",
        steps: [
            Step(id: 0, type: .instruction(text: "Sit comfortably and close your mouth", autoAdvanceSeconds: 3)),
            Step(id: 1, type: .timerCountdown(text: "Breathe only through your nose for 60 seconds. Notice: can you breathe comfortably the entire time?", seconds: 60, showPanicButton: true)),
            Step(id: 2, type: .tapResponse(question: "How was that?", options: ["Easy", "Some difficulty", "Very difficult"])),
            Step(id: 3, type: .result),
        ]
    )

    // MARK: - Exercise 4: CO₂ Tolerance Builder

    static let co2Builder = Exercise(
        id: "co2_builder",
        name: "CO\u{2082} Tolerance",
        icon: "lungs",
        duration: "5 min",
        description: "A progressive hold exercise that gently extends your CO\u{2082} tolerance over 5 rounds. Based on Buteyko\u{2019}s reduced breathing principles.",
        steps: co2BuilderSteps()
    )

    private static func co2BuilderSteps() -> [Step] {
        var steps: [Step] = []
        var stepId = 0
        for round in 1...5 {
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Breathe normally through your nose \u{2014} Round \(round) of 5",
                seconds: 15, showPanicButton: false)))
            stepId += 1

            steps.append(Step(id: stepId, type: .instruction(
                text: "Take a normal breath in... and out",
                autoAdvanceSeconds: 4)))
            stepId += 1

            steps.append(Step(id: stepId, type: .timerCountUp(
                text: "Hold after the exhale \u{2014} tap when you feel the first urge to breathe",
                maxSeconds: 60, tapToStop: true)))
            stepId += 1
        }
        steps.append(Step(id: stepId, type: .result))
        return steps
    }

    // MARK: - Persistence

    static let completionKey = "com.breathe.training"

    static func completionCount(for exerciseId: String, defaults: UserDefaults = .standard) -> Int {
        guard let data = defaults.data(forKey: completionKey),
              let counts = try? JSONDecoder().decode([String: Int].self, from: data) else { return 0 }
        return counts[exerciseId] ?? 0
    }

    static func incrementCompletion(for exerciseId: String, defaults: UserDefaults = .standard) {
        var counts: [String: Int] = [:]
        if let data = defaults.data(forKey: completionKey),
           let existing = try? JSONDecoder().decode([String: Int].self, from: data) {
            counts = existing
        }
        counts[exerciseId, default: 0] += 1
        if let data = try? JSONEncoder().encode(counts) {
            defaults.set(data, forKey: completionKey)
        }
    }
}
