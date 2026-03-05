// ProgramProgressRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining program progress persistence operations
public protocol ProgramProgressRepositoryProtocol: Sendable {
    /// Get the currently active program progress, if any
    func getActiveProgram() async throws -> ProgramProgress?

    /// Start a new program, replacing any existing active program
    func startProgram(_ programId: String, totalDays: Int) async throws

    /// Mark a specific day as complete for the given program
    func completeDay(_ day: Int, for programId: String) async throws

    /// Abandon the current active program
    func abandonProgram() async throws

    /// Get progress for a specific program (may be historical)
    func getProgress(for programId: String) async throws -> ProgramProgress?
}
