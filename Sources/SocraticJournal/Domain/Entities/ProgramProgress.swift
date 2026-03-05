// ProgramProgress.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Tracks user progress through a breath program
public struct ProgramProgress: Codable, Sendable, Equatable {
    public let programId: String
    public var currentDay: Int // 1-based, the next day to complete
    public var completedDays: [Int] // Days already completed
    public let totalDays: Int
    public var startedAt: Date
    public var lastPracticedAt: Date?

    /// Whether the entire program has been completed
    public var isComplete: Bool { currentDay > totalDays }

    /// Fraction of days completed (0.0 to 1.0)
    public var progressFraction: Double {
        guard totalDays > 0 else { return 0 }
        return Double(completedDays.count) / Double(totalDays)
    }

    /// Whether a specific day has been completed
    public func isDayCompleted(_ day: Int) -> Bool {
        completedDays.contains(day)
    }

    public init(
        programId: String,
        currentDay: Int = 1,
        completedDays: [Int] = [],
        totalDays: Int,
        startedAt: Date = Date(),
        lastPracticedAt: Date? = nil
    ) {
        self.programId = programId
        self.currentDay = currentDay
        self.completedDays = completedDays
        self.totalDays = totalDays
        self.startedAt = startedAt
        self.lastPracticedAt = lastPracticedAt
    }
}
