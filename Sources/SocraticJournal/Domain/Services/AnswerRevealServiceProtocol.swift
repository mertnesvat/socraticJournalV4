// AnswerRevealServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service for managing the reveal mechanic between friends' answers
public protocol AnswerRevealServiceProtocol: Sendable {
    /// Returns all reveals for a given question
    func getRevealsForQuestion(questionId: String) async throws -> [AnswerReveal]

    /// Unlocks a friend's answer (requires the user to have answered first)
    func unlockAnswer(revealId: String) async throws -> AnswerReveal

    /// Checks if the current user has answered a specific question
    func hasAnsweredQuestion(questionId: String) async throws -> Bool

    /// Retrieves a friend's voice answer by ID
    func getFriendAnswer(answerId: String) async throws -> VoiceAnswer
}
