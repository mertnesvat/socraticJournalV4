// TodayDashboardViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Today dashboard — loads daily sessions, streak, and goal
@Observable
@MainActor
final class TodayDashboardViewModel {
    private let breathSessionRepository: BreathSessionRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    private(set) var todaySessions: [BreathSession] = []
    private(set) var totalMinutesToday: Double = 0
    private(set) var streak: Int = 0
    private(set) var dailyGoalMinutes: Int = 5

    var sessionsCount: Int { todaySessions.count }
    var goalProgress: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(totalMinutesToday / Double(dailyGoalMinutes), 1.0)
    }

    init(
        breathSessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.breathSessionRepository = breathSessionRepository
        self.settingsRepository = settingsRepository
    }

    func load() async {
        do {
            let today = Calendar.current.startOfDay(for: Date())
            todaySessions = try await breathSessionRepository.getSessionsForDate(today)
                .sorted { $0.startedAt > $1.startedAt }
            totalMinutesToday = try await breathSessionRepository.getTotalMinutesToday()
            streak = try await breathSessionRepository.getStreak()

            let settings = try await settingsRepository.getSettings()
            dailyGoalMinutes = settings.dailyGoalMinutes
        } catch {
            // Silently handle — show empty state
        }
    }

    func techniqueName(for session: BreathSession) -> String {
        BreathTechnique.allTechniques.first { $0.id == session.techniqueId }?.name ?? "Session"
    }
}
#endif
