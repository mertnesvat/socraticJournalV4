// TodayViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// View model for the Today tab dashboard
@Observable
@MainActor
public final class TodayViewModel {

    // MARK: - Published State

    public var streakInfo: StreakCalculator.StreakInfo = .init(
        currentStreak: 0, longestStreak: 0, isAtRisk: false, lastSessionDate: nil
    )
    public var weeklyProgress: StreakCalculator.WeeklyProgress = .init(
        minutesCompleted: 0, goalMinutes: 35, sessionsThisWeek: 0
    )
    public var todaySession: BreathSession?
    public var totalMinutes: Int = 0
    public var tipOfTheDay: BreathFacts.Fact = BreathFacts.tipOfTheDay()
    public var reminderEnabled: Bool = false
    public var reminderTimeFormatted: String = ""
    public var isFirstTime: Bool = true
    public var isLoading: Bool = false

    // MARK: - Dependencies

    private let sessionRepository: SessionRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let streakCalculator = StreakCalculator()

    // MARK: - Init

    public init(
        sessionRepository: SessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.settingsRepository = settingsRepository
    }

    // MARK: - Data Loading

    /// Load all dashboard data from repositories
    public func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load sessions
            let allSessions = try await sessionRepository.getAllSessions()

            // Calculate streak
            streakInfo = streakCalculator.calculateStreak(from: allSessions)

            // Calculate weekly progress
            weeklyProgress = streakCalculator.calculateWeeklyProgress(
                from: allSessions, goalMinutes: 35
            )

            // Total minutes
            totalMinutes = streakCalculator.totalMinutes(from: allSessions)

            // Today's most recent session
            let todaySessions = try await sessionRepository.getTodaySessions()
            todaySession = todaySessions.first

            // First time check (no sessions ever)
            let sessionCount = try await sessionRepository.getSessionCount()
            isFirstTime = sessionCount == 0

            // Tip of the day (deterministic)
            tipOfTheDay = BreathFacts.tipOfTheDay()

        } catch {
            // On error, keep existing state -- dashboard should never show error UI
        }

        // Load settings for reminder status
        do {
            let settings = try await settingsRepository.getSettings()
            reminderEnabled = settings.dailyReminderEnabled
            if settings.dailyReminderEnabled {
                reminderTimeFormatted = settings.formattedReminderTime
            }
        } catch {
            // Keep defaults
        }
    }

    // MARK: - Computed

    /// Whether the user has completed at least one session today
    public var hasSessionToday: Bool {
        todaySession != nil
    }

    /// CTA button text
    public var ctaButtonText: String {
        hasSessionToday ? "Breathe Again" : "Start Breathing"
    }

    /// Streak ring progress (capped at 1.0 for display, based on 7-day target)
    public var streakRingProgress: Double {
        guard streakInfo.currentStreak > 0 else { return 0 }
        return min(Double(streakInfo.currentStreak) / 7.0, 1.0)
    }
}
#endif
