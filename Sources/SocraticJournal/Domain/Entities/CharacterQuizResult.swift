// CharacterQuizResult.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents the complete result of a character quiz analysis
public struct CharacterQuizResult: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let franchise: Franchise
    public let matches: [CharacterMatchEntry]
    public let analyzedAt: Date
    public let journalEntriesUsed: Int

    public init(
        id: String = UUID().uuidString,
        franchise: Franchise,
        matches: [CharacterMatchEntry],
        analyzedAt: Date = Date(),
        journalEntriesUsed: Int
    ) {
        self.id = id
        self.franchise = franchise
        // Sort matches by confidence, highest first
        self.matches = matches.sorted { $0.confidencePercentage > $1.confidencePercentage }
        self.analyzedAt = analyzedAt
        self.journalEntriesUsed = journalEntriesUsed
    }

    /// Returns the top match (highest confidence)
    public var topMatch: CharacterMatchEntry? {
        matches.first
    }

    /// Returns the top N matches
    public func topMatches(_ count: Int) -> [CharacterMatchEntry] {
        Array(matches.prefix(count))
    }

    /// Formatted date string for display
    public var formattedAnalyzedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: analyzedAt)
    }

    /// Time since analysis was performed
    public var timeSinceAnalysis: String {
        let interval = Date().timeIntervalSince(analyzedAt)
        let hours = Int(interval / 3600)
        let days = hours / 24

        if days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else {
            return "Just now"
        }
    }

    /// Description of how many entries were analyzed
    public var entriesDescription: String {
        if journalEntriesUsed == 1 {
            return "Based on 1 journal entry"
        }
        return "Based on \(journalEntriesUsed) journal entries"
    }
}
