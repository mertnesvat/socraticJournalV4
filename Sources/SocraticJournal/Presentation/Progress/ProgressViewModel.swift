// ProgressViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// View model for the Progress tab
@Observable
@MainActor
public final class ProgressViewModel {

    // MARK: - State

    public var totalMinutes: Int = 0
    public var sessionsThisWeek: Int = 0
    public var currentStreak: Int = 0
    public var longestStreak: Int = 0
    public var sessions: [BreathSession] = []
    public var practiceDates: Set<Date> = []
    public var displayedMonth: Date = Date()
    public var isLoading: Bool = false

    // MARK: - Dependencies

    private let sessionRepository: SessionRepositoryProtocol
    private let streakCalculator = StreakCalculator()
    private let calendar = Calendar.current

    // MARK: - Init

    public init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    // MARK: - Loading

    public func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allSessions = try await sessionRepository.getAllSessions()
            sessions = allSessions

            // Stats
            totalMinutes = streakCalculator.totalMinutes(from: allSessions)

            let weeklyProgress = streakCalculator.calculateWeeklyProgress(
                from: allSessions, goalMinutes: 0
            )
            sessionsThisWeek = weeklyProgress.sessionsThisWeek

            let streakInfo = streakCalculator.calculateStreak(from: allSessions)
            currentStreak = streakInfo.currentStreak
            longestStreak = streakInfo.longestStreak

            // Build set of practice dates for calendar
            practiceDates = Set(allSessions.map { calendar.startOfDay(for: $0.startTime) })
        } catch {
            // Keep existing state
        }
    }

    // MARK: - Calendar Navigation

    public func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    public func nextMonth() {
        let today = Date()
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth),
           newMonth <= today {
            displayedMonth = newMonth
        }
    }

    public var canGoForward: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else {
            return false
        }
        return nextMonth <= Date()
    }

    public var displayedMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    // MARK: - Session Grouping

    /// Sessions grouped by date, most recent first
    public var groupedSessions: [(date: Date, sessions: [BreathSession])] {
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, sessions: $0.value) }
    }

    /// Format a date for section headers (e.g. "Tuesday, Mar 3")
    public func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
#endif
