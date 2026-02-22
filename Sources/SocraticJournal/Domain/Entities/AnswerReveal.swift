// AnswerReveal.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents the reveal state between two users' answers for a question
public struct AnswerReveal: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let myAnswerId: String
    public let friendAnswerId: String
    public let questionId: String
    public var isUnlocked: Bool
    public var unlockedAt: Date?

    public init(
        id: String,
        myAnswerId: String,
        friendAnswerId: String,
        questionId: String,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.myAnswerId = myAnswerId
        self.friendAnswerId = friendAnswerId
        self.questionId = questionId
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}
