// ProgramDetailViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the program detail screen
@Observable
@MainActor
public final class ProgramDetailViewModel {
    // MARK: - State

    let program: BreathProgram
    private(set) var progress: ProgramProgress?
    private(set) var isLoading = false
    var showAbandonConfirmation = false
    var error: String?

    /// Whether this program is the currently active one
    var isActiveProgram: Bool {
        progress?.programId == program.id && !(progress?.isComplete ?? true)
    }

    /// Whether any different program is active
    var hasDifferentActiveProgram: Bool {
        guard let progress = progress else { return false }
        return progress.programId != program.id && !progress.isComplete
    }

    // MARK: - Dependencies

    private let progressRepository: ProgramProgressRepositoryProtocol

    // MARK: - Init

    public init(
        program: BreathProgram,
        progressRepository: ProgramProgressRepositoryProtocol
    ) {
        self.program = program
        self.progressRepository = progressRepository
    }

    // MARK: - Actions

    func loadData() async {
        isLoading = true
        do {
            progress = try await progressRepository.getActiveProgram()
        } catch {
            self.error = "Could not load progress"
        }
        isLoading = false
    }

    func startProgram() async {
        do {
            try await progressRepository.startProgram(program.id, totalDays: program.totalDays)
            progress = try await progressRepository.getActiveProgram()
        } catch {
            self.error = "Could not start program"
        }
    }

    func abandonProgram() async {
        do {
            try await progressRepository.abandonProgram()
            progress = nil
        } catch {
            self.error = "Could not abandon program"
        }
    }

    func isDayCompleted(_ day: Int) -> Bool {
        guard isActiveProgram else { return false }
        return progress?.isDayCompleted(day) ?? false
    }

    func isCurrentDay(_ day: Int) -> Bool {
        guard isActiveProgram else { return false }
        return progress?.currentDay == day
    }
}
#endif
