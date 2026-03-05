// ProgramBrowserViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

@Observable
@MainActor
final class ProgramBrowserViewModel {
    // MARK: - State
    private(set) var programs: [BreathProgram] = []

    // MARK: - Actions
    func loadPrograms() {
        programs = BreathProgram.allPrograms
    }
}
#endif
