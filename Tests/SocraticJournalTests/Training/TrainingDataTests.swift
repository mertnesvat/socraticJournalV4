// TrainingDataTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("TrainingData Tests")
struct TrainingDataTests {

    @Test("All 8 exercises exist")
    func allExercisesCount() {
        #expect(TrainingData.allExercises.count == 8)
    }

    @Test("All exercise IDs are unique")
    func exerciseIDsUnique() {
        let ids = TrainingData.allExercises.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count)
    }

    @Test("All exercises have non-empty name, icon, duration, description")
    func exerciseFieldsNonEmpty() {
        for exercise in TrainingData.allExercises {
            #expect(!exercise.name.isEmpty, "Exercise \(exercise.id) has empty name")
            #expect(!exercise.icon.isEmpty, "Exercise \(exercise.id) has empty icon")
            #expect(!exercise.duration.isEmpty, "Exercise \(exercise.id) has empty duration")
            #expect(!exercise.description.isEmpty, "Exercise \(exercise.id) has empty description")
        }
    }

    @Test("Every exercise ends with a result step")
    func exercisesEndWithResult() {
        for exercise in TrainingData.allExercises {
            guard let lastStep = exercise.steps.last else {
                Issue.record("Exercise \(exercise.id) has no steps")
                continue
            }
            if case .result = lastStep.type {
                // correct
            } else {
                Issue.record("Exercise \(exercise.id) does not end with .result step")
            }
        }
    }

    @Test("Step IDs within each exercise are sequential from 0")
    func stepIDsSequential() {
        for exercise in TrainingData.allExercises {
            let ids = exercise.steps.map(\.id)
            let expected = Array(0..<exercise.steps.count)
            #expect(ids == expected, "Exercise \(exercise.id) has non-sequential step IDs")
        }
    }

    @Test("No exercise has zero steps")
    func noEmptyExercises() {
        for exercise in TrainingData.allExercises {
            #expect(!exercise.steps.isEmpty, "Exercise \(exercise.id) has zero steps")
        }
    }

    // MARK: - Round Counts

    @Test("CO2 Builder has 5 rounds (16 steps total)")
    func co2BuilderRounds() {
        let exercise = TrainingData.allExercises.first { $0.id == "co2_builder" }!
        // 5 rounds x 3 steps + 1 result = 16
        #expect(exercise.steps.count == 16)
    }

    @Test("Altitude Hold has 5 rounds")
    func altitudeHoldRounds() {
        let exercise = TrainingData.allExercises.first { $0.id == "altitude_hold" }!
        // 1 intro + 5 rounds x 4 steps + 4 recovery + 1 result = 26
        #expect(exercise.steps.count == 26)
    }

    @Test("CO2 Table has 8 rounds")
    func co2TableRounds() {
        let exercise = TrainingData.allExercises.first { $0.id == "co2_table" }!
        // 1 safety + 8 rounds x 3 steps + 1 rating + 1 result = 27
        #expect(exercise.steps.count == 27)
    }

    @Test("Apnea Pyramid has 9 hold rounds")
    func apneaPyramidRounds() {
        let exercise = TrainingData.allExercises.first { $0.id == "apnea_pyramid" }!
        // 1 intro + 9 rounds x 3 steps + 1 result = 29
        #expect(exercise.steps.count == 29)
    }

    @Test("Breath-Hold Walk has 6 rounds")
    func breathHoldWalkRounds() {
        let exercise = TrainingData.allExercises.first { $0.id == "breathhold_walk" }!
        // 1 intro + 6 rounds x 5 steps + 1 result = 32
        #expect(exercise.steps.count == 32)
    }
}
