// DailyQuestionFeedViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import Observation

/// ViewModel driving the Daily Question Feed (Today tab)
/// Coordinates question loading, answer state, friend answers, and streak data
@Observable
@MainActor
public final class DailyQuestionFeedViewModel {
    // MARK: - Published State

    /// Today's active question
    public private(set) var todaysQuestion: DailyQuestion?

    /// Whether the current user has answered today's question
    public private(set) var hasAnsweredToday: Bool = false

    /// The current user's answer for today's question (if answered)
    public private(set) var myAnswer: VoiceAnswer?

    /// Friend answers for today's question
    public private(set) var friendAnswers: [FriendAnswer] = []

    /// The current user's active streak
    public private(set) var currentStreak: AnswerStreak?

    /// Loading state
    public private(set) var isLoading: Bool = false

    /// Error state
    public private(set) var error: Error?

    /// Controls presentation of the recording sheet
    public var showRecordingSheet: Bool = false

    /// Controls presentation of the reveal sheet
    public var showRevealSheet: Bool = false

    /// History of past daily questions
    public private(set) var questionHistory: [DailyQuestion] = []

    // MARK: - Dependencies

    private let questionRepository: QuestionRepositoryProtocol
    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol
    private let friendshipRepository: FriendshipRepositoryProtocol
    private let streakRepository: StreakRepositoryProtocol

    // MARK: - Initialization

    public init(
        questionRepository: QuestionRepositoryProtocol,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol,
        friendshipRepository: FriendshipRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol
    ) {
        self.questionRepository = questionRepository
        self.voiceAnswerRepository = voiceAnswerRepository
        self.friendshipRepository = friendshipRepository
        self.streakRepository = streakRepository
    }

    // MARK: - Actions

    /// Loads today's question, checks answer state, loads friend answers, and fetches streak
    public func loadTodaysQuestion() async {
        isLoading = true
        error = nil

        do {
            // Load today's question
            let question = await questionRepository.getTodaysQuestion()
            todaysQuestion = question

            // Check if user has answered today
            hasAnsweredToday = await voiceAnswerRepository.hasAnsweredToday()

            // Load user's own answer for this question
            myAnswer = await voiceAnswerRepository.getMyAnswer(forQuestion: question.id)

            // Load friend answers for today's question
            friendAnswers = await voiceAnswerRepository.getFriendAnswers(forQuestion: question.id)

            // Load current streak
            currentStreak = await streakRepository.getCurrentStreak()

            // Load question history
            questionHistory = await questionRepository.getQuestionHistory()
        }

        isLoading = false
    }

    /// Reloads all feed data
    public func refreshFeed() async {
        await loadTodaysQuestion()
    }

    /// Triggers the recording sheet presentation
    public func onRecordButtonTapped() {
        showRecordingSheet = true
    }

    /// Called after a successful answer submission; refreshes the feed to show unlocked state
    public func onAnswerSubmitted() async {
        await refreshFeed()
    }
}
