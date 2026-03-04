// TodayDashboardViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Today Dashboard tab
@Observable
@MainActor
public final class TodayDashboardViewModel {
    // MARK: - State

    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var streak: Int = 0
    private(set) var todayMinutes: Double = 0
    private(set) var dailyGoalMinutes: Int = 5
    private(set) var todaySessions: [BreathSession] = []
    private(set) var lastUsedTechnique: BreathTechnique?

    // MARK: - Computed

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "good morning"
        } else if hour < 17 {
            return "good afternoon"
        } else {
            return "good evening"
        }
    }

    var quickStartTechnique: BreathTechnique {
        lastUsedTechnique ?? .resonance
    }

    var hasTodaySessions: Bool {
        !todaySessions.isEmpty
    }

    // MARK: - Dependencies

    private let sessionRepository: BreathSessionRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    // MARK: - Init

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.settingsRepository = settingsRepository
    }

    // MARK: - Actions

    public func loadData() async {
        isLoading = true
        error = nil

        do {
            // Load settings for daily goal and last used technique
            let settings = try await settingsRepository.getSettings()
            dailyGoalMinutes = settings.dailyGoalMinutes

            // Resolve last used technique
            let techniqueId = settings.lastUsedTechniqueId ?? settings.defaultTechniqueId
            lastUsedTechnique = BreathTechnique.allTechniques.first { $0.id == techniqueId }

            // Load streak
            streak = try await sessionRepository.getCurrentStreak()

            // Load today's sessions
            todaySessions = try await sessionRepository.getSessions(for: Date())

            // Calculate today's minutes from sessions
            todayMinutes = todaySessions.reduce(0.0) { $0 + $1.actualDuration } / 60.0
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
#endif
