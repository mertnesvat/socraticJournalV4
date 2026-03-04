// LearningBit.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Categories for educational breathing content
public enum LearningCategory: String, Codable, Sendable, CaseIterable {
    case science = "The Science"
    case nasal = "Nasal Breathing"
    case ancient = "Ancient Wisdom"
}

/// A bite-sized educational fact about breathing science
public struct LearningBit: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let body: String
    public let category: LearningCategory
    public let sourceNote: String?

    public init(id: String, title: String, body: String, category: LearningCategory, sourceNote: String? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.category = category
        self.sourceNote = sourceNote
    }
}
