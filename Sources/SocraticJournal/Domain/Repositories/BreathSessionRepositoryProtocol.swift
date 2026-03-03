// BreathSessionRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for breath session data operations
public protocol BreathSessionRepositoryProtocol: Sendable {
    func saveSession(_ session: BreathSession) async throws
    func getSessions(for date: Date) async throws -> [BreathSession]
    func getAllSessions() async throws -> [BreathSession]
    func getSessionsInRange(from: Date, to: Date) async throws -> [BreathSession]
    func getCurrentStreak() async throws -> Int
    func getTotalMinutesBreathed() async throws -> Double
    func getTotalSessions() async throws -> Int
}
