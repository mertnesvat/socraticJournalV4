// DailyQuestion.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a daily question presented to all users
public struct DailyQuestion: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    public let text: String
    public let category: QuestionCategory
    public let level: QuestionLevel
    public let createdAt: Date
    public let isActive: Bool

    public init(
        id: String = UUID().uuidString,
        text: String,
        category: QuestionCategory,
        level: QuestionLevel,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.level = level
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
