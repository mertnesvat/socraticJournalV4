// JournalStats.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Statistics for the user's journaling activity
public struct JournalStats: Codable, Sendable, Equatable {
    public let totalEntries: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let thisWeekEntries: Int
    public let sessionCountByDate: [String: Int]
    public let averageScoreByDate: [String: Double]

    public init(
        totalEntries: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        thisWeekEntries: Int = 0,
        sessionCountByDate: [String: Int] = [:],
        averageScoreByDate: [String: Double] = [:]
    ) {
        self.totalEntries = totalEntries
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.thisWeekEntries = thisWeekEntries
        self.sessionCountByDate = sessionCountByDate
        self.averageScoreByDate = averageScoreByDate
    }

    /// Returns session count for a specific date
    public func sessionCount(for date: Date) -> Int {
        let key = Self.dateKey(for: date)
        return sessionCountByDate[key] ?? 0
    }

    /// Returns average clarity score for a specific date
    public func averageScore(for date: Date) -> Double? {
        let key = Self.dateKey(for: date)
        return averageScoreByDate[key]
    }

    /// Creates a date key string for dictionary lookups
    public static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// Empty stats instance
    public static let empty = JournalStats()
}
