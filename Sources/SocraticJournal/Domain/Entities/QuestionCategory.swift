// QuestionCategory.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Category of a daily question indicating its depth and tone
public enum QuestionCategory: String, Codable, Sendable, Hashable, CaseIterable {
    case iceBreaker
    case gettingSpicy
    case deep
    case debateTrigger

    /// Human-readable display name for the category
    public var displayName: String {
        switch self {
        case .iceBreaker: return "Ice Breaker"
        case .gettingSpicy: return "Getting Spicy"
        case .deep: return "Deep"
        case .debateTrigger: return "Debate Trigger"
        }
    }

    /// Color hint for UI theming
    public var colorHint: String {
        switch self {
        case .iceBreaker: return "blue"
        case .gettingSpicy: return "orange"
        case .deep: return "purple"
        case .debateTrigger: return "red"
        }
    }
}
