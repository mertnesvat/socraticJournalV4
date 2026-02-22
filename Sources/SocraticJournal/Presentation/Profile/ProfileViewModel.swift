// ProfileViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel for the user profile screen
@Observable
@MainActor
public final class ProfileViewModel {
    // MARK: - State

    public private(set) var user: User?
    public private(set) var streak: QuestionStreak?
    public private(set) var awards: [SpicyTakeAward] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let userProfileService: UserProfileServiceProtocol

    // MARK: - Init

    public init(userProfileService: UserProfileServiceProtocol) {
        self.userProfileService = userProfileService
    }

    // MARK: - Computed Properties

    /// Number of questions the user has answered (mock value for MVP)
    public var questionsAnswered: Int {
        // In a real app this would come from a service; use streak data as proxy
        42
    }

    /// Last 7 days of streak activity (true = answered that day)
    public var weeklyStreakDays: [Bool] {
        guard let streak = streak, let lastDate = streak.lastAnsweredDate else {
            return Array(repeating: false, count: 7)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Build an array for the last 7 days (Mon through Sun of the current week)
        let weekday = calendar.component(.weekday, from: today)
        // Convert to Monday-based (Monday=1 ... Sunday=7)
        let mondayOffset = (weekday + 5) % 7  // days since Monday
        guard let mondayDate = calendar.date(byAdding: .day, value: -mondayOffset, to: today) else {
            return Array(repeating: false, count: 7)
        }

        let lastAnsweredDay = calendar.startOfDay(for: lastDate)
        let streakDays = streak.currentStreak

        return (0..<7).map { dayIndex in
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: mondayDate) else {
                return false
            }
            // A day is "answered" if it falls within the streak window ending at lastAnsweredDay
            let daysBetween = calendar.dateComponents([.day], from: date, to: lastAnsweredDay).day ?? 0
            return daysBetween >= 0 && daysBetween < streakDays && date <= today
        }
    }

    /// Whether today is within the current week for highlighting
    public var todayWeekdayIndex: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Monday-based index (0=Mon, 6=Sun)
        return (weekday + 5) % 7
    }

    /// Mock spicy takes data for the profile
    public var spicyTakes: [(question: String, reactionCount: Int)] {
        let questions = MockDataProvider.allQuestions
        return [
            (question: questions[7].text, reactionCount: 847),
            (question: questions[12].text, reactionCount: 632),
            (question: questions[3].text, reactionCount: 519)
        ]
    }

    // MARK: - Actions

    public func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let userResult = userProfileService.getCurrentUser()
            async let streakResult = userProfileService.getStreak()
            async let awardsResult = userProfileService.getAwards()

            user = try await userResult
            streak = try await streakResult
            awards = try await awardsResult
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
#endif
