// Milestone.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A breath practice milestone that can be unlocked through consistent practice
public struct Milestone: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let colorHex: String
    public var isUnlocked: Bool
    public var unlockedAt: Date?

    public init(
        id: String,
        title: String,
        description: String,
        iconName: String,
        colorHex: String,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.colorHex = colorHex
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}

// MARK: - Predefined Milestones

extension Milestone {
    /// The 10 milestones available in the app, returned in display order
    public static let allMilestones: [Milestone] = [
        Milestone(
            id: "first_breath",
            title: "First Breath",
            description: "Complete your first session",
            iconName: "wind",
            colorHex: "2D5F5D"
        ),
        Milestone(
            id: "week_one",
            title: "Week One",
            description: "7 consecutive days",
            iconName: "calendar",
            colorHex: "2D5F5D"
        ),
        Milestone(
            id: "century",
            title: "Century",
            description: "100 total minutes",
            iconName: "clock",
            colorHex: "2D5F5D"
        ),
        Milestone(
            id: "pattern_explorer",
            title: "Pattern Explorer",
            description: "Use all 8 patterns",
            iconName: "square.grid.3x3",
            colorHex: "C4502A"
        ),
        Milestone(
            id: "dawn_breather",
            title: "Dawn Breather",
            description: "Session before 7 AM",
            iconName: "sunrise",
            colorHex: "C4502A"
        ),
        Milestone(
            id: "night_owl",
            title: "Night Owl",
            description: "Session after 10 PM",
            iconName: "moon.stars",
            colorHex: "6B4C8A"
        ),
        Milestone(
            id: "marathon",
            title: "Marathon",
            description: "20-minute session",
            iconName: "timer",
            colorHex: "C4502A"
        ),
        Milestone(
            id: "monthly_master",
            title: "Monthly Master",
            description: "30 consecutive days",
            iconName: "crown",
            colorHex: "2D5F5D"
        ),
        Milestone(
            id: "thousand_minutes",
            title: "Thousand Minutes",
            description: "1,000 total minutes",
            iconName: "star",
            colorHex: "2D5F5D"
        ),
        Milestone(
            id: "breath_master",
            title: "Breath Master",
            description: "Unlock all milestones",
            iconName: "trophy",
            colorHex: "2D5F5D"
        ),
    ]
}
