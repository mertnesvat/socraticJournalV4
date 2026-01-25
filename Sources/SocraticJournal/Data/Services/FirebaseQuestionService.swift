// FirebaseQuestionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Firebase-backed question service with local fallback
/// Uses Firebase Functions for dynamic, contextual Socratic questions after the first question
/// Falls back to local curated questions on network failure
public final class FirebaseQuestionService: QuestionServiceProtocol, @unchecked Sendable {
    /// Shared instance for app-wide usage
    public static let shared = FirebaseQuestionService()

    /// Firebase Functions service for AI-generated questions
    private let firebaseFunctionsService: FirebaseFunctionsServiceProtocol

    /// Local question service for first question and fallback
    private let localQuestionService: QuestionServiceProtocol

    /// Private initializer for dependency injection
    /// - Parameters:
    ///   - firebaseFunctionsService: Firebase Functions service for remote question generation
    ///   - localQuestionService: Local question service for curated first questions and fallback
    private init(
        firebaseFunctionsService: FirebaseFunctionsServiceProtocol = FirebaseFunctionsService.shared,
        localQuestionService: QuestionServiceProtocol = MockQuestionService()
    ) {
        self.firebaseFunctionsService = firebaseFunctionsService
        self.localQuestionService = localQuestionService
    }

    // MARK: - QuestionServiceProtocol

    /// Generates the next Socratic question based on previous exchanges
    /// - First question (index 0): Always from curated local set
    /// - Follow-up questions (index 1+): Firebase-generated with local fallback
    /// - Parameter previousExchanges: Array of previous exchanges in the session
    /// - Returns: The next question to ask
    public func generateNextQuestion(previousExchanges: [Exchange]) async throws -> String {
        let questionIndex = previousExchanges.count

        // First question always from curated local set for consistency
        if questionIndex == 0 {
            #if DEBUG
            print("[FirebaseQuestionService] Using local curated first question")
            #endif
            return try await localQuestionService.generateNextQuestion(previousExchanges: [])
        }

        // For follow-up questions (index 1+), try Firebase first
        guard let lastExchange = previousExchanges.last else {
            #if DEBUG
            print("[FirebaseQuestionService] No previous exchanges, falling back to local")
            #endif
            return try await localQuestionService.generateNextQuestion(previousExchanges: previousExchanges)
        }

        // Build exchange data for context (excluding the last exchange which is current)
        let exchangeData = previousExchanges.dropLast().map {
            ExchangeData(question: $0.question, answer: $0.answer)
        }

        let request = FollowUpQuestionRequest(
            currentQuestion: lastExchange.question,
            currentAnswer: lastExchange.answer,
            previousExchanges: exchangeData.isEmpty ? nil : exchangeData,
            questionIndex: questionIndex
        )

        #if DEBUG
        print("[FirebaseQuestionService] Requesting Firebase follow-up question (index: \(questionIndex))")
        print("[FirebaseQuestionService] Current question: \(lastExchange.question.prefix(40))...")
        print("[FirebaseQuestionService] Previous exchanges count: \(exchangeData.count)")
        #endif

        do {
            let question = try await firebaseFunctionsService.generateFollowUpQuestion(request: request)
            #if DEBUG
            print("[FirebaseQuestionService] Firebase success: \(question.prefix(50))...")
            #endif
            return question
        } catch {
            #if DEBUG
            print("[FirebaseQuestionService] Firebase failed, using local fallback: \(error.localizedDescription)")
            #endif
            // Fallback to local question service on any error (network, timeout, etc.)
            return try await localQuestionService.generateNextQuestion(previousExchanges: previousExchanges)
        }
    }

    /// Generates Socrates' emotional reaction to an answer
    /// Delegates to local service (reactions are curated, not AI-generated)
    public func generateReaction(answer: String) async throws -> String {
        return try await localQuestionService.generateReaction(answer: answer)
    }

    /// Generates a clarity mirror reflection of the user's insights
    /// Delegates to local service (clarity mirror is handled by DialogueSessionViewModel with its own Firebase integration)
    public func generateClarityMirror(answer: String) async throws -> String {
        return try await localQuestionService.generateClarityMirror(answer: answer)
    }

    /// Generates a 3-4 word insight card summary
    /// Delegates to local service (insight cards are curated)
    public func generateInsightCard(answer: String) async throws -> String {
        return try await localQuestionService.generateInsightCard(answer: answer)
    }
}
#endif
