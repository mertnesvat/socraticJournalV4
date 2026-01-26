// LocalCharacterQuizHistoryRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-based implementation of CharacterQuizHistoryRepositoryProtocol
/// Persists character quiz history locally for MVP
public final class LocalCharacterQuizHistoryRepository: CharacterQuizHistoryRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let storageKey = "com.socraticjournal.characterQuizHistory"

    /// In-memory cache for faster access
    private var cache: [CharacterQuizHistoryEntry]?

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Private Helpers

    private func loadFromDisk() -> [CharacterQuizHistoryEntry] {
        if let cache = cache {
            return cache
        }

        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }

        do {
            let entries = try decoder.decode([CharacterQuizHistoryEntry].self, from: data)
            cache = entries
            return entries
        } catch {
            // If decoding fails, return empty array
            return []
        }
    }

    private func saveToDisk(_ entries: [CharacterQuizHistoryEntry]) throws {
        let data = try encoder.encode(entries)
        defaults.set(data, forKey: storageKey)
        cache = entries
    }

    // MARK: - History Operations

    public func saveResult(_ entry: CharacterQuizHistoryEntry) async throws {
        var entries = loadFromDisk()
        entries.insert(entry, at: 0)  // Add to front for newest-first order
        try saveToDisk(entries)
    }

    public func getAllResults() async throws -> [CharacterQuizHistoryEntry] {
        loadFromDisk().sorted { $0.createdAt > $1.createdAt }
    }

    public func getResults(forUniverse universeId: String) async throws -> [CharacterQuizHistoryEntry] {
        loadFromDisk()
            .filter { $0.universeId == universeId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func getResult(id: String) async throws -> CharacterQuizHistoryEntry? {
        loadFromDisk().first { $0.id == id }
    }

    // MARK: - Favorites

    public func toggleFavorite(id: String) async throws {
        var entries = loadFromDisk()
        guard let index = entries.firstIndex(where: { $0.id == id }) else {
            return
        }
        entries[index].isFavorite.toggle()
        try saveToDisk(entries)
    }

    public func getFavorites() async throws -> [CharacterQuizHistoryEntry] {
        loadFromDisk()
            .filter { $0.isFavorite }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Deletion

    public func deleteResult(id: String) async throws {
        var entries = loadFromDisk()
        entries.removeAll { $0.id == id }
        try saveToDisk(entries)
    }

    public func deleteResults(forUniverse universeId: String) async throws {
        var entries = loadFromDisk()
        entries.removeAll { $0.universeId == universeId }
        try saveToDisk(entries)
    }

    public func clearAllHistory() async throws {
        defaults.removeObject(forKey: storageKey)
        cache = nil
    }

    // MARK: - Queries

    public func getMostRecentResult(forUniverse universeId: String) async throws -> CharacterQuizHistoryEntry? {
        loadFromDisk()
            .filter { $0.universeId == universeId }
            .max { $0.createdAt < $1.createdAt }
    }

    public func getResultCount() async throws -> Int {
        loadFromDisk().count
    }
}
