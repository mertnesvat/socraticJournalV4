// AnswerStreak.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Tracks a user's daily answer streak
public struct AnswerStreak: Codable, Sendable, Identifiable, Hashable {
    public let userId: String
    public var currentStreak: Int
    public var longestStreak: Int
    public var lastAnswerDate: Date?
    public var streakStartDate: Date?

    /// Uses userId as the stable identifier
    public var id: String { userId }

    public init(
        userId: String,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastAnswerDate: Date? = nil,
        streakStartDate: Date? = nil
    ) {
        self.userId = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastAnswerDate = lastAnswerDate
        self.streakStartDate = streakStartDate
    }
}
