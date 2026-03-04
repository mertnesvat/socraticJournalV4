// TodayDashboardViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Today dashboard tab
@Observable
@MainActor
public final class TodayDashboardViewModel {
    // MARK: - State

    private(set) var todaysSessions: [BreathSession] = []
    private(set) var totalMinutesToday: Double = 0
    private(set) var dailyGoalMinutes: Int = 5
    private(set) var streak: Int = 0
    private(set) var tipOfTheDay: LearningBit?
    private(set) var isLoading: Bool = false
    private(set) var reminderTime: String?

    /// Progress toward daily goal (0.0 to 1.0)
    var dailyProgress: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(totalMinutesToday / Double(dailyGoalMinutes), 1.0)
    }

    var goalReached: Bool { dailyProgress >= 1.0 }

    // MARK: - Dependencies

    private let sessionRepository: BreathSessionRepositoryProtocol
    private let contentService: BreathContentServiceProtocol
    let settingsRepository: SettingsRepositoryProtocol

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        contentService: BreathContentServiceProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.contentService = contentService
        self.settingsRepository = settingsRepository
    }

    // MARK: - Actions

    public func loadData() async {
        isLoading = true

        do {
            todaysSessions = try await sessionRepository.getSessionsForDate(Date())
            totalMinutesToday = try await sessionRepository.getTotalMinutesToday()
            streak = try await sessionRepository.getStreak()

            let settings = try await settingsRepository.getSettings()
            dailyGoalMinutes = settings.dailyGoalMinutes

            if settings.breathReminderEnabled {
                reminderTime = settings.formattedReminderTime
            } else {
                reminderTime = nil
            }
        } catch {
            // Fail silently with empty data
        }

        // Pick tip of the day based on day-of-year for consistency
        let allBits = contentService.getAllLearningBits()
        if !allBits.isEmpty {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
            tipOfTheDay = allBits[dayOfYear % allBits.count]
        }

        isLoading = false
    }
}
#endif
