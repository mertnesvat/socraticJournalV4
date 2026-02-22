// SpicyTakeAward.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Category of a spicy take award given to users with standout opinions
public enum SpicyTakeCategory: String, Codable, Sendable, CaseIterable {
    case mostControversial
    case mostPassionate
    case mostSurprising
}

/// An award given for having a standout voice answer in a given week
public struct SpicyTakeAward: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let questionId: String
    public let userId: String
    public let weekNumber: Int
    public let year: Int
    public let category: SpicyTakeCategory

    public init(
        id: String,
        questionId: String,
        userId: String,
        weekNumber: Int,
        year: Int,
        category: SpicyTakeCategory
    ) {
        self.id = id
        self.questionId = questionId
        self.userId = userId
        self.weekNumber = weekNumber
        self.year = year
        self.category = category
    }
}
