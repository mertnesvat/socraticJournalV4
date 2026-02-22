// QuestionFeedViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel for the daily question feed -- the immersive home experience
@Observable
@MainActor
public final class QuestionFeedViewModel {
    // MARK: - State

    public private(set) var todaysQuestion: DailyQuestion?
    public private(set) var streak: QuestionStreak?
    public private(set) var hasAnsweredToday: Bool = false
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?

    /// Calculates the time remaining until midnight (next question)
    public var timeUntilNextQuestion: TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: now)
        ) else { return 0 }
        return max(0, tomorrow.timeIntervalSince(now))
    }

    // MARK: - Dependencies

    private let questionFeedService: QuestionFeedServiceProtocol
    private let userProfileService: UserProfileServiceProtocol

    // MARK: - Init

    public init(
        questionFeedService: QuestionFeedServiceProtocol,
        userProfileService: UserProfileServiceProtocol
    ) {
        self.questionFeedService = questionFeedService
        self.userProfileService = userProfileService
    }

    // MARK: - Actions

    /// Loads today's question and the user's streak data
    public func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let questionTask = questionFeedService.getTodaysQuestion()
            async let streakTask = userProfileService.getStreak()

            let fetchedQuestion = try await questionTask
            let fetchedStreak = try await streakTask

            todaysQuestion = fetchedQuestion
            streak = fetchedStreak

            // Check if user already answered today by comparing streak date
            if let lastAnswered = fetchedStreak.lastAnsweredDate {
                let calendar = Calendar.current
                hasAnsweredToday = calendar.isDateInToday(lastAnswered)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Marks the current question as answered by the user
    public func markAsAnswered() {
        hasAnsweredToday = true
    }
}
#endif
