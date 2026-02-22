// MockQuestionRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of QuestionRepositoryProtocol that loads questions from bundled JSON
public final class MockQuestionRepository: QuestionRepositoryProtocol, @unchecked Sendable {
    private var questions: [DailyQuestion] = []
    private var questionHistory: [DailyQuestion] = []
    private var streakDays: Int

    public init(streakDays: Int = 0) {
        self.streakDays = streakDays
        self.questions = Self.loadQuestionsFromBundle()
    }

    // MARK: - QuestionRepositoryProtocol

    public func getTodaysQuestion() async -> DailyQuestion {
        let targetLevel = levelForStreak(streakDays)
        let levelQuestions = questions.filter { $0.level == targetLevel && $0.isActive }

        guard !levelQuestions.isEmpty else {
            // Fallback to any active question if no questions match the level
            let activeQuestions = questions.filter { $0.isActive }
            guard !activeQuestions.isEmpty else {
                return DailyQuestion(
                    id: "fallback",
                    text: "What's on your mind today?",
                    category: .iceBreaker,
                    level: .level1
                )
            }
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let index = dayOfYear % activeQuestions.count
            let question = activeQuestions[index]
            trackQuestion(question)
            return question
        }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % levelQuestions.count
        let question = levelQuestions[index]
        trackQuestion(question)
        return question
    }

    public func getQuestionHistory() async -> [DailyQuestion] {
        return questionHistory
    }

    public func getQuestionsByLevel(_ level: QuestionLevel) async -> [DailyQuestion] {
        return questions.filter { $0.level == level && $0.isActive }
    }

    // MARK: - Internal

    /// Updates the streak day count used for level escalation
    func updateStreakDays(_ days: Int) {
        streakDays = days
    }

    // MARK: - Private Helpers

    private func trackQuestion(_ question: DailyQuestion) {
        if !questionHistory.contains(where: { $0.id == question.id }) {
            questionHistory.append(question)
        }
    }

    private func levelForStreak(_ days: Int) -> QuestionLevel {
        switch days {
        case 0...7:
            return .level1
        case 8...21:
            return .level2
        case 22...28:
            return .level3
        default:
            return .level4
        }
    }

    private static func loadQuestionsFromBundle() -> [DailyQuestion] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([DailyQuestion].self, from: data)
        } catch {
            return []
        }
    }
}
