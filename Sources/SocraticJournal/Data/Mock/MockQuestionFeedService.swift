// MockQuestionFeedService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of QuestionFeedServiceProtocol using static mock data
@MainActor
final class MockQuestionFeedService: QuestionFeedServiceProtocol {
    nonisolated init() {}

    nonisolated func getTodaysQuestion() async throws -> DailyQuestion {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.todaysQuestion
    }

    nonisolated func getQuestionHistory() async throws -> [DailyQuestion] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.questionHistory
    }

    nonisolated func getUpcomingQuestions() async throws -> [DailyQuestion] {
        try await Task.sleep(nanoseconds: 300_000_000)
        // Return a few future questions for preview purposes
        return Array(MockDataProvider.allQuestions.prefix(3))
    }
}
