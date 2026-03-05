// InsightSelectionServiceTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
@testable import SocraticJournal

@Suite("InsightSelectionService Tests")
struct InsightSelectionServiceTests {

    // MARK: - Basic Selection

    @Test("Returns an insight when insights are available")
    func returnsInsight() {
        let service = InsightSelectionService()
        let insight = service.selectInsight(forPatternId: "resonance")
        #expect(insight != nil)
    }

    @Test("Returns nil when no insights are available")
    func returnsNilForEmptyInsights() {
        let service = InsightSelectionService(insights: [])
        let insight = service.selectInsight(forPatternId: "resonance")
        #expect(insight == nil)
    }

    // MARK: - Pattern Weighting

    @Test("Selects from pattern-specific pool when available")
    func selectsPatternSpecific() {
        let patternInsight = BreathInsight(id: "p1", text: "Pattern specific", relatedPatternIds: ["resonance"])
        let generalInsight = BreathInsight(id: "g1", text: "General")
        let service = InsightSelectionService(insights: [patternInsight, generalInsight])

        // Run many times -- at least some should be pattern-specific
        var patternSpecificCount = 0
        for _ in 0..<100 {
            if let result = service.selectInsight(forPatternId: "resonance") {
                if result.id == "p1" {
                    patternSpecificCount += 1
                }
            }
        }
        // With 70% weighting, we expect well over 50 out of 100
        #expect(patternSpecificCount > 30)
    }

    @Test("Falls back to general insights when no pattern match exists")
    func fallsBackToGeneral() {
        let generalInsight = BreathInsight(id: "g1", text: "General")
        let otherPatternInsight = BreathInsight(id: "p1", text: "Other pattern", relatedPatternIds: ["box"])
        let service = InsightSelectionService(insights: [generalInsight, otherPatternInsight])

        // For a pattern with no specific insights, should still return something
        let insight = service.selectInsight(forPatternId: "resonance")
        #expect(insight != nil)
    }

    // MARK: - Duplicate Avoidance

    @Test("Never returns the same insight as lastShownId")
    func avoidsLastShown() {
        let insight1 = BreathInsight(id: "i1", text: "First")
        let insight2 = BreathInsight(id: "i2", text: "Second")
        let service = InsightSelectionService(insights: [insight1, insight2])

        for _ in 0..<50 {
            let result = service.selectInsight(forPatternId: "resonance", lastShownId: "i1")
            #expect(result?.id == "i2")
        }
    }

    @Test("selectNextInsight returns a different insight than current")
    func nextInsightIsDifferent() {
        let insight1 = BreathInsight(id: "i1", text: "First")
        let insight2 = BreathInsight(id: "i2", text: "Second")
        let service = InsightSelectionService(insights: [insight1, insight2])

        let next = service.selectNextInsight(forPatternId: "resonance", currentId: "i1")
        #expect(next?.id == "i2")
    }

    @Test("Returns insight even when only one exists and it matches lastShownId")
    func singleInsightStillReturns() {
        let insight = BreathInsight(id: "only", text: "The only one")
        let service = InsightSelectionService(insights: [insight])

        let result = service.selectInsight(forPatternId: "resonance", lastShownId: "only")
        #expect(result != nil)
        #expect(result?.id == "only")
    }

    // MARK: - BreathInsight Model

    @Test("BreathInsight isGeneral returns true for empty relatedPatternIds")
    func isGeneralWhenEmpty() {
        let insight = BreathInsight(id: "test", text: "General insight")
        #expect(insight.isGeneral == true)
    }

    @Test("BreathInsight isGeneral returns false when pattern IDs are set")
    func isNotGeneralWithPatternIds() {
        let insight = BreathInsight(id: "test", text: "Specific", relatedPatternIds: ["box"])
        #expect(insight.isGeneral == false)
    }

    @Test("All 30 static insights exist with unique IDs")
    func allInsightsAreUnique() {
        let allInsights = BreathInsight.allInsights
        #expect(allInsights.count == 30)

        let ids = Set(allInsights.map(\.id))
        #expect(ids.count == 30)
    }

    @Test("All insight texts are non-empty")
    func allInsightsHaveText() {
        for insight in BreathInsight.allInsights {
            #expect(!insight.text.isEmpty)
        }
    }

    @Test("Pattern-specific insights reference valid pattern IDs")
    func patternIdsAreValid() {
        let validIds = Set(BreathPattern.allPatterns.map(\.id))
        for insight in BreathInsight.allInsights {
            for patternId in insight.relatedPatternIds {
                #expect(validIds.contains(patternId), "Insight \(insight.id) references invalid pattern: \(patternId)")
            }
        }
    }
}
