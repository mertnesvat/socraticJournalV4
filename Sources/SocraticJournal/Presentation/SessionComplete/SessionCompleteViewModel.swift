// SessionCompleteViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Session Complete screen
@Observable
@MainActor
public final class SessionCompleteViewModel {
    // MARK: - State

    /// The completed session
    private(set) var session: JournalSession

    /// Calculated clarity score
    private(set) var clarityScore: ClarityScore?

    /// Generated wisdom quote
    private(set) var wisdomQuote: WisdomQuote?

    /// Loading state
    private(set) var isLoading: Bool = false

    /// Error state
    private(set) var error: Error?

    /// Whether score animation should be shown
    var showScoreAnimation: Bool = false

    // MARK: - Dependencies

    private let clarityScoreService: ClarityScoreServiceProtocol
    private let repository: JournalRepositoryProtocol

    // MARK: - Callbacks

    var onWriteLetter: ((JournalSession) -> Void)?
    var onBackToHome: (() -> Void)?

    // MARK: - Init

    public init(
        session: JournalSession,
        clarityScoreService: ClarityScoreServiceProtocol,
        repository: JournalRepositoryProtocol
    ) {
        self.session = session
        self.clarityScoreService = clarityScoreService
        self.repository = repository
    }

    // MARK: - Computed Properties

    /// The total score for display (0-100)
    var displayScore: Int {
        clarityScore?.total ?? 0
    }

    /// The score label (e.g., "Deep Dive")
    var scoreLabel: String {
        clarityScore?.label ?? ""
    }

    /// The personalized message
    var personalizedMessage: String {
        clarityScore?.message ?? ""
    }

    /// Completion component score (0-100)
    var completionScore: Int {
        clarityScore?.completion ?? 0
    }

    /// Depth component score (0-100)
    var depthScore: Int {
        clarityScore?.depth ?? 0
    }

    /// Emotional component score (0-100)
    var emotionalScore: Int {
        clarityScore?.emotional ?? 0
    }

    /// Score quality for color styling
    var scoreQuality: ScoreQuality {
        clarityScore?.quality ?? .quick
    }

    // MARK: - Actions

    /// Load and calculate the clarity score
    public func loadResults() async {
        isLoading = true
        error = nil

        do {
            // Calculate clarity score
            let score = try await clarityScoreService.calculateScore(from: session.exchanges)
            self.clarityScore = score

            // Generate wisdom quote
            let quote = try await clarityScoreService.generateWisdomQuote(for: session.exchanges, score: score)
            self.wisdomQuote = quote

            // Update session with score and quote
            var updatedSession = session
            updatedSession = JournalSession(
                id: session.id,
                createdAt: session.createdAt,
                exchanges: session.exchanges,
                clarityScore: score,
                wisdomQuote: quote,
                isComplete: true
            )
            self.session = updatedSession

            // Save updated session
            try await repository.saveSession(updatedSession)

            // Trigger animation after slight delay
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            showScoreAnimation = true

        } catch {
            self.error = error
            // Provide fallback score
            self.clarityScore = ClarityScore(
                total: 50,
                completion: 50,
                depth: 50,
                emotional: 50,
                label: "Thoughtful Reflection",
                message: "Thank you for taking time to reflect today."
            )
            self.wisdomQuote = WisdomQuote(
                text: "The unexamined life is not worth living.",
                author: "Socrates"
            )
            showScoreAnimation = true
        }

        isLoading = false
    }

    /// Navigate to write letter screen
    public func writeLetter() {
        onWriteLetter?(session)
    }

    /// Navigate back to home
    public func backToHome() {
        onBackToHome?()
    }
}
#endif
