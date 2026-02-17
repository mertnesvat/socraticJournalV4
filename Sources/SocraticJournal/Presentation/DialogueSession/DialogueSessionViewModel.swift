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
    case sessionComplete
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

    /// Whether to show the session complete screen
    var showSessionComplete: Bool = false

    /// Whether currently in offline mode
    private(set) var isOffline: Bool = false

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
    private let analyticsService: AnalyticsServiceProtocol
    private let firebaseFunctionsService: FirebaseFunctionsServiceProtocol

    // MARK: - Analytics Timing

    /// Track when the current question was shown (for time-to-answer measurement)
    private var questionShownAt: Date?

    /// Track when follow-up generation started (for latency measurement)
    private var followUpStartTime: Date?

    /// Track when insight generation started (for latency measurement)
    private var insightStartTime: Date?

    // MARK: - Callbacks

    var onSessionComplete: ((JournalSession) -> Void)?
    var onExit: (() -> Void)?

    // MARK: - Init

    public init(
        questionService: QuestionServiceProtocol,
        repository: JournalRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        firebaseFunctionsService: FirebaseFunctionsServiceProtocol = FirebaseFunctionsService.shared
    ) {
        self.questionService = questionService
        self.repository = repository
        self.analyticsService = analyticsService
        self.firebaseFunctionsService = firebaseFunctionsService
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
        // Log session started analytics event
        analyticsService.logEvent(.sessionStarted, parameters: [
            AnalyticsParameter.sessionId.rawValue: session.id
        ])
        await loadNextQuestion()
    }

    /// Load the next question
    private func loadNextQuestion() async {
        isLoading = true
        error = nil
        phase = .showingQuestion

        do {
            currentQuestion = try await executeWithTimeoutDetection(phase: "question_generation_q\(currentQuestionIndex + 1)") {
                try await self.questionService.generateNextQuestion(previousExchanges: self.exchanges)
            }
            phase = .awaitingAnswer

            // Track when question was shown for time-to-answer measurement
            questionShownAt = Date()

            // Analytics: Question shown to user (new fine-grained event)
            analyticsService.logEvent(.questionShown, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                AnalyticsParameter.questionId.rawValue: UUID().uuidString, // Unique ID for this question instance
                AnalyticsParameter.phase.rawValue: "question_\(currentQuestionIndex + 1)"
            ])

            // Legacy event (kept for backward compatibility)
            analyticsService.logEvent(.sessionQuestionShown, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex,
                AnalyticsParameter.questionText.rawValue: currentQuestion
            ])
        } catch {
            self.error = error

            // Analytics: Error during question generation
            analyticsService.logEvent(.sessionError, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.errorType.rawValue: "question_generation_failed",
                AnalyticsParameter.phase.rawValue: "load_question",
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex
            ])

            // Use a fallback first question if generation fails
            currentQuestion = "What's on your mind today?"
            phase = .awaitingAnswer

            // Track when question was shown
            questionShownAt = Date()

            // Analytics: Question shown (fallback) - new event
            analyticsService.logEvent(.questionShown, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                AnalyticsParameter.questionId.rawValue: UUID().uuidString,
                AnalyticsParameter.phase.rawValue: "question_\(currentQuestionIndex + 1)"
            ])

            // Legacy event (kept for backward compatibility)
            analyticsService.logEvent(.sessionQuestionShown, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex,
                AnalyticsParameter.questionText.rawValue: currentQuestion
            ])
        }

        isLoading = false
    }

    /// Submit the current answer (can be empty for skip)
    public func submitAnswer() async {
        let isSkipped = answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let answer = isSkipped ? "" : answerText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Calculate time-to-answer if we tracked when question was shown
        let timeToAnswerSeconds: Int?
        if let questionShownAt = questionShownAt {
            timeToAnswerSeconds = Int(Date().timeIntervalSince(questionShownAt))
        } else {
            timeToAnswerSeconds = nil
        }

        // Generate exchange ID upfront for offline queue tracking
        let exchangeId = UUID().uuidString

        // Analytics: Track answer submission or skip (new fine-grained events)
        if isSkipped {
            analyticsService.logEvent(.answerSkipped, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1
            ])

            // Legacy event
            analyticsService.logEvent(.sessionQuestionSkipped, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex
            ])
        } else {
            var params: [String: Any] = [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                AnalyticsParameter.answerLength.rawValue: answer.count
            ]
            if let timeToAnswer = timeToAnswerSeconds {
                params[AnalyticsParameter.timeToAnswerSeconds.rawValue] = timeToAnswer
            }

            analyticsService.logEvent(.answerSubmitted, parameters: params)

            // Legacy event
            analyticsService.logEvent(.sessionAnswerSubmitted, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex,
                AnalyticsParameter.answerLength.rawValue: answer.count
            ])
        }

        phase = .processingAnswer
        isLoading = true
        error = nil

        do {
            // Generate AI responses in sequence for visual flow

            // Analytics: Follow-up generation started
            followUpStartTime = Date()
            analyticsService.logEvent(.followUpGenerationStarted, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1
            ])

            // 1. Reaction (with Firebase integration and offline support)
            phase = .showingReaction
            currentReaction = await executeWithTimeoutDetection(phase: "follow_up_reaction_q\(currentQuestionIndex + 1)") {
                await self.generateReactionWithFallback(
                    question: self.currentQuestion,
                    answer: answer,
                    exchangeId: exchangeId
                )
            }

            // Brief pause for user to read
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

            // 2. Clarity Mirror (with Firebase integration and offline support)
            phase = .showingClarityMirror
            currentClarityMirror = await executeWithTimeoutDetection(phase: "follow_up_clarity_q\(currentQuestionIndex + 1)") {
                await self.generateClarityMirrorWithFallback(
                    question: self.currentQuestion,
                    answer: answer,
                    previousExchanges: self.exchanges,
                    exchangeId: exchangeId
                )
            }

            // Calculate follow-up generation latency
            let followUpLatencySeconds = Date().timeIntervalSince(followUpStartTime!)

            // Analytics: Follow-up generation completed (new event)
            analyticsService.logEvent(.followUpGenerationCompleted, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                AnalyticsParameter.latencySeconds.rawValue: followUpLatencySeconds
            ])

            // Legacy event
            analyticsService.logEvent(.sessionFollowUpGenerated, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex,
                AnalyticsParameter.responseTime.rawValue: Int(followUpLatencySeconds * 1000)
            ])

            // Brief pause
            try await Task.sleep(nanoseconds: 1_500_000_000)

            // Analytics: Insight generation started
            insightStartTime = Date()
            analyticsService.logEvent(.insightGenerationStarted, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1
            ])

            // 3. Insight Card (generated locally, no offline queue needed)
            phase = .showingInsightCard
            currentInsightCard = try await executeWithTimeoutDetection(phase: "insight_card_q\(currentQuestionIndex + 1)") {
                try await self.questionService.generateInsightCard(answer: answer)
            }

            // Calculate insight generation latency
            let insightLatencySeconds = Date().timeIntervalSince(insightStartTime!)

            // Analytics: Insight generation completed (new event)
            analyticsService.logEvent(.insightGenerationCompleted, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                AnalyticsParameter.latencySeconds.rawValue: insightLatencySeconds
            ])

            // Analytics: Insight viewed (new event)
            analyticsService.logEvent(.insightViewed, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1
            ])

            // Legacy event
            analyticsService.logEvent(.sessionInsightViewed, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex
            ])

            // Create the exchange with the pre-generated ID
            let exchange = Exchange(
                id: exchangeId,
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

            // Calculate latency for failure events
            let followUpLatency = followUpStartTime.map { Date().timeIntervalSince($0) }
            let insightLatency = insightStartTime.map { Date().timeIntervalSince($0) }

            // Analytics: Error during answer processing
            let errorDescription: String
            if let firebaseError = error as? FirebaseFunctionsError {
                errorDescription = "firebase_\(firebaseError)"
            } else {
                errorDescription = error.localizedDescription
            }

            // Determine which phase failed based on what was started
            if insightStartTime != nil {
                // Insight generation failed
                analyticsService.logEvent(.insightGenerationFailed, parameters: [
                    AnalyticsParameter.sessionId.rawValue: session.id,
                    AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                    AnalyticsParameter.errorType.rawValue: errorDescription,
                    AnalyticsParameter.latencySeconds.rawValue: insightLatency ?? 0
                ])
            } else if followUpStartTime != nil {
                // Follow-up generation failed
                analyticsService.logEvent(.followUpGenerationFailed, parameters: [
                    AnalyticsParameter.sessionId.rawValue: session.id,
                    AnalyticsParameter.questionNumber.rawValue: currentQuestionIndex + 1,
                    AnalyticsParameter.errorType.rawValue: errorDescription,
                    AnalyticsParameter.latencySeconds.rawValue: followUpLatency ?? 0
                ])
            }

            // Legacy event
            analyticsService.logEvent(.sessionError, parameters: [
                AnalyticsParameter.sessionId.rawValue: session.id,
                AnalyticsParameter.errorType.rawValue: errorDescription,
                AnalyticsParameter.phase.rawValue: "process_answer",
                AnalyticsParameter.questionIndex.rawValue: currentQuestionIndex
            ])

            // Create exchange with fallback responses (using the same exchange ID)
            let exchange = Exchange(
                id: exchangeId,
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

    // MARK: - Private Helpers

    /// Timeout threshold for phase operations (30 seconds)
    private static let phaseTimeoutSeconds: Double = 30.0

    /// Execute an async operation with timeout detection
    /// - Parameters:
    ///   - phase: The phase name for analytics
    ///   - operation: The async operation to execute
    /// - Returns: The result of the operation
    private func executeWithTimeoutDetection<T>(
        phase: String,
        operation: @escaping () async throws -> T
    ) async rethrows -> T {
        let startTime = Date()

        // Start a background task to monitor for timeout
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(Self.phaseTimeoutSeconds * 1_000_000_000))

            // Check if we're still running after timeout period
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= Self.phaseTimeoutSeconds {
                // Log timeout event
                await MainActor.run {
                    analyticsService.logEvent(.sessionPhaseTimeout, parameters: [
                        AnalyticsParameter.sessionId.rawValue: session.id,
                        AnalyticsParameter.phase.rawValue: phase,
                        AnalyticsParameter.elapsedSeconds.rawValue: elapsed
                    ])
                }
            }
        }

        // Execute the operation
        let result = try await operation()

        // Cancel the timeout monitoring task
        timeoutTask.cancel()

        return result
    }

    /// Generates a clarity mirror reflection using Firebase Functions with fallback to local service
    /// When offline, uses local fallback immediately and queues request for later sync
    /// - Parameters:
    ///   - question: The current Socratic question
    ///   - answer: The user's answer
    ///   - previousExchanges: Array of previous exchanges in the session
    ///   - exchangeId: The ID of the exchange (for offline queue tracking)
    /// - Returns: The generated clarity mirror text
    private func generateClarityMirrorWithFallback(
        question: String,
        answer: String,
        previousExchanges: [Exchange],
        exchangeId: String
    ) async -> String {
        // Build exchange data for the Firebase request
        let exchangeData = previousExchanges.map {
            ExchangeData(question: $0.question, answer: $0.answer)
        }

        // Check if offline - use local fallback immediately and queue for later
        if !NetworkMonitor.shared.isConnected {
            isOffline = true
            #if DEBUG
            print("[DialogueSession] Offline: Using local clarity mirror and queuing for sync")
            #endif

            // Queue the request for later sync
            let pendingRequest = PendingAIRequest(
                type: .clarityMirror,
                sessionId: session.id,
                exchangeId: exchangeId,
                question: question,
                answer: answer,
                previousExchanges: exchangeData.isEmpty ? nil : exchangeData
            )
            OfflineSyncQueue.shared.enqueue(pendingRequest)

            // Return local fallback
            do {
                return try await questionService.generateClarityMirror(answer: answer)
            } catch {
                return "Your reflection holds meaning worth exploring."
            }
        }

        isOffline = false
        let request = ClarityMirrorRequest(
            question: question,
            answer: answer,
            previousExchanges: exchangeData.isEmpty ? nil : exchangeData
        )

        do {
            // Try Firebase Functions first
            let mirror = try await firebaseFunctionsService.generateClarityMirror(request: request)
            #if DEBUG
            print("[DialogueSession] Firebase clarity mirror success")
            #endif
            return mirror
        } catch {
            #if DEBUG
            print("[DialogueSession] Firebase clarity mirror failed, using fallback: \(error.localizedDescription)")
            #endif

            // Check if it was a network error - queue for later sync
            if let firebaseError = error as? FirebaseFunctionsError,
               case .networkError = firebaseError {
                isOffline = true
                let pendingRequest = PendingAIRequest(
                    type: .clarityMirror,
                    sessionId: session.id,
                    exchangeId: exchangeId,
                    question: question,
                    answer: answer,
                    previousExchanges: exchangeData.isEmpty ? nil : exchangeData
                )
                OfflineSyncQueue.shared.enqueue(pendingRequest)
            }

            // Fallback to local service
            do {
                return try await questionService.generateClarityMirror(answer: answer)
            } catch {
                // Ultimate fallback if local service also fails
                return "Your reflection holds meaning worth exploring."
            }
        }
    }

    /// Generates Socrates' reaction using Firebase Functions with fallback to local service
    /// When offline, uses local fallback immediately and queues request for later sync
    /// - Parameters:
    ///   - question: The current Socratic question
    ///   - answer: The user's answer
    ///   - exchangeId: The ID of the exchange (for offline queue tracking)
    /// - Returns: The generated Socrates reaction text (body language/expression description)
    private func generateReactionWithFallback(
        question: String,
        answer: String,
        exchangeId: String
    ) async -> String {
        // Check if offline - use local fallback immediately and queue for later
        if !NetworkMonitor.shared.isConnected {
            isOffline = true
            #if DEBUG
            print("[DialogueSession] Offline: Using local reaction and queuing for sync")
            #endif

            // Queue the request for later sync
            let pendingRequest = PendingAIRequest(
                type: .socratesReaction,
                sessionId: session.id,
                exchangeId: exchangeId,
                question: question,
                answer: answer,
                previousExchanges: nil
            )
            OfflineSyncQueue.shared.enqueue(pendingRequest)

            // Return local fallback
            do {
                return try await questionService.generateReaction(answer: answer)
            } catch {
                return "Socrates nods thoughtfully..."
            }
        }

        isOffline = false
        let request = SocratesReactionRequest(
            question: question,
            answer: answer
        )

        do {
            // Try Firebase Functions first
            let reaction = try await firebaseFunctionsService.generateSocratesReaction(request: request)
            #if DEBUG
            print("[DialogueSession] Firebase Socrates reaction success")
            #endif
            return reaction
        } catch {
            #if DEBUG
            print("[DialogueSession] Firebase Socrates reaction failed, using fallback: \(error.localizedDescription)")
            #endif

            // Check if it was a network error - queue for later sync
            if let firebaseError = error as? FirebaseFunctionsError,
               case .networkError = firebaseError {
                isOffline = true
                let pendingRequest = PendingAIRequest(
                    type: .socratesReaction,
                    sessionId: session.id,
                    exchangeId: exchangeId,
                    question: question,
                    answer: answer,
                    previousExchanges: nil
                )
                OfflineSyncQueue.shared.enqueue(pendingRequest)
            }

            // Fallback to local question service
            do {
                return try await questionService.generateReaction(answer: answer)
            } catch {
                // Ultimate fallback if local service also fails
                return "Socrates nods thoughtfully..."
            }
        }
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
            clarityScore: nil, // Will be generated in SessionCompleteView
            wisdomQuote: nil,  // Will be generated in SessionCompleteView
            isComplete: true
        )

        do {
            try await repository.saveSession(session)
            phase = .sessionComplete
            showSessionComplete = true
        } catch {
            self.error = error
            // Still show session complete even if save fails
            phase = .sessionComplete
            showSessionComplete = true
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

    /// Returns the completed session for passing to SessionCompleteView
    func getCompletedSession() -> JournalSession {
        return session
    }

    /// Whether we have unsaved progress that would be lost
    var hasUnsavedProgress: Bool {
        !exchanges.isEmpty || !answerText.isEmpty
    }
}
#endif
