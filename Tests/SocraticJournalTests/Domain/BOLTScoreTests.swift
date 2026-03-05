// BOLTScoreTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("BOLTScore Tests")
struct BOLTScoreTests {

    // MARK: - Tier Classification

    @Suite("Tier Classification")
    struct TierClassificationTests {

        @Test("0 seconds is veryLow")
        func zeroIsVeryLow() {
            #expect(BOLTTier.from(score: 0) == .veryLow)
        }

        @Test("9.9 seconds is veryLow")
        func ninePointNineIsVeryLow() {
            #expect(BOLTTier.from(score: 9.9) == .veryLow)
        }

        @Test("10.0 seconds is belowAverage")
        func tenIsBelowAverage() {
            #expect(BOLTTier.from(score: 10.0) == .belowAverage)
        }

        @Test("19.9 seconds is belowAverage")
        func nineteenPointNineIsBelowAverage() {
            #expect(BOLTTier.from(score: 19.9) == .belowAverage)
        }

        @Test("20.0 seconds is average")
        func twentyIsAverage() {
            #expect(BOLTTier.from(score: 20.0) == .average)
        }

        @Test("29.9 seconds is average")
        func twentyNinePointNineIsAverage() {
            #expect(BOLTTier.from(score: 29.9) == .average)
        }

        @Test("30.0 seconds is good")
        func thirtyIsGood() {
            #expect(BOLTTier.from(score: 30.0) == .good)
        }

        @Test("39.9 seconds is good")
        func thirtyNinePointNineIsGood() {
            #expect(BOLTTier.from(score: 39.9) == .good)
        }

        @Test("40.0 seconds is excellent")
        func fortyIsExcellent() {
            #expect(BOLTTier.from(score: 40.0) == .excellent)
        }

        @Test("120.0 seconds is excellent")
        func oneHundredTwentyIsExcellent() {
            #expect(BOLTTier.from(score: 120.0) == .excellent)
        }
    }

    // MARK: - Tier Properties

    @Suite("Tier Properties")
    struct TierPropertyTests {

        @Test("Each tier has non-empty label")
        func labelsNonEmpty() {
            let tiers: [BOLTTier] = [.veryLow, .belowAverage, .average, .good, .excellent]
            for tier in tiers {
                #expect(!tier.label.isEmpty, "Tier \(tier) has empty label")
            }
        }

        @Test("Each tier has non-empty colorHex")
        func colorHexNonEmpty() {
            let tiers: [BOLTTier] = [.veryLow, .belowAverage, .average, .good, .excellent]
            for tier in tiers {
                #expect(!tier.colorHex.isEmpty, "Tier \(tier) has empty colorHex")
            }
        }

        @Test("Each tier has non-empty interpretation")
        func interpretationNonEmpty() {
            let tiers: [BOLTTier] = [.veryLow, .belowAverage, .average, .good, .excellent]
            for tier in tiers {
                #expect(!tier.interpretation.isEmpty, "Tier \(tier) has empty interpretation")
            }
        }
    }

    // MARK: - Codable

    @Test("BOLTScore Codable round-trip")
    func codableRoundTrip() throws {
        let score = BOLTScore(id: "test-id", score: 25.3, recordedAt: Date())

        let encoder = JSONEncoder()
        let data = try encoder.encode(score)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(BOLTScore.self, from: data)

        #expect(decoded.id == score.id)
        #expect(decoded.score == score.score)
    }

    // MARK: - Trend

    @Suite("Trend Calculation")
    struct TrendTests {

        @Test("Improved when current > previous by >2s")
        func improved() {
            let trend = BOLTTier.trend(previous: 25.0, current: 30.0)
            #expect(trend == .improved)
        }

        @Test("Declined when current < previous by >2s")
        func declined() {
            let trend = BOLTTier.trend(previous: 30.0, current: 25.0)
            #expect(trend == .declined)
        }

        @Test("Same when difference is within ±2s")
        func same() {
            let trend = BOLTTier.trend(previous: 25.0, current: 26.0)
            #expect(trend == .same)
        }

        @Test("Same when difference is exactly 2s")
        func sameAtExactBoundary() {
            let trend = BOLTTier.trend(previous: 25.0, current: 27.0)
            #expect(trend == .same)
        }

        @Test("Improved when difference is just over 2s")
        func improvedJustOver() {
            let trend = BOLTTier.trend(previous: 25.0, current: 27.1)
            #expect(trend == .improved)
        }
    }
}
