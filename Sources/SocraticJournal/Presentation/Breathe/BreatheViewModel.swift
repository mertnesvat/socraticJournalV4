// BreatheViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Breathe tab
@Observable
@MainActor
public final class BreatheViewModel {
    // MARK: - State

    var selectedPattern: BreathPattern = .resonance
    var selectedDuration: SessionDuration = .five
    private(set) var sessionStartedAt: Date?
    private(set) var previousDailyTotal: Double = 0
    private(set) var dailyGoalMinutes: Int = 5
    private(set) var lastCompletedSession: BreathSession?

    let engine = BreathPacingEngine()
    let hapticEngine = HapticRhythmEngine()

    // MARK: - Dependencies

    private let sessionRepository: BreathSessionRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol?
    private let analyticsService: AnalyticsServiceProtocol?
    private let healthKitService: HealthKitServiceProtocol?

    // MARK: - Init

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        healthKitService: HealthKitServiceProtocol? = nil
    ) {
        self.sessionRepository = sessionRepository
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
        self.healthKitService = healthKitService

        engine.onPhaseTransition = { [hapticEngine] phaseType in
            hapticEngine.firePhaseTransition(phaseType: phaseType)
        }
    }

    func loadSettings() async {
        guard let repo = settingsRepository else { return }
        do {
            let settings = try await repo.getSettings()
            hapticEngine.setEnabled(settings.hapticRhythmEnabled)
            dailyGoalMinutes = settings.dailyGoalMinutes
        } catch {}
    }

    // MARK: - Duration Options

    enum SessionDuration: Int, CaseIterable {
        case five = 5
        case ten = 10
        case twenty = 20

        var label: String { "\(rawValue) min" }
        var seconds: TimeInterval { TimeInterval(rawValue * 60) }
    }

    // MARK: - Actions

    func preSelectForProgram(patternId: String, durationMinutes: Int) {
        guard !engine.isRunning else { return }
        if let pattern = BreathPattern.allPatterns.first(where: { $0.id == patternId }) {
            selectedPattern = pattern
        }
        if let duration = SessionDuration(rawValue: durationMinutes) {
            selectedDuration = duration
        } else {
            // Pick nearest duration
            let sorted = SessionDuration.allCases.sorted { abs($0.rawValue - durationMinutes) < abs($1.rawValue - durationMinutes) }
            selectedDuration = sorted.first ?? .five
        }
    }

    func selectPattern(_ pattern: BreathPattern) {
        guard !engine.isRunning else { return }
        selectedPattern = pattern
        analyticsService?.logEvent(.patternSelected, parameters: [
            "pattern_id": pattern.id,
            "pattern_name": pattern.name,
        ])
    }

    func toggleSession() {
        if engine.isRunning {
            if engine.isPaused {
                engine.resume()
            } else {
                engine.pause()
            }
        } else {
            startSession()
        }
    }

    func stopSession() {
        let duration = engine.totalElapsed
        let cycles = engine.cyclesCompleted
        engine.stop()
        saveSession(duration: duration, cycles: cycles)
    }

    // MARK: - Private

    private func startSession() {
        sessionStartedAt = Date()
        lastCompletedSession = nil
        Task {
            previousDailyTotal = (try? await sessionRepository.getTotalMinutesToday()) ?? 0
        }
        engine.start(pattern: selectedPattern, duration: selectedDuration.seconds)
        analyticsService?.logEvent(.sessionStarted, parameters: [
            "pattern_id": selectedPattern.id,
            "duration_minutes": selectedDuration.rawValue,
        ])
    }

    func handleSessionFinished() {
        let duration = engine.totalElapsed
        let cycles = engine.cyclesCompleted
        saveSession(duration: duration, cycles: cycles)
    }

    private func saveSession(duration: TimeInterval, cycles: Int) {
        guard duration > 5 else { return } // Don't save sessions < 5 seconds
        let session = BreathSession(
            id: UUID().uuidString,
            patternId: selectedPattern.id,
            startedAt: sessionStartedAt ?? Date(),
            completedAt: Date(),
            totalDuration: duration,
            cyclesCompleted: cycles
        )
        if duration >= 30 {
            lastCompletedSession = session
        }
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)
        Task {
            try? await sessionRepository.saveSession(session)
            // Save to HealthKit as Mindful Minutes (silently ignores auth errors)
            try? await healthKitService?.saveMindfulSession(startDate: startDate, endDate: endDate)
        }
        analyticsService?.logEvent(.sessionCompleted, parameters: [
            "pattern_id": selectedPattern.id,
            "duration_seconds": duration,
            "cycles_completed": cycles,
        ])
        sessionStartedAt = nil
    }

    /// Formatted elapsed time
    var elapsedFormatted: String {
        let total = Int(engine.totalElapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Button label
    var actionButtonLabel: String {
        if !engine.isRunning { return "Begin" }
        return engine.isPaused ? "Resume" : "Pause"
    }

    var showStopButton: Bool {
        engine.isRunning
    }
}
#endif
