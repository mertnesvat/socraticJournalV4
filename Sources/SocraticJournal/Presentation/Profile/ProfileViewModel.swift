// ProfileViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the User Profile & Streak Dashboard screen
@Observable
@MainActor
public final class ProfileViewModel {
    // MARK: - State

    private(set) var userProfile: UserProfile?
    private(set) var currentStreak: Int = 0
    private(set) var longestStreak: Int = 0
    private(set) var totalAnswers: Int = 12
    private(set) var weeklyActivity: [Bool] = [true, false, true, true, false, true, false]
    private(set) var friendCount: Int = 0
    var showingEditProfile: Bool = false
    var showingSettings: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    /// Mock recent answers for display
    struct RecentAnswer: Identifiable {
        let id = UUID()
        let date: Date
        let questionPreview: String
        let durationSeconds: Int

        var formattedDuration: String {
            let minutes = durationSeconds / 60
            let seconds = durationSeconds % 60
            if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            }
            return "\(seconds)s"
        }
    }

    private(set) var recentAnswers: [RecentAnswer] = []

    // MARK: - Dependencies

    private let userProfileRepository: UserProfileRepositoryProtocol
    private let streakRepository: StreakRepositoryProtocol
    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol
    private let friendshipRepository: FriendshipRepositoryProtocol

    // MARK: - Init

    public init(
        userProfileRepository: UserProfileRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol,
        friendshipRepository: FriendshipRepositoryProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.streakRepository = streakRepository
        self.voiceAnswerRepository = voiceAnswerRepository
        self.friendshipRepository = friendshipRepository
    }

    // MARK: - Actions

    /// Loads the user profile from the repository
    public func loadProfile() async {
        isLoading = true
        error = nil

        let profile = await userProfileRepository.getCurrentUser()
        userProfile = profile

        isLoading = false
    }

    /// Loads streak and stats data
    public func loadStats() async {
        // Load streak data
        let streak = await streakRepository.getCurrentStreak()
        currentStreak = streak.currentStreak
        longestStreak = streak.longestStreak

        // Load friend count
        friendCount = await friendshipRepository.getFriendCount()

        // Generate mock weekly activity
        weeklyActivity = generateMockWeeklyActivity()

        // Generate mock recent answers
        recentAnswers = generateMockRecentAnswers()

        // Mock total answers
        totalAnswers = 12
    }

    /// Updates the user profile
    public func updateProfile(_ profile: UserProfile) async {
        do {
            try await userProfileRepository.updateProfile(profile)
            userProfile = profile
        } catch {
            self.error = error
        }
    }

    // MARK: - Private Helpers

    private func generateMockWeeklyActivity() -> [Bool] {
        // Generate activity based on current streak
        if currentStreak >= 7 {
            return Array(repeating: true, count: 7)
        } else if currentStreak > 0 {
            var activity = Array(repeating: false, count: 7)
            // Fill from the end (most recent days)
            let calendar = Calendar.current
            let today = calendar.component(.weekday, from: Date())
            // Convert Sunday=1 to Monday=0 index
            let todayIndex = (today + 5) % 7
            for i in 0..<min(currentStreak, 7) {
                let index = (todayIndex - i + 7) % 7
                activity[index] = true
            }
            return activity
        }
        return [false, true, false, true, true, false, false]
    }

    private func generateMockRecentAnswers() -> [RecentAnswer] {
        let calendar = Calendar.current
        let now = Date()

        return [
            RecentAnswer(
                date: now,
                questionPreview: "What is one thing you would change about how people communicate?",
                durationSeconds: 45
            ),
            RecentAnswer(
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                questionPreview: "If you could have dinner with anyone, who would it be and why?",
                durationSeconds: 62
            ),
            RecentAnswer(
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                questionPreview: "What does success mean to you personally?",
                durationSeconds: 38
            ),
            RecentAnswer(
                date: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                questionPreview: "What is a belief you held strongly but have since changed?",
                durationSeconds: 55
            ),
            RecentAnswer(
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                questionPreview: "What role does silence play in your daily life?",
                durationSeconds: 30
            )
        ]
    }
}
#endif
