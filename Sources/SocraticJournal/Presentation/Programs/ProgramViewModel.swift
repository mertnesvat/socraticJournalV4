// ProgramViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for program detail and progress tracking
@Observable
@MainActor
public final class ProgramViewModel {
    // MARK: - State

    let program: Program
    private(set) var progress: ProgramProgress?
    private(set) var expandedDay: Int?

    var currentDay: Int { progress?.currentDay ?? 1 }
    var isStarted: Bool { progress != nil }

    // MARK: - Persistence

    private static let progressKey = "com.breathe.programs"
    private let defaults: UserDefaults

    // MARK: - Init

    public init(program: Program, defaults: UserDefaults = .standard) {
        self.program = program
        self.defaults = defaults
    }

    // MARK: - Actions

    func loadProgress() {
        let allProgress = loadAllProgress()
        progress = allProgress[program.id]
        // Expand the current day by default
        if let progress {
            expandedDay = progress.currentDay
        }
    }

    func startProgram() {
        let newProgress = ProgramProgress(
            programId: program.id,
            startDate: Date(),
            totalDays: program.totalDays
        )
        progress = newProgress
        expandedDay = 1
        saveProgress(newProgress)
    }

    func toggleDay(_ dayNumber: Int) {
        if expandedDay == dayNumber {
            expandedDay = nil
        } else {
            // Only expand current or past days
            guard let progress, dayNumber <= progress.currentDay else { return }
            expandedDay = dayNumber
        }
    }

    func markDayComplete(_ dayNumber: Int) {
        guard var prog = progress else { return }
        prog.completedDays.insert(dayNumber)
        progress = prog
        saveProgress(prog)
    }

    func isDayCompleted(_ dayNumber: Int) -> Bool {
        progress?.completedDays.contains(dayNumber) ?? false
    }

    func isDayCurrent(_ dayNumber: Int) -> Bool {
        guard let progress else { return dayNumber == 1 }
        return dayNumber == progress.currentDay && !isDayCompleted(dayNumber)
    }

    func isDayLocked(_ dayNumber: Int) -> Bool {
        guard let progress else { return dayNumber > 1 }
        return dayNumber > progress.currentDay
    }

    func prescriptionSummary(for day: ProgramDay) -> String {
        day.prescriptions.map { prescription in
            let name = BreathPattern.allPatterns.first { $0.id == prescription.patternId }?.name ?? prescription.patternId
            return "\(name) \u{00b7} \(prescription.durationMinutes) min"
        }.joined(separator: " + ")
    }

    func patternName(for patternId: String) -> String {
        BreathPattern.allPatterns.first { $0.id == patternId }?.name ?? patternId
    }

    // MARK: - Persistence Helpers

    private func loadAllProgress() -> [String: ProgramProgress] {
        guard let data = defaults.data(forKey: Self.progressKey) else { return [:] }
        return (try? JSONDecoder().decode([String: ProgramProgress].self, from: data)) ?? [:]
    }

    private func saveProgress(_ prog: ProgramProgress) {
        var all = loadAllProgress()
        all[prog.programId] = prog
        if let data = try? JSONEncoder().encode(all) {
            defaults.set(data, forKey: Self.progressKey)
        }
    }

    // MARK: - Static Helpers

    static func progressFor(programId: String, defaults: UserDefaults = .standard) -> ProgramProgress? {
        guard let data = defaults.data(forKey: progressKey) else { return nil }
        let all = (try? JSONDecoder().decode([String: ProgramProgress].self, from: data)) ?? [:]
        return all[programId]
    }
}
#endif
