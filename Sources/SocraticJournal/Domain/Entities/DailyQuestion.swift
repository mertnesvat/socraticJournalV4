// DailyQuestion.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Category/level of a daily question, from light to provocative
public enum QuestionCategory: String, Codable, Sendable, CaseIterable {
    case iceBreaker = "ice_breaker"
    case gettingSpicy = "getting_spicy"
    case deepDive = "deep_dive"
    case debateTrigger = "debate_trigger"

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .iceBreaker: return "Ice Breaker"
        case .gettingSpicy: return "Getting Spicy"
        case .deepDive: return "Deep Dive"
        case .debateTrigger: return "Debate Trigger"
        }
    }

    /// Difficulty/intensity level (1-4)
    public var level: Int {
        switch self {
        case .iceBreaker: return 1
        case .gettingSpicy: return 2
        case .deepDive: return 3
        case .debateTrigger: return 4
        }
    }
}

/// A daily question posed to users for voice-based responses
public struct DailyQuestion: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let text: String
    public let category: QuestionCategory
    public let level: Int
    public var isActive: Bool
    public let createdAt: Date
    public var globalResponseCount: Int
    public var disagreementRatio: Double

    public init(
        id: String,
        text: String,
        category: QuestionCategory,
        level: Int,
        isActive: Bool = true,
        createdAt: Date,
        globalResponseCount: Int = 0,
        disagreementRatio: Double = 0.0
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.level = level
        self.isActive = isActive
        self.createdAt = createdAt
        self.globalResponseCount = globalResponseCount
        self.disagreementRatio = disagreementRatio
    }
}
