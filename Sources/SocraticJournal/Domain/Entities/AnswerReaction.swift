// AnswerReaction.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Type of reaction a user can leave on an answer
public enum ReactionType: String, Codable, Sendable, Hashable, CaseIterable {
    case fire
    case mindBlown
    case disagree
    case laugh

    /// Emoji representation of the reaction
    public var emoji: String {
        switch self {
        case .fire: return "🔥"
        case .mindBlown: return "🤯"
        case .disagree: return "👎"
        case .laugh: return "😂"
        }
    }

    /// Human-readable display name for the reaction
    public var displayName: String {
        switch self {
        case .fire: return "Fire"
        case .mindBlown: return "Mind Blown"
        case .disagree: return "Disagree"
        case .laugh: return "Laugh"
        }
    }
}

/// Represents a reaction left on a voice answer
public struct AnswerReaction: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    public let answerId: String
    public let reactorUserId: String
    public let type: ReactionType
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        answerId: String,
        reactorUserId: String,
        type: ReactionType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.answerId = answerId
        self.reactorUserId = reactorUserId
        self.type = type
        self.createdAt = createdAt
    }
}
