// BreathSessionRepositoryProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Protocol for persisting and querying breath sessions
public protocol BreathSessionRepositoryProtocol: Sendable {
    /// Save a completed session
    func saveSession(_ session: BreathSession) async throws

    /// Get all sessions for a specific date
    func getSessionsForDate(_ date: Date) async throws -> [BreathSession]

    /// Get sessions within a date range
    func getSessionsForDateRange(from startDate: Date, to endDate: Date) async throws -> [BreathSession]

    /// Get total minutes practiced today
    func getTotalMinutesToday() async throws -> Double

    /// Get current streak (consecutive days with at least one session)
    func getStreak() async throws -> Int

    /// Get the longest streak ever achieved
    func getBestStreak() async throws -> Int

    /// Get total minutes practiced all time
    func getTotalMinutesAllTime() async throws -> Double

    /// Get total session count all time
    func getTotalSessionCount() async throws -> Int
}
