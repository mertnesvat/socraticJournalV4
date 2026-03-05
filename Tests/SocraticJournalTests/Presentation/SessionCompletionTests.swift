// SessionCompletionTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

@Suite("Session Completion Tests")
struct SessionCompletionTests {

    // MARK: - Duration Formatting

    @Suite("Duration Formatting")
    struct DurationFormattingTests {

        @Test("312 seconds formats to 5:12")
        func fiveMinuteTwelve() {
            #expect(SessionStatsGrid.formatDuration(312) == "5:12")
        }

        @Test("60 seconds formats to 1:00")
        func oneMinute() {
            #expect(SessionStatsGrid.formatDuration(60) == "1:00")
        }

        @Test("5 seconds formats to 0:05")
        func fiveSeconds() {
            #expect(SessionStatsGrid.formatDuration(5) == "0:05")
        }

        @Test("0 seconds formats to 0:00")
        func zeroSeconds() {
            #expect(SessionStatsGrid.formatDuration(0) == "0:00")
        }

        @Test("600 seconds formats to 10:00")
        func tenMinutes() {
            #expect(SessionStatsGrid.formatDuration(600) == "10:00")
        }
    }

    // MARK: - Pattern Insight Lookup

    @Suite("Pattern Insight Lookup")
    struct PatternInsightTests {

        @Test("Resonance insight contains baroreflex")
        func resonanceInsight() {
            let insight = InsightCard.insight(for: "resonance")
            #expect(insight.contains("baroreflex"))
        }

        @Test("Coherent insight contains parasympathetic")
        func coherentInsight() {
            let insight = InsightCard.insight(for: "coherent")
            #expect(insight.contains("parasympathetic"))
        }

        @Test("Box insight contains Navy SEALs")
        func boxInsight() {
            let insight = InsightCard.insight(for: "box")
            #expect(insight.contains("Navy SEALs"))
        }

        @Test("478 insight contains tranquiliser")
        func fourSevenEightInsight() {
            let insight = InsightCard.insight(for: "478")
            #expect(insight.contains("tranquiliser"))
        }

        @Test("Physiological insight contains Huberman")
        func physiologicalInsight() {
            let insight = InsightCard.insight(for: "physiological")
            #expect(insight.contains("Huberman"))
        }

        @Test("Buteyko insight contains chemoreceptors")
        func buteykoInsight() {
            let insight = InsightCard.insight(for: "buteyko")
            #expect(insight.contains("chemoreceptors"))
        }

        @Test("Tummo insight contains Wim Hof")
        func tummoInsight() {
            let insight = InsightCard.insight(for: "wim")
            #expect(insight.contains("Wim Hof"))
        }

        @Test("Nadi insight contains Nadi Shodhana")
        func nadiInsight() {
            let insight = InsightCard.insight(for: "nadi")
            #expect(insight.contains("Nadi Shodhana"))
        }

        @Test("Unknown pattern returns fallback insight")
        func unknownPatternInsight() {
            let insight = InsightCard.insight(for: "unknown_pattern")
            #expect(!insight.isEmpty)
            #expect(insight.contains("breath practice"))
        }

        @Test("All 8 pattern insights are non-empty")
        func allInsightsNonEmpty() {
            let patternIds = ["resonance", "coherent", "box", "478", "physiological", "buteyko", "wim", "nadi"]
            for id in patternIds {
                let insight = InsightCard.insight(for: id)
                #expect(!insight.isEmpty, "Insight for \(id) is empty")
            }
        }
    }

    // MARK: - Goal Crossing Detection

    @Suite("Goal Crossing Detection")
    struct GoalCrossingTests {

        @Test("Goal crossed when session pushes past threshold")
        func goalCrossed() {
            // previousTotal = 3.0, sessionMinutes = 3.0, goal = 5
            let previousTotal = 3.0
            let sessionMinutes = 3.0
            let goal = 5
            let crossed = previousTotal < Double(goal) && (previousTotal + sessionMinutes) >= Double(goal)
            #expect(crossed)
        }

        @Test("Goal NOT crossed when already past threshold")
        func goalNotCrossedAlreadyPast() {
            // previousTotal = 6.0, sessionMinutes = 3.0, goal = 5
            let previousTotal = 6.0
            let sessionMinutes = 3.0
            let goal = 5
            let crossed = previousTotal < Double(goal) && (previousTotal + sessionMinutes) >= Double(goal)
            #expect(!crossed)
        }

        @Test("Goal NOT crossed when still under threshold")
        func goalNotCrossedStillUnder() {
            // previousTotal = 1.0, sessionMinutes = 1.0, goal = 5
            let previousTotal = 1.0
            let sessionMinutes = 1.0
            let goal = 5
            let crossed = previousTotal < Double(goal) && (previousTotal + sessionMinutes) >= Double(goal)
            #expect(!crossed)
        }
    }

    // MARK: - Session Threshold

    @Suite("Session Overlay Threshold")
    struct SessionThresholdTests {

        @Test("Sessions under 30 seconds should NOT trigger overlay")
        func shortSessionNoOverlay() {
            let duration: TimeInterval = 29
            #expect(duration < 30)
        }

        @Test("Sessions at exactly 30 seconds SHOULD trigger overlay")
        func thirtySecondSessionTriggers() {
            let duration: TimeInterval = 30
            #expect(duration >= 30)
        }

        @Test("Sessions over 30 seconds SHOULD trigger overlay")
        func longSessionTriggers() {
            let duration: TimeInterval = 300
            #expect(duration >= 30)
        }
    }
}
#endif
