// QuestionFeedServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service for managing the daily question feed
public protocol QuestionFeedServiceProtocol: Sendable {
    /// Returns the active question for today
    func getTodaysQuestion() async throws -> DailyQuestion

    /// Returns a list of previously active questions
    func getQuestionHistory() async throws -> [DailyQuestion]

    /// Returns upcoming questions that have not yet been active
    func getUpcomingQuestions() async throws -> [DailyQuestion]
}
