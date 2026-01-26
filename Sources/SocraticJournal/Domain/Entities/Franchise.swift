// Franchise.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a fictional franchise for character matching
public enum Franchise: String, Codable, CaseIterable, Hashable, Sendable {
    case lordOfTheRings
    case harryPotter
    case starWars

    /// Display name for the franchise
    public var displayName: String {
        switch self {
        case .lordOfTheRings: return "Lord of the Rings"
        case .harryPotter: return "Harry Potter"
        case .starWars: return "Star Wars"
        }
    }

    /// SF Symbol icon name for the franchise
    public var iconName: String {
        switch self {
        case .lordOfTheRings: return "mountain.2.fill"
        case .harryPotter: return "wand.and.stars"
        case .starWars: return "staroflife.fill"
        }
    }

    /// Short description of the franchise universe
    public var universeDescription: String {
        switch self {
        case .lordOfTheRings:
            return "Middle-earth's epic tale of courage, friendship, and the battle against darkness"
        case .harryPotter:
            return "The wizarding world of magic, wonder, and the triumph of love over evil"
        case .starWars:
            return "A galaxy far, far away where hope and the Force shape destiny"
        }
    }
}
