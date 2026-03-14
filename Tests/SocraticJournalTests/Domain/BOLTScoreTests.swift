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

    // MARK: - BOLTScore Properties

    @Suite("BOLTScore Properties")
    struct BOLTScorePropertyTests {

        @Test("BOLTScore initializer sets correct defaults")
        func initializerDefaults() {
            let score = BOLTScore(score: 25.0)
            #expect(!score.id.isEmpty)
            #expect(score.score == 25.0)
        }

        @Test("BOLTScore.tier returns correct tier")
        func tierComputed() {
            let score5 = BOLTScore(score: 5.0)
            #expect(score5.tier == .veryLow)

            let score15 = BOLTScore(score: 15.0)
            #expect(score15.tier == .belowAverage)

            let score25 = BOLTScore(score: 25.0)
            #expect(score25.tier == .average)

            let score35 = BOLTScore(score: 35.0)
            #expect(score35.tier == .good)

            let score45 = BOLTScore(score: 45.0)
            #expect(score45.tier == .excellent)
        }

        @Test("Trend symbols are correct")
        func trendSymbols() {
            #expect(BOLTTier.TrendDirection.improved.symbol == "\u{2191}")
            #expect(BOLTTier.TrendDirection.declined.symbol == "\u{2193}")
            #expect(BOLTTier.TrendDirection.same.symbol == "\u{2192}")
        }

        @Test("Trend colors are correct")
        func trendColors() {
            #expect(BOLTTier.TrendDirection.improved.colorHex == "5A6E3D")
            #expect(BOLTTier.TrendDirection.declined.colorHex == "C4502A")
            #expect(BOLTTier.TrendDirection.same.colorHex == "7A6E60")
        }
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
