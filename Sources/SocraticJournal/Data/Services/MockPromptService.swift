// MockPromptService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock prompt service for SwiftUI previews and testing.
/// Returns sample prompts without requiring SwiftData or a bundled JSON file.
@Observable
@MainActor
public final class MockPromptService: PromptServiceProtocol {
    // MARK: - State

    public var prompts: [Prompt] = []

    // MARK: - Init

    /// Creates a mock prompt service.
    /// - Parameter withSampleData: If true, populates with sample prompts.
    public init(withSampleData: Bool = true) {
        if withSampleData {
            prompts = Self.makeSamplePrompts()
        }
    }

    // MARK: - PromptServiceProtocol

    public func getTodaysPrompt(for circleId: UUID) async throws -> Prompt {
        if let existing = prompts.first(where: {
            $0.circleId == circleId
                && $0.dateAssigned != nil
                && Calendar.current.isDateInToday($0.dateAssigned!)
        }) {
            return existing
        }

        let prompt = Prompt(
            text: "What made you smile today?",
            category: .dailyMoments,
            depth: 1,
            dateAssigned: Date(),
            circleId: circleId,
            isSeen: false
        )
        prompts.append(prompt)
        return prompt
    }

    public func getPromptHistory(for circleId: UUID) async throws -> [Prompt] {
        prompts
            .filter { $0.circleId == circleId && $0.dateAssigned != nil }
            .sorted { ($0.dateAssigned ?? .distantPast) > ($1.dateAssigned ?? .distantPast) }
    }

    public func markPromptSeen(id: UUID) async throws {
        if let prompt = prompts.first(where: { $0.id == id }) {
            prompt.isSeen = true
        }
    }

    // MARK: - Feedback

    /// In-memory feedback storage for previews.
    private var feedbackStore: [UUID: PromptRating] = [:]

    public func submitFeedback(promptId: UUID, circleId: UUID, rating: PromptRating, category: PromptCategory) throws {
        feedbackStore[promptId] = rating
    }

    public func getFeedback(promptId: UUID, circleId: UUID) throws -> PromptFeedback? {
        guard let rating = feedbackStore[promptId] else { return nil }
        return PromptFeedback(
            promptId: promptId,
            circleId: circleId,
            rating: rating,
            category: .dailyMoments
        )
    }

    // MARK: - Streak

    /// Mock streak values for previews.
    public var mockCurrentStreak: Int = 5
    public var mockLongestStreak: Int = 12
    public var mockLastActiveDate: Date? = Date()

    public func computeStreak(for circleId: UUID) throws -> (current: Int, longest: Int, lastActiveDate: Date?) {
        return (current: mockCurrentStreak, longest: mockLongestStreak, lastActiveDate: mockLastActiveDate)
    }

    // MARK: - Sample Data

    private static func makeSamplePrompts() -> [Prompt] {
        let circleId = UUID()
        let calendar = Calendar.current

        return [
            Prompt(
                text: "What made you laugh today?",
                category: .dailyMoments,
                depth: 1,
                dateAssigned: Date(),
                circleId: circleId,
                isSeen: false
            ),
            Prompt(
                text: "What's a childhood memory that still makes you happy?",
                category: .nostalgia,
                depth: 2,
                dateAssigned: calendar.date(byAdding: .day, value: -1, to: Date()),
                circleId: circleId,
                isSeen: true
            ),
            Prompt(
                text: "Who made your day a little brighter recently?",
                category: .gratitude,
                depth: 2,
                dateAssigned: calendar.date(byAdding: .day, value: -2, to: Date()),
                circleId: circleId,
                isSeen: true
            ),
            Prompt(
                text: "What's something you've been carrying this week that you haven't told anyone?",
                category: .vulnerability,
                depth: 3,
                dateAssigned: calendar.date(byAdding: .day, value: -3, to: Date()),
                circleId: circleId,
                isSeen: true
            ),
            Prompt(
                text: "If you could relive one day from last year, which would it be?",
                category: .reflection,
                depth: 3,
                dateAssigned: calendar.date(byAdding: .day, value: -4, to: Date()),
                circleId: circleId,
                isSeen: true
            ),
            Prompt(
                text: "What's a song that always takes you back to a specific moment?",
                category: .nostalgia,
                depth: 1,
                dateAssigned: calendar.date(byAdding: .day, value: -5, to: Date()),
                circleId: circleId,
                isSeen: true
            ),
            Prompt(
                text: "What's something small that someone did for you that meant more than they know?",
                category: .gratitude,
                depth: 2,
                dateAssigned: calendar.date(byAdding: .day, value: -6, to: Date()),
                circleId: circleId,
                isSeen: true
            ),
        ]
    }
}
#endif
