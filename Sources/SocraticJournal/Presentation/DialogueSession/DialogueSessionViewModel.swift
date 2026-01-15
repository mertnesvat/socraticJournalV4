// DialogueSessionViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// Represents the current phase within a question exchange
public enum ExchangePhase: Equatable {
    case showingQuestion
    case awaitingAnswer
    case processingAnswer
    case showingReaction
    case showingClarityMirror
    case showingInsightCard
    case readyForNext
}

/// ViewModel for the Socratic Dialogue Session
@Observable
@MainActor
public final class DialogueSessionViewModel {
    // MARK: - Constants

    public static let totalQuestions = 3

    // MARK: - State

    /// Current question index (0-based)
    private(set) var currentQuestionIndex: Int = 0

    /// Current phase in the exchange flow
    private(set) var phase: ExchangePhase = .showingQuestion

    /// Current question being displayed
    private(set) var currentQuestion: String = ""

    /// User's current answer text
    var answerText: String = ""

    /// Current Socrates reaction
    private(set) var currentReaction: String = ""

    /// Current clarity mirror text
    private(set) var currentClarityMirror: String = ""

    /// Current insight card text
    private(set) var currentInsightCard: String = ""

    /// All exchanges completed in this session
    private(set) var exchanges: [Exchange] = []

    /// The current session being built
    private(set) var session: JournalSession

    /// Loading state
    private(set) var isLoading: Bool = false

    /// Error state
    private(set) var error: Error?

    /// Whether the session is complete
    var isSessionComplete: Bool {
        exchanges.count >= Self.totalQuestions
    }

    /// Progress as fraction (0.0 to 1.0)
    var progress: Double {
        Double(currentQuestionIndex) / Double(Self.totalQuestions)
    }

    /// Display string for progress
    var progressText: String {
        "Question \(currentQuestionIndex + 1) of \(Self.totalQuestions)"
    }

    // MARK: - Dependencies

    private let questionService: QuestionServiceProtocol
    private let repository: JournalRepositoryProtocol

    // MARK: - Callbacks

    var onSessionComplete: ((JournalSession) -> Void)?
    var onExit: (() -> Void)?

    // MARK: - Init

    public init(
        questionService: QuestionServiceProtocol,
        repository: JournalRepositoryProtocol
    ) {
        self.questionService = questionService
        self.repository = repository
        self.session = JournalSession(
            id: UUID().uuidString,
            createdAt: Date(),
            exchanges: [],
            isComplete: false
        )
    }

    // MARK: - Actions

    /// Start the dialogue session by loading the first question
    public func startSession() async {
        await loadNextQuestion()
    }

    /// Load the next question
    private func loadNextQuestion() async {
        isLoading = true
        error = nil
        phase = .showingQuestion

        do {
            currentQuestion = try await questionService.generateNextQuestion(previousExchanges: exchanges)
            phase = .awaitingAnswer
        } catch {
            self.error = error
            // Use a fallback first question if generation fails
            currentQuestion = "What's on your mind today?"
            phase = .awaitingAnswer
        }

        isLoading = false
    }

    /// Submit the current answer (can be empty for skip)
    public func submitAnswer() async {
        let isSkipped = answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let answer = isSkipped ? "" : answerText.trimmingCharacters(in: .whitespacesAndNewlines)

        phase = .processingAnswer
        isLoading = true
        error = nil

        do {
            // Generate AI responses in sequence for visual flow
            // 1. Reaction
            phase = .showingReaction
            currentReaction = try await questionService.generateReaction(answer: answer)

            // Brief pause for user to read
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

            // 2. Clarity Mirror
            phase = .showingClarityMirror
            currentClarityMirror = try await questionService.generateClarityMirror(answer: answer)

            // Brief pause
            try await Task.sleep(nanoseconds: 1_500_000_000)

            // 3. Insight Card
            phase = .showingInsightCard
            currentInsightCard = try await questionService.generateInsightCard(answer: answer)

            // Create the exchange
            let exchange = Exchange(
                question: currentQuestion,
                answer: answer,
                socratesReaction: currentReaction,
                clarityMirror: currentClarityMirror,
                insightCard: currentInsightCard,
                skipped: isSkipped
            )
            exchanges.append(exchange)

            phase = .readyForNext

        } catch {
            self.error = error
            // Create exchange with fallback responses
            let exchange = Exchange(
                question: currentQuestion,
                answer: answer,
                socratesReaction: "Socrates nods thoughtfully...",
                clarityMirror: "Your reflection holds meaning worth exploring.",
                insightCard: "Quiet wisdom",
                skipped: isSkipped
            )
            exchanges.append(exchange)
            phase = .readyForNext
        }

        isLoading = false
    }

    /// Continue to the next question or complete the session
    public func continueToNext() async {
        // Clear previous answer
        answerText = ""
        currentReaction = ""
        currentClarityMirror = ""
        currentInsightCard = ""

        currentQuestionIndex += 1

        if currentQuestionIndex >= Self.totalQuestions {
            // Session complete
            await completeSession()
        } else {
            // Load next question
            await loadNextQuestion()
        }
    }

    /// Complete and save the session
    private func completeSession() async {
        isLoading = true

        // Update session with all exchanges
        session = JournalSession(
            id: session.id,
            createdAt: session.createdAt,
            exchanges: exchanges,
            clarityScore: nil, // Will be generated in post-session
            wisdomQuote: nil,  // Will be generated in post-session
            isComplete: true
        )

        do {
            try await repository.saveSession(session)
            onSessionComplete?(session)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Request to exit the session (will trigger confirmation if mid-session)
    public func requestExit() {
        onExit?()
    }

    /// Discard the current session and exit
    public func discardAndExit() {
        onExit?()
    }

    /// Whether we have unsaved progress that would be lost
    var hasUnsavedProgress: Bool {
        !exchanges.isEmpty || !answerText.isEmpty
    }
}
#endif
