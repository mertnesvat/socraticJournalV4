// MockDataProvider.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Central mock data store providing realistic sample data for development and previews
public enum MockDataProvider {

    // MARK: - Date Helpers

    private static let calendar = Calendar.current

    private static func date(daysAgo: Int) -> Date {
        calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 10
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }

    // MARK: - Users

    /// The current authenticated user
    public static let currentUser = User(
        id: "user_alex",
        displayName: "Alex Rivera",
        username: "alexriv",
        avatarURL: nil,
        createdAt: date(year: 2025, month: 11, day: 1),
        streakCount: 7,
        friendCount: 5
    )

    /// All mock friend users
    public static let friends: [User] = [
        User(
            id: "user_luna",
            displayName: "Luna Martinez",
            username: "lunaa",
            avatarURL: nil,
            createdAt: date(year: 2025, month: 11, day: 5),
            streakCount: 12,
            friendCount: 8
        ),
        User(
            id: "user_kai",
            displayName: "Kai Chen",
            username: "kaichen_",
            avatarURL: nil,
            createdAt: date(year: 2025, month: 11, day: 10),
            streakCount: 3,
            friendCount: 4
        ),
        User(
            id: "user_zara",
            displayName: "Zara Williams",
            username: "zaranotsorry",
            avatarURL: nil,
            createdAt: date(year: 2025, month: 12, day: 1),
            streakCount: 15,
            friendCount: 11
        ),
        User(
            id: "user_marcus",
            displayName: "Marcus Johnson",
            username: "marcusjay",
            avatarURL: nil,
            createdAt: date(year: 2025, month: 12, day: 15),
            streakCount: 5,
            friendCount: 6
        ),
        User(
            id: "user_priya",
            displayName: "Priya Patel",
            username: "priyavibes",
            avatarURL: nil,
            createdAt: date(year: 2026, month: 1, day: 3),
            streakCount: 9,
            friendCount: 7
        )
    ]

    /// All users including the current user
    public static let allUsers: [User] = [currentUser] + friends

    // MARK: - Friendships

    public static let friendships: [Friendship] = [
        Friendship(id: "fs_1", userId: "user_alex", friendId: "user_luna", status: .accepted, createdAt: date(daysAgo: 60)),
        Friendship(id: "fs_2", userId: "user_alex", friendId: "user_kai", status: .accepted, createdAt: date(daysAgo: 45)),
        Friendship(id: "fs_3", userId: "user_alex", friendId: "user_zara", status: .accepted, createdAt: date(daysAgo: 30)),
        Friendship(id: "fs_4", userId: "user_alex", friendId: "user_marcus", status: .accepted, createdAt: date(daysAgo: 20)),
        Friendship(id: "fs_5", userId: "user_alex", friendId: "user_priya", status: .accepted, createdAt: date(daysAgo: 10)),
        Friendship(id: "fs_6", userId: "user_luna", friendId: "user_kai", status: .accepted, createdAt: date(daysAgo: 50)),
        Friendship(id: "fs_7", userId: "user_zara", friendId: "user_marcus", status: .accepted, createdAt: date(daysAgo: 25))
    ]

    /// Pending incoming friend requests for the current user
    public static let incomingRequests: [Friendship] = [
        Friendship(id: "fs_pending_1", userId: "user_priya", friendId: "user_alex", status: .pending, createdAt: date(daysAgo: 1))
    ]

    /// Pending outgoing friend requests from the current user
    public static let sentRequests: [Friendship] = [
        Friendship(id: "fs_sent_1", userId: "user_alex", friendId: "user_kai", status: .pending, createdAt: date(daysAgo: 2))
    ]

    // MARK: - Friend Groups

    public static let friendGroups: [FriendGroup] = [
        FriendGroup(
            id: "group_1",
            name: "Squad",
            memberIds: ["user_luna", "user_kai", "user_zara"],
            createdAt: date(daysAgo: 30)
        ),
        FriendGroup(
            id: "group_2",
            name: "College Crew",
            memberIds: ["user_marcus", "user_priya"],
            createdAt: date(daysAgo: 20)
        ),
        FriendGroup(
            id: "group_3",
            name: "Hot Take Club",
            memberIds: ["user_luna", "user_zara", "user_marcus", "user_priya"],
            createdAt: date(daysAgo: 10)
        )
    ]

    // MARK: - Daily Questions

    /// Level 1 -- Ice Breakers
    private static let iceBreakerQuestions: [DailyQuestion] = [
        DailyQuestion(
            id: "q_ib_1",
            text: "What's a popular movie everyone loves that you think is actually trash?",
            category: .iceBreaker,
            level: 1,
            isActive: false,
            createdAt: date(daysAgo: 16),
            globalResponseCount: 2841,
            disagreementRatio: 0.62
        ),
        DailyQuestion(
            id: "q_ib_2",
            text: "Be honest -- do you wash your legs in the shower or just let the water run down?",
            category: .iceBreaker,
            level: 1,
            isActive: false,
            createdAt: date(daysAgo: 15),
            globalResponseCount: 3290,
            disagreementRatio: 0.55
        ),
        DailyQuestion(
            id: "q_ib_3",
            text: "What's something you pretend to like because everyone around you does?",
            category: .iceBreaker,
            level: 1,
            isActive: false,
            createdAt: date(daysAgo: 14),
            globalResponseCount: 1987,
            disagreementRatio: 0.48
        ),
        DailyQuestion(
            id: "q_ib_4",
            text: "If you could delete one app from everyone's phone, which one?",
            category: .iceBreaker,
            level: 1,
            isActive: false,
            createdAt: date(daysAgo: 13),
            globalResponseCount: 4102,
            disagreementRatio: 0.71
        )
    ]

    /// Level 2 -- Getting Spicy
    private static let gettingSpicyQuestions: [DailyQuestion] = [
        DailyQuestion(
            id: "q_gs_1",
            text: "What's a relationship red flag you've personally ignored?",
            category: .gettingSpicy,
            level: 2,
            isActive: false,
            createdAt: date(daysAgo: 12),
            globalResponseCount: 2156,
            disagreementRatio: 0.39
        ),
        DailyQuestion(
            id: "q_gs_2",
            text: "Who in your friend group would survive the longest in a zombie apocalypse? Who'd go first?",
            category: .gettingSpicy,
            level: 2,
            isActive: false,
            createdAt: date(daysAgo: 11),
            globalResponseCount: 3678,
            disagreementRatio: 0.58
        ),
        DailyQuestion(
            id: "q_gs_3",
            text: "What's an opinion you hold that would genuinely make people uncomfortable at a dinner party?",
            category: .gettingSpicy,
            level: 2,
            isActive: false,
            createdAt: date(daysAgo: 10),
            globalResponseCount: 2890,
            disagreementRatio: 0.67
        ),
        DailyQuestion(
            id: "q_gs_4",
            text: "If you had to bet your life savings -- does God exist or not?",
            category: .gettingSpicy,
            level: 2,
            isActive: false,
            createdAt: date(daysAgo: 9),
            globalResponseCount: 5412,
            disagreementRatio: 0.82
        )
    ]

    /// Level 3 -- Deep Dive
    private static let deepDiveQuestions: [DailyQuestion] = [
        DailyQuestion(
            id: "q_dd_1",
            text: "What's something you've never said out loud but think about at least once a week?",
            category: .deepDive,
            level: 3,
            isActive: false,
            createdAt: date(daysAgo: 8),
            globalResponseCount: 1543,
            disagreementRatio: 0.31
        ),
        DailyQuestion(
            id: "q_dd_2",
            text: "If your friend group had to vote one person out, who would it be and why?",
            category: .deepDive,
            level: 3,
            isActive: false,
            createdAt: date(daysAgo: 7),
            globalResponseCount: 2234,
            disagreementRatio: 0.74
        ),
        DailyQuestion(
            id: "q_dd_3",
            text: "What's the most selfish thing you've done that you'd do again?",
            category: .deepDive,
            level: 3,
            isActive: false,
            createdAt: date(daysAgo: 6),
            globalResponseCount: 1876,
            disagreementRatio: 0.45
        ),
        DailyQuestion(
            id: "q_dd_4",
            text: "Is there someone in your life you love but don't actually like?",
            category: .deepDive,
            level: 3,
            isActive: false,
            createdAt: date(daysAgo: 5),
            globalResponseCount: 2567,
            disagreementRatio: 0.52
        )
    ]

    /// Level 4 -- Debate Triggers
    private static let debateTriggerQuestions: [DailyQuestion] = [
        DailyQuestion(
            id: "q_dt_1",
            text: "Is it ever okay to go through your partner's phone?",
            category: .debateTrigger,
            level: 4,
            isActive: false,
            createdAt: date(daysAgo: 4),
            globalResponseCount: 4890,
            disagreementRatio: 0.88
        ),
        DailyQuestion(
            id: "q_dt_2",
            text: "Should you tell your best friend their partner is cheating -- even if it'll destroy the friendship?",
            category: .debateTrigger,
            level: 4,
            isActive: false,
            createdAt: date(daysAgo: 3),
            globalResponseCount: 3901,
            disagreementRatio: 0.76
        ),
        DailyQuestion(
            id: "q_dt_3",
            text: "Rich and lonely or broke with the best people around you?",
            category: .debateTrigger,
            level: 4,
            isActive: false,
            createdAt: date(daysAgo: 2),
            globalResponseCount: 5234,
            disagreementRatio: 0.69
        ),
        DailyQuestion(
            id: "q_dt_4",
            text: "Could you forgive cheating if everything else was perfect?",
            category: .debateTrigger,
            level: 4,
            isActive: true,
            createdAt: date(daysAgo: 0),
            globalResponseCount: 1203,
            disagreementRatio: 0.81
        ),
        DailyQuestion(
            id: "q_dt_5",
            text: "Is it selfish to not want kids, or is having kids the selfish act?",
            category: .debateTrigger,
            level: 4,
            isActive: false,
            createdAt: date(daysAgo: 1),
            globalResponseCount: 6102,
            disagreementRatio: 0.91
        )
    ]

    /// All questions across all levels (17 total)
    public static let allQuestions: [DailyQuestion] =
        iceBreakerQuestions + gettingSpicyQuestions + deepDiveQuestions + debateTriggerQuestions

    /// Today's active question
    public static var todaysQuestion: DailyQuestion {
        allQuestions.first(where: { $0.isActive }) ?? allQuestions[0]
    }

    /// Previously active questions (history)
    public static var questionHistory: [DailyQuestion] {
        allQuestions.filter { !$0.isActive }.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Voice Answers

    public static let voiceAnswers: [VoiceAnswer] = [
        // Current user answers
        VoiceAnswer(
            id: "va_alex_q_dt_4",
            questionId: "q_dt_4",
            userId: "user_alex",
            audioURL: "recordings/alex_qdt4_20260222.m4a",
            duration: 42.5,
            createdAt: date(daysAgo: 0),
            isListened: false
        ),
        VoiceAnswer(
            id: "va_alex_q_dt_5",
            questionId: "q_dt_5",
            userId: "user_alex",
            audioURL: "recordings/alex_qdt5_20260221.m4a",
            duration: 38.0,
            createdAt: date(daysAgo: 1),
            isListened: false
        ),
        VoiceAnswer(
            id: "va_alex_q_dt_3",
            questionId: "q_dt_3",
            userId: "user_alex",
            audioURL: "recordings/alex_qdt3_20260220.m4a",
            duration: 55.2,
            createdAt: date(daysAgo: 2),
            isListened: false
        ),
        // Luna's answers
        VoiceAnswer(
            id: "va_luna_q_dt_4",
            questionId: "q_dt_4",
            userId: "user_luna",
            audioURL: "recordings/luna_qdt4_20260222.m4a",
            duration: 35.8,
            createdAt: date(daysAgo: 0),
            isListened: false
        ),
        VoiceAnswer(
            id: "va_luna_q_dt_5",
            questionId: "q_dt_5",
            userId: "user_luna",
            audioURL: "recordings/luna_qdt5_20260221.m4a",
            duration: 28.3,
            createdAt: date(daysAgo: 1),
            isListened: true
        ),
        // Kai's answers
        VoiceAnswer(
            id: "va_kai_q_dt_4",
            questionId: "q_dt_4",
            userId: "user_kai",
            audioURL: "recordings/kai_qdt4_20260222.m4a",
            duration: 61.0,
            createdAt: date(daysAgo: 0),
            isListened: false
        ),
        // Zara's answers
        VoiceAnswer(
            id: "va_zara_q_dt_4",
            questionId: "q_dt_4",
            userId: "user_zara",
            audioURL: "recordings/zara_qdt4_20260222.m4a",
            duration: 47.1,
            createdAt: date(daysAgo: 0),
            isListened: false
        ),
        VoiceAnswer(
            id: "va_zara_q_dt_3",
            questionId: "q_dt_3",
            userId: "user_zara",
            audioURL: "recordings/zara_qdt3_20260220.m4a",
            duration: 52.6,
            createdAt: date(daysAgo: 2),
            isListened: true
        ),
        // Marcus's answers
        VoiceAnswer(
            id: "va_marcus_q_dt_4",
            questionId: "q_dt_4",
            userId: "user_marcus",
            audioURL: "recordings/marcus_qdt4_20260222.m4a",
            duration: 33.9,
            createdAt: date(daysAgo: 0),
            isListened: false
        ),
        // Priya's answers
        VoiceAnswer(
            id: "va_priya_q_dt_4",
            questionId: "q_dt_4",
            userId: "user_priya",
            audioURL: "recordings/priya_qdt4_20260222.m4a",
            duration: 44.7,
            createdAt: date(daysAgo: 0),
            isListened: false
        ),
        VoiceAnswer(
            id: "va_priya_q_dt_5",
            questionId: "q_dt_5",
            userId: "user_priya",
            audioURL: "recordings/priya_qdt5_20260221.m4a",
            duration: 39.2,
            createdAt: date(daysAgo: 1),
            isListened: false
        )
    ]

    // MARK: - Answer Reveals

    public static let answerReveals: [AnswerReveal] = [
        // Today's question reveals (some unlocked, some locked)
        AnswerReveal(
            id: "reveal_luna_dt4",
            myAnswerId: "va_alex_q_dt_4",
            friendAnswerId: "va_luna_q_dt_4",
            questionId: "q_dt_4",
            isUnlocked: true,
            unlockedAt: date(daysAgo: 0)
        ),
        AnswerReveal(
            id: "reveal_kai_dt4",
            myAnswerId: "va_alex_q_dt_4",
            friendAnswerId: "va_kai_q_dt_4",
            questionId: "q_dt_4",
            isUnlocked: false,
            unlockedAt: nil
        ),
        AnswerReveal(
            id: "reveal_zara_dt4",
            myAnswerId: "va_alex_q_dt_4",
            friendAnswerId: "va_zara_q_dt_4",
            questionId: "q_dt_4",
            isUnlocked: true,
            unlockedAt: date(daysAgo: 0)
        ),
        AnswerReveal(
            id: "reveal_marcus_dt4",
            myAnswerId: "va_alex_q_dt_4",
            friendAnswerId: "va_marcus_q_dt_4",
            questionId: "q_dt_4",
            isUnlocked: false,
            unlockedAt: nil
        ),
        AnswerReveal(
            id: "reveal_priya_dt4",
            myAnswerId: "va_alex_q_dt_4",
            friendAnswerId: "va_priya_q_dt_4",
            questionId: "q_dt_4",
            isUnlocked: false,
            unlockedAt: nil
        ),
        // Yesterday's question reveals
        AnswerReveal(
            id: "reveal_luna_dt5",
            myAnswerId: "va_alex_q_dt_5",
            friendAnswerId: "va_luna_q_dt_5",
            questionId: "q_dt_5",
            isUnlocked: true,
            unlockedAt: date(daysAgo: 1)
        ),
        AnswerReveal(
            id: "reveal_priya_dt5",
            myAnswerId: "va_alex_q_dt_5",
            friendAnswerId: "va_priya_q_dt_5",
            questionId: "q_dt_5",
            isUnlocked: true,
            unlockedAt: date(daysAgo: 1)
        )
    ]

    // MARK: - Streaks

    public static let currentUserStreak = QuestionStreak(
        userId: "user_alex",
        currentStreak: 7,
        longestStreak: 12,
        lastAnsweredDate: date(daysAgo: 0)
    )

    public static let allStreaks: [QuestionStreak] = [
        currentUserStreak,
        QuestionStreak(userId: "user_luna", currentStreak: 12, longestStreak: 20, lastAnsweredDate: date(daysAgo: 0)),
        QuestionStreak(userId: "user_kai", currentStreak: 3, longestStreak: 8, lastAnsweredDate: date(daysAgo: 0)),
        QuestionStreak(userId: "user_zara", currentStreak: 15, longestStreak: 15, lastAnsweredDate: date(daysAgo: 0)),
        QuestionStreak(userId: "user_marcus", currentStreak: 5, longestStreak: 11, lastAnsweredDate: date(daysAgo: 0)),
        QuestionStreak(userId: "user_priya", currentStreak: 9, longestStreak: 14, lastAnsweredDate: date(daysAgo: 0))
    ]

    // MARK: - Awards

    public static let awards: [SpicyTakeAward] = [
        SpicyTakeAward(
            id: "award_1",
            questionId: "q_gs_4",
            userId: "user_alex",
            weekNumber: 7,
            year: 2026,
            category: .mostControversial
        ),
        SpicyTakeAward(
            id: "award_2",
            questionId: "q_dt_1",
            userId: "user_alex",
            weekNumber: 6,
            year: 2026,
            category: .mostPassionate
        )
    ]
}
