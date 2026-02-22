// VoiceAnswerRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining voice answer data operations
public protocol VoiceAnswerRepositoryProtocol: Sendable {
    /// Saves a voice answer
    func saveAnswer(_ answer: VoiceAnswer) async

    /// Fetches the current user's answer for a specific question
    func getMyAnswer(forQuestion questionId: String) async -> VoiceAnswer?

    /// Fetches friend answers for a specific question
    func getFriendAnswers(forQuestion questionId: String) async -> [FriendAnswer]

    /// Checks whether the current user has answered today's question
    func hasAnsweredToday() async -> Bool
}
