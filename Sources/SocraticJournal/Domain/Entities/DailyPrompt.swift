// DailyPrompt.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a daily prompt sent to all members of a circle
public struct DailyPrompt: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let circleId: UUID
    public let promptText: String
    public let generatedAt: Date
    /// IDs of members who have responded with a voice note
    public var respondedUserIds: [UUID]
    /// Which week of the circle's life this prompt was generated in (affects depth tier)
    public let weekNumber: Int

    public init(
        id: UUID = UUID(),
        circleId: UUID,
        promptText: String,
        generatedAt: Date = Date(),
        respondedUserIds: [UUID] = [],
        weekNumber: Int = 1
    ) {
        self.id = id
        self.circleId = circleId
        self.promptText = promptText
        self.generatedAt = generatedAt
        self.respondedUserIds = respondedUserIds
        self.weekNumber = weekNumber
    }

    /// Whether this prompt was generated today
    public var isToday: Bool {
        Calendar.current.isDateInToday(generatedAt)
    }
}
