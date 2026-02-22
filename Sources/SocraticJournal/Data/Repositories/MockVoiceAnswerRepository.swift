// MockVoiceAnswerRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of VoiceAnswerRepositoryProtocol
/// Stores user answers in memory and loads friend answers from bundled JSON
public final class MockVoiceAnswerRepository: VoiceAnswerRepositoryProtocol, @unchecked Sendable {
    private var userAnswers: [String: VoiceAnswer] = [:]
    private var mockFriendAnswers: [VoiceAnswer] = []
    private var mockUsers: [String: UserProfile] = [:]
    private var answeredQuestionIds: Set<String> = []

    public init() {
        let users = Self.loadMockUsers()
        for user in users {
            mockUsers[user.id] = user
        }
        mockFriendAnswers = Self.loadMockAnswers()
    }

    // MARK: - VoiceAnswerRepositoryProtocol

    public func saveAnswer(_ answer: VoiceAnswer) async {
        userAnswers[answer.questionId] = answer
        answeredQuestionIds.insert(answer.questionId)
    }

    public func getMyAnswer(forQuestion questionId: String) async -> VoiceAnswer? {
        return userAnswers[questionId]
    }

    public func getFriendAnswers(forQuestion questionId: String) async -> [FriendAnswer] {
        let friendAnswersForQuestion = mockFriendAnswers.filter { $0.questionId == questionId }
        let userHasAnswered = answeredQuestionIds.contains(questionId)

        return friendAnswersForQuestion.compactMap { answer in
            guard let friend = mockUsers[answer.userId] else { return nil }
            return FriendAnswer(
                answer: answer,
                friend: friend,
                isUnlocked: userHasAnswered
            )
        }
    }

    public func hasAnsweredToday() async -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return userAnswers.values.contains { answer in
            calendar.startOfDay(for: answer.createdAt) == today
        }
    }

    // MARK: - Private Helpers

    private static func loadMockUsers() -> [UserProfile] {
        guard let url = Bundle.main.url(forResource: "mock_users", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([UserProfile].self, from: data)
        } catch {
            return []
        }
    }

    private static func loadMockAnswers() -> [VoiceAnswer] {
        guard let url = Bundle.main.url(forResource: "mock_answers", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([VoiceAnswer].self, from: data)
        } catch {
            return []
        }
    }
}
