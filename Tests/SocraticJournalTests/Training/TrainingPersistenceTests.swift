// TrainingPersistenceTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("TrainingData Persistence Tests")
struct TrainingPersistenceTests {

    private func makeDefaults() -> UserDefaults {
        let suiteName = "com.breathe.test.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test("Initial completion count is 0")
    func initialCountIsZero() {
        let defaults = makeDefaults()
        let count = TrainingData.completionCount(for: "nose_unblocking", defaults: defaults)
        #expect(count == 0)
    }

    @Test("After one increment, count is 1")
    func singleIncrement() {
        let defaults = makeDefaults()
        TrainingData.incrementCompletion(for: "nose_unblocking", defaults: defaults)
        let count = TrainingData.completionCount(for: "nose_unblocking", defaults: defaults)
        #expect(count == 1)
    }

    @Test("After 3 increments, count is 3")
    func tripleIncrement() {
        let defaults = makeDefaults()
        for _ in 0..<3 {
            TrainingData.incrementCompletion(for: "co2_builder", defaults: defaults)
        }
        let count = TrainingData.completionCount(for: "co2_builder", defaults: defaults)
        #expect(count == 3)
    }

    @Test("Counts are independent per exercise ID")
    func independentCounts() {
        let defaults = makeDefaults()
        TrainingData.incrementCompletion(for: "nose_unblocking", defaults: defaults)
        TrainingData.incrementCompletion(for: "nose_unblocking", defaults: defaults)
        TrainingData.incrementCompletion(for: "co2_builder", defaults: defaults)

        #expect(TrainingData.completionCount(for: "nose_unblocking", defaults: defaults) == 2)
        #expect(TrainingData.completionCount(for: "co2_builder", defaults: defaults) == 1)
        #expect(TrainingData.completionCount(for: "altitude_hold", defaults: defaults) == 0)
    }

    @Test("Incrementing one exercise does not affect another")
    func noSideEffects() {
        let defaults = makeDefaults()
        TrainingData.incrementCompletion(for: "altitude_hold", defaults: defaults)

        #expect(TrainingData.completionCount(for: "altitude_hold", defaults: defaults) == 1)
        #expect(TrainingData.completionCount(for: "co2_table", defaults: defaults) == 0)
    }

    @Test("Counts persist across separate calls")
    func persistence() {
        let defaults = makeDefaults()
        TrainingData.incrementCompletion(for: "breathhold_walk", defaults: defaults)
        // Read from same defaults instance
        let count1 = TrainingData.completionCount(for: "breathhold_walk", defaults: defaults)
        TrainingData.incrementCompletion(for: "breathhold_walk", defaults: defaults)
        let count2 = TrainingData.completionCount(for: "breathhold_walk", defaults: defaults)

        #expect(count1 == 1)
        #expect(count2 == 2)
    }
}
