// FictionalCharacter.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a character from a fictional universe for personality matching
public struct FictionalCharacter: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let universe: String
    public let description: String
    public let traits: [String]
    public let imageAssetName: String

    public init(
        id: String,
        name: String,
        universe: String,
        description: String,
        traits: [String],
        imageAssetName: String
    ) {
        self.id = id
        self.name = name
        self.universe = universe
        self.description = description
        self.traits = traits
        self.imageAssetName = imageAssetName
    }

    /// Returns a comma-separated string of traits for display
    public var traitsDescription: String {
        traits.joined(separator: ", ")
    }

    /// Returns the number of traits this character has
    public var traitCount: Int {
        traits.count
    }

    /// Checks if this character has a specific trait (case-insensitive)
    public func hasTrait(_ trait: String) -> Bool {
        traits.contains { $0.lowercased() == trait.lowercased() }
    }

    /// Returns traits that match the given set (case-insensitive)
    public func matchingTraits(from candidates: Set<String>) -> [String] {
        let lowercasedCandidates = Set(candidates.map { $0.lowercased() })
        return traits.filter { lowercasedCandidates.contains($0.lowercased()) }
    }

    /// Calculates a match score based on shared traits
    public func matchScore(for userTraits: Set<String>) -> Double {
        guard !traits.isEmpty else { return 0 }
        let matches = matchingTraits(from: userTraits)
        return Double(matches.count) / Double(traits.count)
    }
}
