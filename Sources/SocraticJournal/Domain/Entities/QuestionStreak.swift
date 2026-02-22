// QuestionStreak.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Tracks a user's consecutive daily question-answering streak
public struct QuestionStreak: Codable, Sendable, Equatable {
    public let userId: String
    public var currentStreak: Int
    public var longestStreak: Int
    public var lastAnsweredDate: Date?

    public init(
        userId: String,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastAnsweredDate: Date? = nil
    ) {
        self.userId = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastAnsweredDate = lastAnsweredDate
    }
}
