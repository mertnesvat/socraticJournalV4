// TrainingSectionsTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("TrainingData Sections Tests")
struct TrainingSectionsTests {

    @Test("allSections has exactly 2 sections")
    func sectionCount() {
        #expect(TrainingData.allSections.count == 2)
    }

    @Test("Basics section contains exactly 4 exercises")
    func basicsSectionCount() {
        let basics = TrainingData.allSections.first { $0.id == "basics" }
        #expect(basics != nil)
        #expect(basics!.exercises.count == 4)
    }

    @Test("CO2 Tolerance section contains exactly 4 exercises")
    func co2SectionCount() {
        let co2 = TrainingData.allSections.first { $0.id == "co2_tolerance" }
        #expect(co2 != nil)
        #expect(co2!.exercises.count == 4)
    }

    @Test("allExercises computed property returns all 8 exercises")
    func allExercisesBackwardCompat() {
        #expect(TrainingData.allExercises.count == 8)
    }

    @Test("Section titles and subtitles are non-empty")
    func sectionFieldsNonEmpty() {
        for section in TrainingData.allSections {
            #expect(!section.title.isEmpty, "Section \(section.id) has empty title")
            #expect(!section.subtitle.isEmpty, "Section \(section.id) has empty subtitle")
        }
    }

    @Test("Each section has unique id")
    func sectionIDsUnique() {
        let ids = TrainingData.allSections.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count)
    }

    @Test("Exercise IDs across all sections are globally unique")
    func exerciseIDsGloballyUnique() {
        let allIDs = TrainingData.allSections.flatMap { $0.exercises.map(\.id) }
        let uniqueIDs = Set(allIDs)
        #expect(allIDs.count == uniqueIDs.count)
    }
}
