// QuestionLevel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Level of question depth, unlocked progressively as the user engages
public enum QuestionLevel: Int, Codable, Sendable, Hashable, CaseIterable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4

    /// Human-readable display name for the level
    public var displayName: String {
        switch self {
        case .level1: return "Level 1"
        case .level2: return "Level 2"
        case .level3: return "Level 3"
        case .level4: return "Level 4"
        }
    }

    /// Description of what this level represents
    public var description: String {
        switch self {
        case .level1: return "Getting started with light questions"
        case .level2: return "Going a bit deeper"
        case .level3: return "Exploring meaningful topics"
        case .level4: return "The deepest conversations"
        }
    }

    /// Number of days of activity required to unlock this level
    public var unlockDay: Int {
        switch self {
        case .level1: return 0
        case .level2: return 8
        case .level3: return 22
        case .level4: return 29
        }
    }
}
