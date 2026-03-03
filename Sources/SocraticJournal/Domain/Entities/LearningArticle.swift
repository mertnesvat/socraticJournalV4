// LearningArticle.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Category for learning content
public enum LearningCategory: String, Codable, Sendable, CaseIterable {
    case science
    case practice
    case anatomy

    public var displayName: String {
        switch self {
        case .science: return "Science"
        case .practice: return "Practice"
        case .anatomy: return "Anatomy"
        }
    }
}

/// Educational content piece
public struct LearningArticle: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let body: String
    public let category: LearningCategory
    public let keyTakeaway: String
    public let sourceNote: String
    public let readTimeMinutes: Int

    public init(
        id: String,
        title: String,
        summary: String,
        body: String,
        category: LearningCategory,
        keyTakeaway: String,
        sourceNote: String,
        readTimeMinutes: Int
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.body = body
        self.category = category
        self.keyTakeaway = keyTakeaway
        self.sourceNote = sourceNote
        self.readTimeMinutes = readTimeMinutes
    }
}
