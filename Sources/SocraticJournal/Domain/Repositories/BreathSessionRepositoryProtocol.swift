// BreathSessionRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining breath session persistence operations
public protocol BreathSessionRepositoryProtocol: Sendable {
    /// Save a completed breath session
    func saveSession(_ session: BreathSession) async throws

    /// Get all sessions for a specific date
    func getSessionsForDate(_ date: Date) async throws -> [BreathSession]

    /// Get sessions within a date range
    func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession]

    /// Get total minutes practiced today
    func getTotalMinutesToday() async throws -> Double

    /// Get current streak (consecutive days with at least one session)
    func getStreak() async throws -> Int

    // MARK: - BOLT Score

    /// Save a BOLT score
    func saveBOLTScore(_ score: BOLTScore) async throws

    /// Get all BOLT scores
    func getBOLTScores() async throws -> [BOLTScore]

    /// Get the most recent BOLT score
    func getLatestBOLTScore() async throws -> BOLTScore?

    // MARK: - All Sessions

    /// Get all saved sessions sorted by startedAt descending
    func getAllSessions() async throws -> [BreathSession]
}
