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

    let engine = BreathPacingEngine()
    let hapticEngine = HapticRhythmEngine()

    // MARK: - Dependencies

    private let sessionRepository: BreathSessionRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol?
    private let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Init

    public init(
        sessionRepository: BreathSessionRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.sessionRepository = sessionRepository
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService

        engine.onPhaseTransition = { [hapticEngine] phaseType in
            hapticEngine.firePhaseTransition(phaseType: phaseType)
        }
    }

    func loadSettings() async {
        guard let repo = settingsRepository else { return }
        do {
            let settings = try await repo.getSettings()
            hapticEngine.setEnabled(settings.hapticRhythmEnabled)
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
        Task {
            try? await sessionRepository.saveSession(session)
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
