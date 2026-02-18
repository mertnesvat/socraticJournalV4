// DailyPrompt.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents a daily prompt question delivered to a circle
public struct DailyPrompt: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let circleId: String
    public let question: String
    public let category: PromptCategory
    public let generatedAt: Date
    public var responseCount: Int

    public init(
        id: String = UUID().uuidString,
        circleId: String,
        question: String,
        category: PromptCategory = .reflective,
        generatedAt: Date = Date(),
        responseCount: Int = 0
    ) {
        self.id = id
        self.circleId = circleId
        self.question = question
        self.category = category
        self.generatedAt = generatedAt
        self.responseCount = responseCount
    }

    /// Whether this prompt is from today
    public var isToday: Bool {
        Calendar.current.isDateInToday(generatedAt)
    }
}

/// Categories of daily prompts
public enum PromptCategory: String, Codable, Sendable, Equatable, CaseIterable {
    case reflective
    case playful
    case vulnerable
    case nostalgic
    case aspirational
    case gratitude
    case icebreaker

    public var displayName: String {
        switch self {
        case .reflective: return "Reflective"
        case .playful: return "Playful"
        case .vulnerable: return "Vulnerable"
        case .nostalgic: return "Nostalgic"
        case .aspirational: return "Aspirational"
        case .gratitude: return "Gratitude"
        case .icebreaker: return "Icebreaker"
        }
    }

    public var emoji: String {
        switch self {
        case .reflective: return "🪞"
        case .playful: return "🎲"
        case .vulnerable: return "💛"
        case .nostalgic: return "📷"
        case .aspirational: return "🚀"
        case .gratitude: return "🙏"
        case .icebreaker: return "👋"
        }
    }
}
