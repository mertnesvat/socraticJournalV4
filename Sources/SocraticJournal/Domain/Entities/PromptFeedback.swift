// PromptFeedback.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// Rating a user can give to a daily prompt.
public enum PromptRating: String, Codable, Sendable {
    case thumbsUp
    case thumbsDown
}

/// Stores user feedback on a prompt for a circle.
/// Used to influence future prompt category weighting.
@Model
public final class PromptFeedback {
    @Attribute(.unique) public var id: UUID
    /// The prompt this feedback is for.
    public var promptId: UUID
    /// The circle context for this feedback.
    public var circleId: UUID
    /// The user's rating of the prompt.
    public var ratingRaw: String
    /// When the feedback was given.
    public var createdAt: Date
    /// The category of the prompt at the time of feedback (denormalized for fast queries).
    public var categoryRaw: String

    /// Typed rating accessor backed by the raw string.
    public var rating: PromptRating {
        get { PromptRating(rawValue: ratingRaw) ?? .thumbsUp }
        set { ratingRaw = newValue.rawValue }
    }

    /// Typed category accessor backed by the raw string.
    public var category: PromptCategory {
        get { PromptCategory(rawValue: categoryRaw) ?? .dailyMoments }
        set { categoryRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        promptId: UUID,
        circleId: UUID,
        rating: PromptRating,
        category: PromptCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.promptId = promptId
        self.circleId = circleId
        self.ratingRaw = rating.rawValue
        self.categoryRaw = category.rawValue
        self.createdAt = createdAt
    }
}
