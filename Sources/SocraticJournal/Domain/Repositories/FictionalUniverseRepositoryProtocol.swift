// FictionalUniverseRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining fictional universe data operations
public protocol FictionalUniverseRepositoryProtocol: Sendable {
    // MARK: - Universes

    /// Fetches all available fictional universes
    func getAllUniverses() async throws -> [FictionalUniverse]

    /// Fetches a specific universe by ID
    func getUniverse(id: String) async throws -> FictionalUniverse?

    // MARK: - Characters

    /// Fetches all characters across all universes
    func getAllCharacters() async throws -> [FictionalCharacter]

    /// Fetches characters from a specific universe
    func getCharacters(universeId: String) async throws -> [FictionalCharacter]

    /// Fetches a specific character by ID
    func getCharacter(id: String) async throws -> FictionalCharacter?

    /// Searches characters by trait keywords
    func searchCharacters(byTraits traits: Set<String>) async throws -> [FictionalCharacter]

    /// Finds characters that best match a set of user traits
    func findMatchingCharacters(forTraits traits: Set<String>, limit: Int) async throws -> [FictionalCharacter]
}
