// ReactionRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining answer reaction data operations
public protocol ReactionRepositoryProtocol: Sendable {
    /// Adds a reaction to a voice answer
    func addReaction(_ reaction: AnswerReaction) async

    /// Fetches all reactions for a specific answer
    func getReactions(forAnswer answerId: String) async -> [AnswerReaction]
}
