// JournalSession.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a complete journal session with Socratic dialogue
public struct JournalSession: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let createdAt: Date
    public var exchanges: [Exchange]
    public var clarityScore: ClarityScore?
    public var wisdomQuote: WisdomQuote?
    public var isComplete: Bool

    public init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        exchanges: [Exchange] = [],
        clarityScore: ClarityScore? = nil,
        wisdomQuote: WisdomQuote? = nil,
        isComplete: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.exchanges = exchanges
        self.clarityScore = clarityScore
        self.wisdomQuote = wisdomQuote
        self.isComplete = isComplete
    }

    /// Returns the title based on the first exchange or a default
    public var title: String {
        guard let firstExchange = exchanges.first else {
            return "New Session"
        }
        let preview = firstExchange.answer.prefix(50)
        return preview.count < firstExchange.answer.count ? "\(preview)..." : String(preview)
    }

    /// Returns the date formatted for display
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// Duration estimate based on number of exchanges
    public var estimatedDuration: String {
        let minutes = exchanges.count * 2
        if minutes < 1 {
            return "Just started"
        }
        return "\(minutes) min"
    }
}
