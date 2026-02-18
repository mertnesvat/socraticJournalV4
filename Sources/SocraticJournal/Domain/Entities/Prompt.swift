// Prompt.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// Category of a daily prompt, representing different types of sharing.
public enum PromptCategory: String, Codable, CaseIterable, Sendable {
    case gratitude
    case reflection
    case vulnerability
    case sharedMemories
    case futureHopes
    case dailyMoments
    case playful
    case nostalgia

    /// Human-readable display name for this category.
    public var displayName: String {
        switch self {
        case .gratitude: return "Gratitude"
        case .reflection: return "Reflection"
        case .vulnerability: return "Vulnerability"
        case .sharedMemories: return "Shared Memories"
        case .futureHopes: return "Future Hopes"
        case .dailyMoments: return "Daily Moments"
        case .playful: return "Playful"
        case .nostalgia: return "Nostalgia"
        }
    }

    /// SF Symbol icon name for this category.
    public var iconName: String {
        switch self {
        case .gratitude: return "heart.fill"
        case .reflection: return "brain.head.profile"
        case .vulnerability: return "hand.raised.fill"
        case .sharedMemories: return "photo.on.rectangle.angled"
        case .futureHopes: return "star.fill"
        case .dailyMoments: return "sun.max.fill"
        case .playful: return "face.smiling.fill"
        case .nostalgia: return "clock.arrow.circlepath"
        }
    }
}

/// A daily prompt that circle members respond to with voice notes.
/// Stored via SwiftData to track which prompts have been assigned and seen.
@Model
public final class Prompt {
    @Attribute(.unique) public var id: UUID
    public var text: String
    public var categoryRaw: String
    public var depth: Int
    public var dateAssigned: Date?
    public var circleId: UUID?
    public var isSeen: Bool

    /// Typed category accessor backed by the raw string.
    public var category: PromptCategory {
        get { PromptCategory(rawValue: categoryRaw) ?? .dailyMoments }
        set { categoryRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        text: String,
        category: PromptCategory,
        depth: Int = 1,
        dateAssigned: Date? = nil,
        circleId: UUID? = nil,
        isSeen: Bool = false
    ) {
        self.id = id
        self.text = text
        self.categoryRaw = category.rawValue
        self.depth = depth
        self.dateAssigned = dateAssigned
        self.circleId = circleId
        self.isSeen = isSeen
    }
}
