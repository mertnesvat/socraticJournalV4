// TrainingData.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Defines the 8 training exercises and their step structures
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

    struct Section: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let exercises: [Exercise]
    }

    // MARK: - Sections

    static let allSections: [Section] = [
        Section(
            id: "basics",
            title: "Basics",
            subtitle: "Foundation exercises for better breathing",
            exercises: [noseUnblocking, breathAwareness, mouthTapeReadiness, co2Builder]
        ),
        Section(
            id: "co2_tolerance",
            title: "CO\u{2082} Tolerance",
            subtitle: "Freediver-inspired protocols for chemoreceptor training",
            exercises: [altitudeHold, co2Table, breathHoldWalk, apneaPyramid]
        ),
    ]

    // MARK: - All Exercises

    static var allExercises: [Exercise] {
        allSections.flatMap(\.exercises)
    }

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

    // MARK: - Exercise 5: High Altitude Breath Hold

    static let altitudeHold = Exercise(
        id: "altitude_hold",
        name: "High Altitude Hold",
        icon: "mountain.2",
        duration: "6 min",
        description: "Simulates the hypoxic-hypercapnic conditions of high altitude (4,000\u{2013}5,000m). A 4-second nasal inhale, 2-second hold, slow exhale, then hold after exhale for as long as comfortable. Five rounds with recovery breathing between each. Trains both CO\u{2082} and O\u{2082} tolerance simultaneously.",
        steps: altitudeHoldSteps()
    )

    private static func altitudeHoldSteps() -> [Step] {
        var steps: [Step] = []
        var stepId = 0
        steps.append(Step(id: stepId, type: .instruction(
            text: "This exercise simulates high-altitude breathing. You\u{2019}ll do 5 rounds of: inhale, brief hold, exhale, then hold after exhale as long as comfortable.",
            autoAdvanceSeconds: 6)))
        stepId += 1
        for round in 1...5 {
            steps.append(Step(id: stepId, type: .instruction(
                text: "Round \(round) of 5 \u{2014} Breathe in through your nose",
                autoAdvanceSeconds: 4)))
            stepId += 1
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Hold",
                seconds: 2, showPanicButton: false)))
            stepId += 1
            steps.append(Step(id: stepId, type: .instruction(
                text: "Slow exhale through your nose",
                autoAdvanceSeconds: 4)))
            stepId += 1
            steps.append(Step(id: stepId, type: .timerCountUp(
                text: "Hold after exhale \u{2014} tap when you need to breathe",
                maxSeconds: 90, tapToStop: true)))
            stepId += 1
            if round < 5 {
                steps.append(Step(id: stepId, type: .timerCountdown(
                    text: "Recovery breathing \u{2014} gentle nasal breaths",
                    seconds: 15, showPanicButton: false)))
                stepId += 1
            }
        }
        steps.append(Step(id: stepId, type: .result))
        return steps
    }

    // MARK: - Exercise 6: CO₂ Table

    static let co2Table = Exercise(
        id: "co2_table",
        name: "CO\u{2082} Table",
        icon: "chart.bar.xaxis.ascending",
        duration: "7 min",
        description: "A classic freediver CO\u{2082} desensitisation protocol. Eight rounds of a fixed 20-second breath hold with rest periods that shrink from 40 seconds down to 5. The decreasing rest means CO\u{2082} accumulates across the session, progressively challenging your chemoreceptors.",
        steps: co2TableSteps()
    )

    private static func co2TableSteps() -> [Step] {
        let restPeriods: [TimeInterval] = [40, 35, 30, 25, 20, 15, 10, 5]
        var steps: [Step] = []
        var stepId = 0
        steps.append(Step(id: stepId, type: .instruction(
            text: "Stop immediately if you feel dizzy, see spots, or feel tingling in your extremities. Never practise breath holds in water.",
            autoAdvanceSeconds: 6)))
        stepId += 1
        for round in 0..<8 {
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Recovery breathing \u{2014} Round \(round + 1) of 8 (\(Int(restPeriods[round]))s rest)",
                seconds: restPeriods[round], showPanicButton: false)))
            stepId += 1
            steps.append(Step(id: stepId, type: .instruction(
                text: "Take a normal breath in\u{2026} and out",
                autoAdvanceSeconds: 4)))
            stepId += 1
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Hold \u{2014} Round \(round + 1) of 8",
                seconds: 20, showPanicButton: true)))
            stepId += 1
        }
        steps.append(Step(id: stepId, type: .ratingScale(
            question: "How did the last round feel?",
            count: 5, lowLabel: "Desperate", highLabel: "Comfortable")))
        stepId += 1
        steps.append(Step(id: stepId, type: .result))
        return steps
    }

    // MARK: - Exercise 7: Breath-Hold Walk

    static let breathHoldWalk = Exercise(
        id: "breathhold_walk",
        name: "Breath-Hold Walk",
        icon: "figure.walk",
        duration: "8 min",
        description: "Patrick McKeown\u{2019}s Oxygen Advantage exercise. After a gentle exhale, hold your breath and walk, counting steps. Movement during holds is more effective than static holds for improving your BOLT score because it increases metabolic CO\u{2082} production.",
        steps: breathHoldWalkSteps()
    )

    private static func breathHoldWalkSteps() -> [Step] {
        var steps: [Step] = []
        var stepId = 0
        steps.append(Step(id: stepId, type: .instruction(
            text: "You\u{2019}ll hold your breath after a gentle exhale and walk, counting your steps. Start easy \u{2014} your goal is to add a few steps each round.",
            autoAdvanceSeconds: 6)))
        stepId += 1
        for round in 1...6 {
            steps.append(Step(id: stepId, type: .instruction(
                text: "Round \(round) of 6 \u{2014} Breathe normally for 30 seconds",
                autoAdvanceSeconds: 3)))
            stepId += 1
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Normal nasal breathing",
                seconds: 30, showPanicButton: false)))
            stepId += 1
            steps.append(Step(id: stepId, type: .instruction(
                text: "Gentle breath in\u{2026} and out. Pinch your nose.",
                autoAdvanceSeconds: 4)))
            stepId += 1
            steps.append(Step(id: stepId, type: .tapCounter(
                text: "Walk and tap each step \u{2014} stop when you need to breathe",
                seconds: 60)))
            stepId += 1
            steps.append(Step(id: stepId, type: .instruction(
                text: "Resume gentle nasal breathing",
                autoAdvanceSeconds: 4)))
            stepId += 1
        }
        steps.append(Step(id: stepId, type: .result))
        return steps
    }

    // MARK: - Exercise 8: Apnea Pyramid

    static let apneaPyramid = Exercise(
        id: "apnea_pyramid",
        name: "Apnea Pyramid",
        icon: "triangle",
        duration: "8 min",
        description: "A freediving dry static pyramid: holds gradually increase to a peak then decrease. The ascending half builds confidence, the peak challenges your limit, and the descending half provides psychological relief. All holds are after a normal exhale.",
        steps: apneaPyramidSteps()
    )

    private static func apneaPyramidSteps() -> [Step] {
        let holdDurations: [TimeInterval] = [10, 15, 20, 25, 30, 25, 20, 15, 10]
        var steps: [Step] = []
        var stepId = 0
        steps.append(Step(id: stepId, type: .instruction(
            text: "A pyramid of breath holds \u{2014} building up, then easing down. All holds are after a normal exhale.",
            autoAdvanceSeconds: 5)))
        stepId += 1
        for (index, holdSeconds) in holdDurations.enumerated() {
            let round = index + 1
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Recovery breathing \u{2014} Round \(round) of 9",
                seconds: 20, showPanicButton: false)))
            stepId += 1
            steps.append(Step(id: stepId, type: .instruction(
                text: "Normal breath in\u{2026} and out",
                autoAdvanceSeconds: 4)))
            stepId += 1
            steps.append(Step(id: stepId, type: .timerCountdown(
                text: "Hold \u{2014} \(Int(holdSeconds))s",
                seconds: holdSeconds, showPanicButton: holdSeconds >= 25)))
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
