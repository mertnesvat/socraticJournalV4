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

    /// Get all stored sessions
    func getAllSessions() async throws -> [BreathSession]

    /// Get total minutes across all sessions
    func getTotalMinutes() async throws -> Double

    /// Get total number of sessions
    func getTotalSessions() async throws -> Int

    /// Get longest streak of consecutive days
    func getLongestStreak() async throws -> Int

    /// Get sessions grouped by pattern ID
    func getSessionsByPattern() async throws -> [String: [BreathSession]]

    /// Get sessions for a specific calendar month
    func getSessionsForMonth(year: Int, month: Int) async throws -> [BreathSession]
}
