// VoiceAnswerRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Repository for persisting and retrieving voice answers
public protocol VoiceAnswerRepositoryProtocol: Sendable {
    /// Saves a voice answer to the data store
    func saveAnswer(_ answer: VoiceAnswer) async throws

    /// Retrieves a voice answer by its ID
    func getAnswer(id: String) async throws -> VoiceAnswer?

    /// Returns all voice answers for a given question
    func getAnswersForQuestion(questionId: String) async throws -> [VoiceAnswer]

    /// Returns all voice answers by a specific user
    func getUserAnswers(userId: String) async throws -> [VoiceAnswer]

    /// Deletes a voice answer by its ID
    func deleteAnswer(id: String) async throws
}
