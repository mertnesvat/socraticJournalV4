// StreakRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining answer streak data operations
public protocol StreakRepositoryProtocol: Sendable {
    /// Fetches the current user's active streak
    func getCurrentStreak() async -> AnswerStreak

    /// Records that the user answered today's question
    func recordAnswer() async

    /// Fetches the streak history for analytics
    func getStreakHistory() async -> [AnswerStreak]
}
