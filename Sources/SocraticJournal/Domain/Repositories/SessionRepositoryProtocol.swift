// SessionRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for persisting and retrieving breath sessions
public protocol SessionRepositoryProtocol: Sendable {
    /// Save a completed session
    func saveSession(_ session: BreathSession) async throws

    /// Get all sessions, most recent first
    func getAllSessions() async throws -> [BreathSession]

    /// Get sessions for a specific date
    func getSessions(for date: Date) async throws -> [BreathSession]

    /// Get sessions for today
    func getTodaySessions() async throws -> [BreathSession]

    /// Get the total number of sessions
    func getSessionCount() async throws -> Int

    /// Clear all session data
    func clearAllSessions() async throws
}
