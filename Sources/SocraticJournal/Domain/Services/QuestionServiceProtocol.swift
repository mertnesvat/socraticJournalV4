// QuestionServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the Socratic questioning service
/// Generates questions and AI responses for dialogue sessions
public protocol QuestionServiceProtocol: Sendable {
    /// Generates the next Socratic question based on previous exchanges
    /// - Parameter previousExchanges: Array of previous exchanges in the session
    /// - Returns: The next question to ask
    func generateNextQuestion(previousExchanges: [Exchange]) async throws -> String

    /// Generates Socrates' emotional reaction to an answer
    /// - Parameter answer: The user's answer
    /// - Returns: An emotional reaction (e.g., "Socrates nods slowly...")
    func generateReaction(answer: String) async throws -> String

    /// Generates a clarity mirror reflection of the user's insights
    /// - Parameter answer: The user's answer
    /// - Returns: A reflective insight about the answer
    func generateClarityMirror(answer: String) async throws -> String

    /// Generates a 3-4 word insight card summary
    /// - Parameter answer: The user's answer
    /// - Returns: A brief insight summary (e.g., "Growth through challenge")
    func generateInsightCard(answer: String) async throws -> String
}

/// Errors that can occur in the question service
public enum QuestionServiceError: Error, LocalizedError {
    case networkUnavailable
    case generationFailed(String)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable. Using fallback responses."
        case .generationFailed(let reason):
            return "Failed to generate content: \(reason)"
        case .invalidResponse:
            return "Received an invalid response from the service."
        }
    }
}
