// ProgressViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Progress tab showing stats, calendar, and session history
@Observable
@MainActor
public final class ProgressViewModel {
    // MARK: - State

    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var totalMinutes: Double = 0
    private(set) var totalSessions: Int = 0
    private(set) var streak: Int = 0
    private(set) var allSessions: [BreathSession] = []

    // MARK: - Computed

    /// Sessions grouped by calendar day (start of day), sorted reverse chronological
    var sessionsByDate: [(date: Date, sessions: [BreathSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allSessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, sessions: $0.value.sorted { $0.startedAt > $1.startedAt }) }
    }

    /// Sessions in the current month mapped by day for the calendar view
    var currentMonthSessionsByDay: [Date: [BreathSession]] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else {
            return [:]
        }

        let monthSessions = allSessions.filter { session in
            session.startedAt >= monthInterval.start && session.startedAt < monthInterval.end
        }

        return Dictionary(grouping: monthSessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }
    }

    var hasData: Bool {
        !allSessions.isEmpty
    }

    /// Formatted total minutes for display (whole number)
    var formattedTotalMinutes: String {
        "\(Int(totalMinutes))"
    }

    // MARK: - Dependencies

    private let repository: BreathSessionRepositoryProtocol

    // MARK: - Init

    public init(repository: BreathSessionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    public func loadData() async {
        isLoading = true
        error = nil

        do {
            totalMinutes = try await repository.getTotalMinutesBreathed()
            totalSessions = try await repository.getTotalSessions()
            streak = try await repository.getCurrentStreak()
            allSessions = try await repository.getAllSessions()
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
#endif
