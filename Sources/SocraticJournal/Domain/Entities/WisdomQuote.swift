// WisdomQuote.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Theme categories for wisdom quotes
public enum QuoteTheme: String, Codable, Sendable, CaseIterable {
    case change
    case struggle
    case acceptance
    case relationships
    case purpose
    case selfKnowledge
    case time
    case fear
    case loss
    case gratitude
    case creativity
    case universal

    /// Display name for the theme
    public var displayName: String {
        switch self {
        case .change: return "Change"
        case .struggle: return "Struggle"
        case .acceptance: return "Acceptance"
        case .relationships: return "Relationships"
        case .purpose: return "Purpose"
        case .selfKnowledge: return "Self-Knowledge"
        case .time: return "Time"
        case .fear: return "Fear"
        case .loss: return "Loss"
        case .gratitude: return "Gratitude"
        case .creativity: return "Creativity"
        case .universal: return "Universal"
        }
    }

    /// SF Symbol icon for the theme
    public var iconName: String {
        switch self {
        case .change: return "arrow.triangle.2.circlepath"
        case .struggle: return "figure.climbing"
        case .acceptance: return "heart.circle"
        case .relationships: return "person.2"
        case .purpose: return "target"
        case .selfKnowledge: return "brain.head.profile"
        case .time: return "clock"
        case .fear: return "exclamationmark.shield"
        case .loss: return "leaf"
        case .gratitude: return "hands.clap"
        case .creativity: return "paintbrush"
        case .universal: return "globe"
        }
    }

    /// Keywords used to match content to this theme
    public var keywords: [String] {
        switch self {
        case .change:
            return ["change", "transform", "different", "evolve", "grow", "become", "new", "transition"]
        case .struggle:
            return ["struggle", "difficult", "hard", "challenge", "obstacle", "fight", "persist", "overcome"]
        case .acceptance:
            return ["accept", "let go", "surrender", "peace", "embrace", "allow", "release", "forgive"]
        case .relationships:
            return ["friend", "family", "love", "relationship", "connection", "together", "partner", "people"]
        case .purpose:
            return ["purpose", "meaning", "why", "goal", "mission", "calling", "destiny", "direction"]
        case .selfKnowledge:
            return ["know", "understand", "self", "identity", "who am i", "discover", "awareness", "insight"]
        case .time:
            return ["time", "moment", "present", "past", "future", "now", "yesterday", "tomorrow"]
        case .fear:
            return ["fear", "afraid", "scared", "worry", "anxious", "courage", "brave", "terror"]
        case .loss:
            return ["loss", "grief", "miss", "gone", "death", "end", "goodbye", "mourn"]
        case .gratitude:
            return ["grateful", "thankful", "appreciate", "blessed", "fortune", "luck", "gift", "cherish"]
        case .creativity:
            return ["create", "imagine", "art", "express", "vision", "inspire", "innovate", "design"]
        case .universal:
            return ["life", "wisdom", "truth", "virtue", "human", "soul", "spirit", "philosophy"]
        }
    }
}

/// A wisdom quote shown at the end of a journal session
public struct WisdomQuote: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let text: String
    public let author: String
    public let source: String?
    public let theme: QuoteTheme

    public init(
        id: UUID = UUID(),
        text: String,
        author: String,
        source: String? = nil,
        theme: QuoteTheme = .universal
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.source = source
        self.theme = theme
    }

    /// Formatted attribution string
    public var attribution: String {
        if let source = source {
            return "- \(author), \(source)"
        }
        return "- \(author)"
    }
}
