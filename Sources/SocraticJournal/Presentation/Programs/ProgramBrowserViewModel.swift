// ProgramBrowserViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the program browser screen
@Observable
@MainActor
public final class ProgramBrowserViewModel {
    // MARK: - State

    private(set) var programs: [BreathProgram] = []
    private(set) var activeProgress: ProgramProgress?
    private(set) var isLoading = false

    // MARK: - Dependencies

    private let progressRepository: ProgramProgressRepositoryProtocol

    // MARK: - Init

    public init(progressRepository: ProgramProgressRepositoryProtocol) {
        self.progressRepository = progressRepository
    }

    // MARK: - Actions

    func loadData() async {
        isLoading = true
        programs = BreathProgram.allPrograms
        do {
            activeProgress = try await progressRepository.getActiveProgram()
        } catch {
            // Degrade gracefully
        }
        isLoading = false
    }

    func isActiveProgram(_ programId: String) -> Bool {
        activeProgress?.programId == programId
    }
}
#endif
