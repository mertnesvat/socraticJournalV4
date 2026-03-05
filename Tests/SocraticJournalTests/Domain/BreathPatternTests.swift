// BreathPatternTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("BreathPattern Tests")
struct BreathPatternTests {

    @Test("All 8 patterns exist in allPatterns")
    func allPatternsExist() {
        #expect(BreathPattern.allPatterns.count == 8)
    }

    @Test("Pattern IDs are unique")
    func patternIDsUnique() {
        let ids = BreathPattern.allPatterns.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count)
    }

    @Test("Resonance cycle duration is correct")
    func resonanceCycleDuration() {
        let pattern = BreathPattern.resonance
        // 5.5 inhale + 5.5 exhale = 11.0
        #expect(pattern.cycleDuration == 11.0)
    }

    @Test("Coherent cycle duration is correct")
    func coherentCycleDuration() {
        let pattern = BreathPattern.coherent
        // 6.0 inhale + 6.0 exhale = 12.0
        #expect(pattern.cycleDuration == 12.0)
    }

    @Test("Box cycle duration is correct")
    func boxCycleDuration() {
        let pattern = BreathPattern.box
        // 4+4+4+4 = 16.0
        #expect(pattern.cycleDuration == 16.0)
    }

    @Test("4-7-8 cycle duration is correct")
    func fourSevenEightCycleDuration() {
        let pattern = BreathPattern.fourSevenEight
        // 4+7+8 = 19.0
        #expect(pattern.cycleDuration == 19.0)
    }

    @Test("Physiological Sigh cycle duration is correct")
    func physiologicalSighCycleDuration() {
        let pattern = BreathPattern.physiologicalSigh
        // 2+1+0.5+8 = 11.5
        #expect(pattern.cycleDuration == 11.5)
    }

    @Test("Buteyko cycle duration is correct")
    func buteykoCycleDuration() {
        let pattern = BreathPattern.buteyko
        // 3+3+3 = 9.0
        #expect(pattern.cycleDuration == 9.0)
    }

    @Test("Tummo cycle duration is correct")
    func tummoCycleDuration() {
        let pattern = BreathPattern.tummo
        // 2+1.5 = 3.5
        #expect(pattern.cycleDuration == 3.5)
    }

    @Test("Alternate Nostril cycle duration is correct")
    func alternateNostrilCycleDuration() {
        let pattern = BreathPattern.alternateNostril
        // 4+4+4 = 12.0
        #expect(pattern.cycleDuration == 12.0)
    }

    @Test("Each pattern has non-empty importance text")
    func patternsHaveImportance() {
        for pattern in BreathPattern.allPatterns {
            #expect(!pattern.importance.isEmpty, "Pattern \(pattern.id) has empty importance")
        }
    }

    @Test("Each pattern has non-empty bestFor text")
    func patternsHaveBestFor() {
        for pattern in BreathPattern.allPatterns {
            #expect(!pattern.bestFor.isEmpty, "Pattern \(pattern.id) has empty bestFor")
        }
    }

    @Test("Resonance has only inhale and exhale phases")
    func resonancePhaseTypes() {
        let phaseTypes = BreathPattern.resonance.phases.map(\.phaseType)
        #expect(phaseTypes == [.inhale, .exhale])
    }

    @Test("Box has all four phase types including two holds")
    func boxPhaseTypes() {
        let phaseTypes = BreathPattern.box.phases.map(\.phaseType)
        #expect(phaseTypes == [.inhale, .hold, .exhale, .hold])
    }

    @Test("Physiological Sigh has inhaleTopUp phase")
    func physiologicalSighHasTopUp() {
        let phaseTypes = BreathPattern.physiologicalSigh.phases.map(\.phaseType)
        #expect(phaseTypes.contains(.inhaleTopUp))
    }

    @Test("Difficulty levels are correctly assigned")
    func difficultyLevels() {
        #expect(BreathPattern.resonance.difficulty == .beginner)
        #expect(BreathPattern.coherent.difficulty == .beginner)
        #expect(BreathPattern.box.difficulty == .beginner)
        #expect(BreathPattern.fourSevenEight.difficulty == .intermediate)
        #expect(BreathPattern.physiologicalSigh.difficulty == .beginner)
        #expect(BreathPattern.buteyko.difficulty == .intermediate)
        #expect(BreathPattern.tummo.difficulty == .advanced)
        #expect(BreathPattern.alternateNostril.difficulty == .intermediate)
    }
}
