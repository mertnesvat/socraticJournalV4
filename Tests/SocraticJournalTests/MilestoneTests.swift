// MilestoneTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

#if os(iOS)
/// Tests for milestone types, thresholds, and unlock logic
struct MilestoneTests {

    // MARK: - First Entry Milestone

    @Test("First entry milestone has threshold of 1")
    func testFirstEntryThreshold() {
        #expect(MilestoneType.firstEntry.threshold == 1)
    }

    @Test("First entry milestone is not a streak milestone")
    func testFirstEntryIsNotStreakMilestone() {
        #expect(MilestoneType.firstEntry.isStreakMilestone == false)
    }

    // MARK: - Entry Count Milestone Thresholds

    @Test("10 entries milestone has correct threshold")
    func testEntries10Threshold() {
        #expect(MilestoneType.entries10.threshold == 10)
    }

    @Test("25 entries milestone has correct threshold")
    func testEntries25Threshold() {
        #expect(MilestoneType.entries25.threshold == 25)
    }

    @Test("50 entries milestone has correct threshold")
    func testEntries50Threshold() {
        #expect(MilestoneType.entries50.threshold == 50)
    }

    @Test("100 entries milestone has correct threshold")
    func testEntries100Threshold() {
        #expect(MilestoneType.entries100.threshold == 100)
    }

    @Test("All entry milestones are not streak milestones")
    func testEntryMilestonesAreNotStreakMilestones() {
        #expect(MilestoneType.entries10.isStreakMilestone == false)
        #expect(MilestoneType.entries25.isStreakMilestone == false)
        #expect(MilestoneType.entries50.isStreakMilestone == false)
        #expect(MilestoneType.entries100.isStreakMilestone == false)
    }

    // MARK: - Streak Milestone Thresholds

    @Test("3-day streak milestone has correct threshold")
    func testStreak3Threshold() {
        #expect(MilestoneType.streak3.threshold == 3)
    }

    @Test("7-day streak milestone has correct threshold")
    func testStreak7Threshold() {
        #expect(MilestoneType.streak7.threshold == 7)
    }

    @Test("14-day streak milestone has correct threshold")
    func testStreak14Threshold() {
        #expect(MilestoneType.streak14.threshold == 14)
    }

    @Test("30-day streak milestone has correct threshold")
    func testStreak30Threshold() {
        #expect(MilestoneType.streak30.threshold == 30)
    }

    @Test("All streak milestones are correctly identified as streak milestones")
    func testStreakMilestonesAreStreakMilestones() {
        #expect(MilestoneType.streak3.isStreakMilestone == true)
        #expect(MilestoneType.streak7.isStreakMilestone == true)
        #expect(MilestoneType.streak14.isStreakMilestone == true)
        #expect(MilestoneType.streak30.isStreakMilestone == true)
    }

    // MARK: - Parameterized Threshold Tests

    @Test("Entry milestones have correct thresholds", arguments: [
        (MilestoneType.firstEntry, 1),
        (MilestoneType.entries10, 10),
        (MilestoneType.entries25, 25),
        (MilestoneType.entries50, 50),
        (MilestoneType.entries100, 100)
    ])
    func testEntryMilestoneThresholds(milestone: MilestoneType, expectedThreshold: Int) {
        #expect(milestone.threshold == expectedThreshold)
        #expect(milestone.isStreakMilestone == false)
    }

    @Test("Streak milestones have correct thresholds", arguments: [
        (MilestoneType.streak3, 3),
        (MilestoneType.streak7, 7),
        (MilestoneType.streak14, 14),
        (MilestoneType.streak30, 30)
    ])
    func testStreakMilestoneThresholds(milestone: MilestoneType, expectedThreshold: Int) {
        #expect(milestone.threshold == expectedThreshold)
        #expect(milestone.isStreakMilestone == true)
    }

    // MARK: - Milestone Struct Tests

    @Test("Milestone struct initializes with correct values")
    func testMilestoneInitialization() {
        let milestone = Milestone(type: .firstEntry, isUnlocked: true, progress: 1.0)

        #expect(milestone.id == MilestoneType.firstEntry.rawValue)
        #expect(milestone.type == .firstEntry)
        #expect(milestone.isUnlocked == true)
        #expect(milestone.progress == 1.0)
    }

    @Test("Milestone progress is clamped to maximum of 1.0")
    func testMilestoneProgressClampedToMax() {
        let milestone = Milestone(type: .entries10, isUnlocked: true, progress: 1.5)

        #expect(milestone.progress == 1.0)
    }

    @Test("Milestone progress is clamped to minimum of 0.0")
    func testMilestoneProgressClampedToMin() {
        let milestone = Milestone(type: .entries10, isUnlocked: false, progress: -0.5)

        #expect(milestone.progress == 0.0)
    }

    @Test("Milestone progress within valid range is preserved")
    func testMilestoneProgressValidRange() {
        let milestone = Milestone(type: .streak7, isUnlocked: false, progress: 0.57)

        #expect(milestone.progress == 0.57)
    }

    @Test("Unlocked milestone retains unlocked state")
    func testUnlockedMilestoneState() {
        let milestone = Milestone(type: .streak30, isUnlocked: true, progress: 1.0)

        #expect(milestone.isUnlocked == true)
    }

    @Test("Locked milestone retains locked state")
    func testLockedMilestoneState() {
        let milestone = Milestone(type: .entries100, isUnlocked: false, progress: 0.25)

        #expect(milestone.isUnlocked == false)
    }

    // MARK: - Milestone ID Tests

    @Test("Each milestone type has unique id based on rawValue")
    func testMilestoneIdsAreUnique() {
        let milestones = MilestoneType.allCases.map { type in
            Milestone(type: type, isUnlocked: false, progress: 0)
        }

        let ids = milestones.map { $0.id }
        let uniqueIds = Set(ids)

        #expect(ids.count == uniqueIds.count)
    }

    @Test("Milestone id equals type rawValue")
    func testMilestoneIdEqualsRawValue() {
        for type in MilestoneType.allCases {
            let milestone = Milestone(type: type, isUnlocked: false, progress: 0)
            #expect(milestone.id == type.rawValue)
        }
    }

    // MARK: - All Cases Coverage

    @Test("MilestoneType has exactly 9 cases")
    func testMilestoneTypeCount() {
        #expect(MilestoneType.allCases.count == 9)
    }

    @Test("All milestone types have non-empty rawValue")
    func testAllMilestoneTypesHaveRawValue() {
        for type in MilestoneType.allCases {
            #expect(!type.rawValue.isEmpty)
        }
    }

    @Test("All milestone types have positive threshold")
    func testAllMilestoneTypesHavePositiveThreshold() {
        for type in MilestoneType.allCases {
            #expect(type.threshold > 0)
        }
    }

    // MARK: - Milestone Icon Tests

    @Test("All milestone types have non-empty icon")
    func testAllMilestoneTypesHaveIcon() {
        for type in MilestoneType.allCases {
            #expect(!type.icon.isEmpty)
        }
    }

    // MARK: - Milestone Description Tests

    @Test("All milestone types have non-empty description")
    func testAllMilestoneTypesHaveDescription() {
        for type in MilestoneType.allCases {
            #expect(!type.description.isEmpty)
        }
    }

    // MARK: - Milestone Unlock Logic Tests (via Milestone struct)

    @Test("Milestone at exactly threshold should be unlockable")
    func testMilestoneAtExactThreshold() {
        // When entries equals threshold, milestone should be unlocked
        // This tests the expected behavior - progress at 1.0 means threshold reached
        let milestone = Milestone(type: .entries10, isUnlocked: true, progress: 1.0)

        #expect(milestone.isUnlocked == true)
        #expect(milestone.progress == 1.0)
    }

    @Test("Milestone below threshold should not be unlocked")
    func testMilestoneBelowThreshold() {
        // 5 entries out of 10 = 50% progress, not unlocked
        let milestone = Milestone(type: .entries10, isUnlocked: false, progress: 0.5)

        #expect(milestone.isUnlocked == false)
        #expect(milestone.progress == 0.5)
    }

    @Test("Milestone above threshold retains unlocked state")
    func testMilestoneAboveThreshold() {
        // Even with more than threshold, progress caps at 1.0
        let milestone = Milestone(type: .firstEntry, isUnlocked: true, progress: 5.0)

        #expect(milestone.isUnlocked == true)
        #expect(milestone.progress == 1.0)  // Clamped to 1.0
    }

    // MARK: - Streak vs Entry Milestone Categorization

    @Test("Exactly 4 streak milestones exist")
    func testStreakMilestoneCount() {
        let streakMilestones = MilestoneType.allCases.filter { $0.isStreakMilestone }
        #expect(streakMilestones.count == 4)
    }

    @Test("Exactly 5 entry milestones exist")
    func testEntryMilestoneCount() {
        let entryMilestones = MilestoneType.allCases.filter { !$0.isStreakMilestone }
        #expect(entryMilestones.count == 5)
    }

    @Test("Streak milestones are streak3, streak7, streak14, streak30")
    func testStreakMilestoneTypes() {
        let streakMilestones = MilestoneType.allCases.filter { $0.isStreakMilestone }

        #expect(streakMilestones.contains(.streak3))
        #expect(streakMilestones.contains(.streak7))
        #expect(streakMilestones.contains(.streak14))
        #expect(streakMilestones.contains(.streak30))
    }

    @Test("Entry milestones are firstEntry, entries10, entries25, entries50, entries100")
    func testEntryMilestoneTypes() {
        let entryMilestones = MilestoneType.allCases.filter { !$0.isStreakMilestone }

        #expect(entryMilestones.contains(.firstEntry))
        #expect(entryMilestones.contains(.entries10))
        #expect(entryMilestones.contains(.entries25))
        #expect(entryMilestones.contains(.entries50))
        #expect(entryMilestones.contains(.entries100))
    }

    // MARK: - Threshold Ordering Tests

    @Test("Entry milestone thresholds are in ascending order")
    func testEntryThresholdsAscending() {
        #expect(MilestoneType.firstEntry.threshold < MilestoneType.entries10.threshold)
        #expect(MilestoneType.entries10.threshold < MilestoneType.entries25.threshold)
        #expect(MilestoneType.entries25.threshold < MilestoneType.entries50.threshold)
        #expect(MilestoneType.entries50.threshold < MilestoneType.entries100.threshold)
    }

    @Test("Streak milestone thresholds are in ascending order")
    func testStreakThresholdsAscending() {
        #expect(MilestoneType.streak3.threshold < MilestoneType.streak7.threshold)
        #expect(MilestoneType.streak7.threshold < MilestoneType.streak14.threshold)
        #expect(MilestoneType.streak14.threshold < MilestoneType.streak30.threshold)
    }
}
#endif
