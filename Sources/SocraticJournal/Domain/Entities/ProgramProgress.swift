// ProgramProgress.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Tracks a user's progress through a guided program
public struct ProgramProgress: Codable, Sendable {
    public let programId: String
    public var startDate: Date
    public var completedDays: Set<Int> // 1-indexed day numbers
    public var totalDays: Int

    public var currentDay: Int {
        let daysSinceStart = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: startDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0
        return min(daysSinceStart + 1, totalDays)
    }

    public var isComplete: Bool {
        completedDays.count >= totalDays
    }

    public init(programId: String, startDate: Date, totalDays: Int) {
        self.programId = programId
        self.startDate = startDate
        self.completedDays = []
        self.totalDays = totalDays
    }
}
