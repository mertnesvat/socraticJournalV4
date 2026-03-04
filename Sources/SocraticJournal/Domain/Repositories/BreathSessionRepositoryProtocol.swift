// BreathSessionRepositoryProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

protocol BreathSessionRepositoryProtocol: Sendable {
    func saveSession(_ session: BreathSession) async throws
    func getSessionsForDate(_ date: Date) async throws -> [BreathSession]
    func getSessionsForDateRange(from: Date, to: Date) async throws -> [BreathSession]
    func getTotalMinutesToday() async throws -> Double
    func getStreak() async throws -> Int
}
