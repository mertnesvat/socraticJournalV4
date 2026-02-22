// QuestionRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining daily question data operations
public protocol QuestionRepositoryProtocol: Sendable {
    /// Fetches today's active question
    func getTodaysQuestion() async -> DailyQuestion

    /// Fetches the history of past daily questions
    func getQuestionHistory() async -> [DailyQuestion]

    /// Fetches questions filtered by a specific level
    func getQuestionsByLevel(_ level: QuestionLevel) async -> [DailyQuestion]
}
