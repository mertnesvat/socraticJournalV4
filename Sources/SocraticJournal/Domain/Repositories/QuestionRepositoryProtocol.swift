// QuestionRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Repository for persisting and retrieving daily questions
public protocol QuestionRepositoryProtocol: Sendable {
    /// Saves a question to the data store
    func saveQuestion(_ question: DailyQuestion) async throws

    /// Retrieves a question by its ID
    func getQuestion(id: String) async throws -> DailyQuestion?

    /// Returns all stored questions
    func getAllQuestions() async throws -> [DailyQuestion]

    /// Returns the active question for today, if available
    func getTodaysQuestion() async throws -> DailyQuestion?
}
