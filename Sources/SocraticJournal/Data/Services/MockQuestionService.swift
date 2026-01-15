// MockQuestionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of QuestionServiceProtocol
/// Provides local fallback responses for development and offline use
public final class MockQuestionService: QuestionServiceProtocol, @unchecked Sendable {

    public init() {}

    // MARK: - Fallback Questions

    /// First question always the same
    private let firstQuestion = "What's on your mind today?"

    /// Fallback follow-up questions
    private let followUpQuestions = [
        "What makes this important to you?",
        "How does this connect to your deeper values?",
        "What would change if you fully understood this?",
        "What are you truly seeking here?",
        "What assumption might you be holding onto?",
        "If a wise friend asked the same question, what would you tell them?",
        "What is the fear beneath this thought?",
        "How might your future self view this situation?",
        "What truth are you dancing around?",
        "What would you do if you weren't afraid?"
    ]

    /// Third question fallbacks (more conclusive/reflective)
    private let finalQuestions = [
        "What insight emerges when you sit with all of this?",
        "What one small step could bring clarity?",
        "How might you carry this wisdom forward?",
        "What commitment are you ready to make?",
        "What will you remember from this reflection?",
        "How has your understanding shifted?",
        "What gift does this challenge offer you?",
        "What would you tell yourself a year from now?"
    ]

    // MARK: - Fallback Reactions

    private let reactions = [
        "Socrates nods slowly, contemplating your words...",
        "Socrates strokes his beard thoughtfully...",
        "A knowing smile crosses Socrates' face...",
        "Socrates pauses, giving weight to your reflection...",
        "Socrates' eyes light up with recognition...",
        "Socrates leans forward with interest...",
        "A moment of shared understanding passes...",
        "Socrates closes his eyes briefly, absorbing your thoughts...",
        "Socrates nods with quiet appreciation...",
        "A gentle silence follows, honoring your words..."
    ]

    // MARK: - Fallback Clarity Mirrors

    private let clarityMirrors = [
        "Your words reveal a search for meaning beyond the surface. There's wisdom in questioning what we take for granted.",
        "I sense a desire for authenticity in your reflection. The examined life requires such courage.",
        "Your thoughts suggest a turning point - a moment where understanding deepens into wisdom.",
        "There's a tension here between what is and what could be. This awareness is the beginning of change.",
        "Your reflection shows self-awareness. You're already closer to clarity than you might realize.",
        "The vulnerability in your words is a strength. Truth often emerges from such openness.",
        "I notice you're grappling with something fundamental. These are the questions worth asking.",
        "Your insight touches on universal human experience. You're not alone in this inquiry."
    ]

    // MARK: - Fallback Insight Cards

    private let insightCards = [
        "Seeking deeper truth",
        "Growth through challenge",
        "Courage in uncertainty",
        "Wisdom from reflection",
        "Finding inner clarity",
        "Embracing the unknown",
        "Truth in vulnerability",
        "Purpose through questioning",
        "Strength in awareness",
        "Path to understanding"
    ]

    // MARK: - QuestionServiceProtocol

    public func generateNextQuestion(previousExchanges: [Exchange]) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        switch previousExchanges.count {
        case 0:
            return firstQuestion
        case 1:
            return followUpQuestions.randomElement() ?? followUpQuestions[0]
        default:
            return finalQuestions.randomElement() ?? finalQuestions[0]
        }
    }

    public func generateReaction(answer: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // For skipped answers
        if answer.isEmpty {
            return "Socrates nods respectfully, understanding that some answers need time..."
        }

        return reactions.randomElement() ?? reactions[0]
    }

    public func generateClarityMirror(answer: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds

        // For skipped answers
        if answer.isEmpty {
            return "Silence, too, can be an answer. What remains unspoken often speaks loudest."
        }

        return clarityMirrors.randomElement() ?? clarityMirrors[0]
    }

    public func generateInsightCard(answer: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // For skipped answers
        if answer.isEmpty {
            return "Space for reflection"
        }

        return insightCards.randomElement() ?? insightCards[0]
    }
}
