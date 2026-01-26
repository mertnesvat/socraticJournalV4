// CharacterQuizHistoryEntry.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A saved character quiz result with metadata for history tracking
public struct CharacterQuizHistoryEntry: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let universeId: String
    public let universeName: String
    public let result: CharacterMatchResult
    public let createdAt: Date
    public var isFavorite: Bool
    public let entryCountAtAnalysis: Int

    public init(
        id: String = UUID().uuidString,
        universeId: String,
        universeName: String,
        result: CharacterMatchResult,
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        entryCountAtAnalysis: Int
    ) {
        self.id = id
        self.universeId = universeId
        self.universeName = universeName
        self.result = result
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.entryCountAtAnalysis = entryCountAtAnalysis
    }

    /// Returns the top character match from this result
    public var topMatch: CharacterMatch? {
        result.topMatch
    }

    /// Returns the top character name for display
    public var topCharacterName: String {
        topMatch?.characterName ?? "Unknown"
    }

    /// Returns the top match confidence as percentage
    public var topMatchConfidence: String {
        topMatch?.confidencePercentage ?? "0%"
    }

    /// Returns a formatted date string for display
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// Returns relative time string (e.g., "2 days ago")
    public var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    /// Checks if this result has evolved significantly from another result
    /// (for showing "personality evolved" indicator)
    public func hasEvolvedFrom(_ other: CharacterQuizHistoryEntry) -> Bool {
        guard universeId == other.universeId else { return false }

        // Check if top match changed
        if topMatch?.characterId != other.topMatch?.characterId {
            return true
        }

        // Check if confidence changed significantly (more than 10%)
        if let currentConfidence = topMatch?.confidence,
           let previousConfidence = other.topMatch?.confidence {
            let difference = abs(currentConfidence - previousConfidence)
            if difference > 0.1 {
                return true
            }
        }

        return false
    }
}
