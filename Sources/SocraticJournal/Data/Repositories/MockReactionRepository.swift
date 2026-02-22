// MockReactionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of ReactionRepositoryProtocol
/// Stores reactions in memory with some pre-populated mock reactions
public final class MockReactionRepository: ReactionRepositoryProtocol, @unchecked Sendable {
    private var reactions: [AnswerReaction] = []

    public init() {
        seedMockReactions()
    }

    // MARK: - ReactionRepositoryProtocol

    public func addReaction(_ reaction: AnswerReaction) async {
        reactions.append(reaction)
    }

    public func getReactions(forAnswer answerId: String) async -> [AnswerReaction] {
        return reactions.filter { $0.answerId == answerId }
    }

    // MARK: - Private Helpers

    private func seedMockReactions() {
        reactions = [
            AnswerReaction(
                id: "reaction-001",
                answerId: "ans-mock-001",
                reactorUserId: "user-mock-002",
                type: .fire,
                createdAt: Date(timeIntervalSince1970: 1_735_740_000)
            ),
            AnswerReaction(
                id: "reaction-002",
                answerId: "ans-mock-001",
                reactorUserId: "user-mock-003",
                type: .laugh,
                createdAt: Date(timeIntervalSince1970: 1_735_741_000)
            ),
            AnswerReaction(
                id: "reaction-003",
                answerId: "ans-mock-002",
                reactorUserId: "user-mock-001",
                type: .mindBlown,
                createdAt: Date(timeIntervalSince1970: 1_735_742_000)
            ),
            AnswerReaction(
                id: "reaction-004",
                answerId: "ans-mock-005",
                reactorUserId: "user-mock-003",
                type: .disagree,
                createdAt: Date(timeIntervalSince1970: 1_735_743_000)
            ),
            AnswerReaction(
                id: "reaction-005",
                answerId: "ans-mock-013",
                reactorUserId: "user-mock-004",
                type: .fire,
                createdAt: Date(timeIntervalSince1970: 1_735_744_000)
            )
        ]
    }
}
