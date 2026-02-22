// MockAnswerRevealService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of AnswerRevealServiceProtocol using static mock data
@MainActor
final class MockAnswerRevealService: AnswerRevealServiceProtocol {
    nonisolated init() {}

    nonisolated func getRevealsForQuestion(questionId: String) async throws -> [AnswerReveal] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.answerReveals.filter { $0.questionId == questionId }
    }

    nonisolated func unlockAnswer(revealId: String) async throws -> AnswerReveal {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard var reveal = MockDataProvider.answerReveals.first(where: { $0.id == revealId }) else {
            throw MockServiceError.notFound
        }
        reveal = AnswerReveal(
            id: reveal.id,
            myAnswerId: reveal.myAnswerId,
            friendAnswerId: reveal.friendAnswerId,
            questionId: reveal.questionId,
            isUnlocked: true,
            unlockedAt: Date()
        )
        return reveal
    }

    nonisolated func hasAnsweredQuestion(questionId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.voiceAnswers.contains { answer in
            answer.questionId == questionId && answer.userId == MockDataProvider.currentUser.id
        }
    }

    nonisolated func getFriendAnswer(answerId: String) async throws -> VoiceAnswer {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard let answer = MockDataProvider.voiceAnswers.first(where: { $0.id == answerId }) else {
            throw MockServiceError.notFound
        }
        return answer
    }
}

/// Errors used by mock services
enum MockServiceError: Error, LocalizedError {
    case notFound
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .notFound: return "The requested item was not found."
        case .unauthorized: return "You are not authorized to perform this action."
        }
    }
}
