// StatisticsViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// Milestone types that can be achieved
public enum MilestoneType: String, CaseIterable, Codable, Sendable {
    case firstEntry = "First Entry"
    case streak3 = "3-Day Streak"
    case streak7 = "Week Warrior"
    case streak14 = "Fortnight Force"
    case streak30 = "Monthly Master"
    case entries10 = "10 Entries"
    case entries25 = "25 Entries"
    case entries50 = "50 Entries"
    case entries100 = "Century Club"

    var icon: String {
        switch self {
        case .firstEntry: return "star.fill"
        case .streak3: return "flame"
        case .streak7: return "flame.fill"
        case .streak14: return "bolt.fill"
        case .streak30: return "crown.fill"
        case .entries10: return "book.closed"
        case .entries25: return "book.closed.fill"
        case .entries50: return "books.vertical"
        case .entries100: return "books.vertical.fill"
        }
    }

    var description: String {
        switch self {
        case .firstEntry: return "Began your journey"
        case .streak3: return "3 consecutive days"
        case .streak7: return "7 consecutive days"
        case .streak14: return "14 consecutive days"
        case .streak30: return "30 consecutive days"
        case .entries10: return "Completed 10 entries"
        case .entries25: return "Completed 25 entries"
        case .entries50: return "Completed 50 entries"
        case .entries100: return "Completed 100 entries"
        }
    }

    var threshold: Int {
        switch self {
        case .firstEntry: return 1
        case .streak3: return 3
        case .streak7: return 7
        case .streak14: return 14
        case .streak30: return 30
        case .entries10: return 10
        case .entries25: return 25
        case .entries50: return 50
        case .entries100: return 100
        }
    }

    var isStreakMilestone: Bool {
        switch self {
        case .streak3, .streak7, .streak14, .streak30: return true
        default: return false
        }
    }
}

/// Represents a milestone achievement
public struct Milestone: Identifiable, Sendable {
    public let id: String
    public let type: MilestoneType
    public let isUnlocked: Bool
    public let progress: Double // 0.0 to 1.0

    public init(type: MilestoneType, isUnlocked: Bool, progress: Double) {
        self.id = type.rawValue
        self.type = type
        self.isUnlocked = isUnlocked
        self.progress = min(max(progress, 0), 1)
    }
}

/// Weekly trend data point
public struct TrendDataPoint: Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let score: Double
    public let sessionCount: Int

    public init(date: Date, score: Double, sessionCount: Int) {
        self.id = JournalStats.dateKey(for: date)
        self.date = date
        self.score = score
        self.sessionCount = sessionCount
    }
}

/// ViewModel for the Statistics screen
@Observable
@MainActor
public final class StatisticsViewModel {
    // MARK: - State

    private(set) var stats: JournalStats = .empty
    private(set) var sessions: [JournalSession] = []
    private(set) var milestones: [Milestone] = []
    private(set) var trendData: [TrendDataPoint] = []
    private(set) var lastWeekData: [TrendDataPoint] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    // Computed stats
    var averageScore: Double {
        let scores = sessions.compactMap { $0.clarityScore?.total }
        guard !scores.isEmpty else { return 0 }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }

    var thisWeekAverageScore: Double {
        guard !trendData.isEmpty else { return 0 }
        let scores = trendData.filter { $0.score > 0 }.map { $0.score }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / Double(scores.count)
    }

    var lastWeekAverageScore: Double {
        guard !lastWeekData.isEmpty else { return 0 }
        let scores = lastWeekData.filter { $0.score > 0 }.map { $0.score }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / Double(scores.count)
    }

    var thisWeekSessionCount: Int {
        trendData.reduce(0) { $0 + $1.sessionCount }
    }

    var lastWeekSessionCount: Int {
        lastWeekData.reduce(0) { $0 + $1.sessionCount }
    }

    var weekOverWeekChange: Double {
        guard lastWeekSessionCount > 0 else { return 0 }
        let change = Double(thisWeekSessionCount - lastWeekSessionCount) / Double(lastWeekSessionCount) * 100
        return change
    }

    var streakProgress: Double {
        let target = nextStreakMilestone
        guard target > 0 else { return 1.0 }
        return Double(stats.currentStreak) / Double(target)
    }

    var nextStreakMilestone: Int {
        let streakMilestones = [3, 7, 14, 30]
        for milestone in streakMilestones {
            if stats.currentStreak < milestone {
                return milestone
            }
        }
        return 30
    }

    var daysUntilNextMilestone: Int {
        max(0, nextStreakMilestone - stats.currentStreak)
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    public init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    public func loadData() async {
        isLoading = true
        error = nil

        do {
            async let sessionsTask = repository.getAllSessions()
            async let statsTask = repository.getStats()

            sessions = try await sessionsTask
            stats = try await statsTask

            calculateMilestones()
            calculateTrendData()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Private Helpers

    private func calculateMilestones() {
        let totalEntries = stats.totalEntries
        let longestStreak = stats.longestStreak

        milestones = MilestoneType.allCases.map { type in
            let (isUnlocked, progress) = calculateMilestoneProgress(type: type, totalEntries: totalEntries, longestStreak: longestStreak)
            return Milestone(type: type, isUnlocked: isUnlocked, progress: progress)
        }
    }

    private func calculateMilestoneProgress(type: MilestoneType, totalEntries: Int, longestStreak: Int) -> (Bool, Double) {
        let threshold = type.threshold

        if type.isStreakMilestone {
            let isUnlocked = longestStreak >= threshold
            let progress = Double(min(longestStreak, threshold)) / Double(threshold)
            return (isUnlocked, progress)
        } else {
            let isUnlocked = totalEntries >= threshold
            let progress = Double(min(totalEntries, threshold)) / Double(threshold)
            return (isUnlocked, progress)
        }
    }

    private func calculateTrendData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get this week's data (last 7 days including today)
        var thisWeekPoints: [TrendDataPoint] = []
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let key = JournalStats.dateKey(for: date)
            let sessionCount = stats.sessionCountByDate[key] ?? 0
            let score = stats.averageScoreByDate[key] ?? 0
            thisWeekPoints.append(TrendDataPoint(date: date, score: score, sessionCount: sessionCount))
        }
        trendData = thisWeekPoints

        // Get last week's data (7-13 days ago)
        var lastWeekPoints: [TrendDataPoint] = []
        for dayOffset in (7..<14).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let key = JournalStats.dateKey(for: date)
            let sessionCount = stats.sessionCountByDate[key] ?? 0
            let score = stats.averageScoreByDate[key] ?? 0
            lastWeekPoints.append(TrendDataPoint(date: date, score: score, sessionCount: sessionCount))
        }
        lastWeekData = lastWeekPoints
    }
}
#endif
