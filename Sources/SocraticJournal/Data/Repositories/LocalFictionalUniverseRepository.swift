// LocalFictionalUniverseRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Local implementation of FictionalUniverseRepositoryProtocol
/// Uses embedded static data for fictional universes and characters
public final class LocalFictionalUniverseRepository: FictionalUniverseRepositoryProtocol, @unchecked Sendable {
    /// Cache of all universes for efficient lookups
    private let universes: [FictionalUniverse]

    /// Cache of all characters with their universe mapping
    private let charactersByUniverse: [String: [FictionalCharacter]]

    /// All characters flattened for searching
    private let allCharacters: [FictionalCharacter]

    public init() {
        self.universes = FictionalUniverse.allUniverses

        // Build character lookup caches
        var byUniverse: [String: [FictionalCharacter]] = [:]
        var all: [FictionalCharacter] = []

        for universe in universes {
            byUniverse[universe.id] = universe.characters
            all.append(contentsOf: universe.characters)
        }

        self.charactersByUniverse = byUniverse
        self.allCharacters = all
    }

    // MARK: - Universes

    public func getAllUniverses() async throws -> [FictionalUniverse] {
        universes
    }

    public func getUniverse(id: String) async throws -> FictionalUniverse? {
        universes.first { $0.id == id }
    }

    // MARK: - Characters

    public func getAllCharacters() async throws -> [FictionalCharacter] {
        allCharacters
    }

    public func getCharacters(universeId: String) async throws -> [FictionalCharacter] {
        charactersByUniverse[universeId] ?? []
    }

    public func getCharacter(id: String) async throws -> FictionalCharacter? {
        allCharacters.first { $0.id == id }
    }

    public func searchCharacters(byTraits traits: Set<String>) async throws -> [FictionalCharacter] {
        guard !traits.isEmpty else { return allCharacters }

        let lowercasedTraits = Set(traits.map { $0.lowercased() })

        return allCharacters.filter { character in
            character.traits.contains { trait in
                lowercasedTraits.contains(trait.lowercased())
            }
        }
    }

    public func findMatchingCharacters(forTraits traits: Set<String>, limit: Int) async throws -> [FictionalCharacter] {
        guard !traits.isEmpty else { return [] }

        // Score each character based on trait matches
        let scored = allCharacters.map { character -> (character: FictionalCharacter, score: Double) in
            let score = character.matchScore(for: traits)
            return (character, score)
        }

        // Sort by score descending and take top matches
        return scored
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0.character }
    }
}
