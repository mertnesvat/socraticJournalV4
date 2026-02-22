// AnswerRevealViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import Observation

/// Phases of the answer reveal experience
public enum RevealPhase: Sendable {
    case celebration
    case reveal
    case summary
}

/// ViewModel driving the answer reveal experience after submitting a voice answer
/// Manages celebration animation, friend answer playback, and reaction state
@Observable
@MainActor
public final class AnswerRevealViewModel {
    // MARK: - State

    /// Current phase of the reveal experience
    public private(set) var revealPhase: RevealPhase = .celebration

    /// Friend answers loaded for the current question
    public private(set) var friendAnswers: [FriendAnswer] = []

    /// Index of the friend answer currently being played, if any
    public var currentlyPlayingIndex: Int?

    /// Map of answerId to user reaction (one reaction per answer)
    public var reactions: [String: ReactionType] = [:]

    /// Set of answer IDs that have been played (listened to)
    public var playedAnswerIds: Set<String> = []

    /// Whether data is currently loading
    public private(set) var isLoading: Bool = false

    /// Whether the share coming-soon alert is shown
    public var showShareAlert: Bool = false

    // MARK: - Dependencies

    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol
    private let reactionRepository: ReactionRepositoryProtocol
    private let playbackService: AudioPlaybackServiceProtocol
    private let questionId: String
    private let onDismiss: (() -> Void)?

    // MARK: - Initialization

    public init(
        questionId: String,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol,
        reactionRepository: ReactionRepositoryProtocol,
        playbackService: AudioPlaybackServiceProtocol,
        onDismiss: (() -> Void)? = nil
    ) {
        self.questionId = questionId
        self.voiceAnswerRepository = voiceAnswerRepository
        self.reactionRepository = reactionRepository
        self.playbackService = playbackService
        self.onDismiss = onDismiss
    }

    // MARK: - Actions

    /// Starts the reveal experience by loading friend answers, showing celebration, then auto-transitioning
    public func startReveal() async {
        isLoading = true
        revealPhase = .celebration

        // Load friend answers
        friendAnswers = await voiceAnswerRepository.getFriendAnswers(forQuestion: questionId)

        isLoading = false

        // Auto-transition from celebration to reveal after 2 seconds
        try? await Task.sleep(for: .seconds(2))
        revealPhase = .reveal
    }

    /// Plays the friend answer at the given index
    public func playFriendAnswer(at index: Int) async {
        guard index >= 0, index < friendAnswers.count else { return }

        let friendAnswer = friendAnswers[index]

        // If already playing this one, stop it
        if currentlyPlayingIndex == index {
            stopPlayback()
            return
        }

        // Stop any current playback
        stopPlayback()

        // Mark as currently playing
        currentlyPlayingIndex = index

        // Mark this answer as played
        playedAnswerIds.insert(friendAnswer.id)

        // Attempt to play audio if URL is available
        if let audioURL = friendAnswer.answer.audioFileURL {
            do {
                try playbackService.play(url: audioURL)

                // Listen for playback finished
                Task { [weak self] in
                    guard let self else { return }
                    for await _ in self.playbackService.playbackFinished {
                        self.currentlyPlayingIndex = nil
                        break
                    }
                }
            } catch {
                // If playback fails, simulate a brief play duration
                currentlyPlayingIndex = nil
            }
        } else {
            // No audio URL; simulate playback for mock data
            // Mark as played and immediately stop
            try? await Task.sleep(for: .milliseconds(500))
            currentlyPlayingIndex = nil
        }
    }

    /// Stops the current playback
    public func stopPlayback() {
        playbackService.stop()
        currentlyPlayingIndex = nil
    }

    /// Adds a reaction to a friend's answer (replaces previous reaction for same answer)
    public func addReaction(type: ReactionType, toAnswerId answerId: String) async {
        reactions[answerId] = type

        let reaction = AnswerReaction(
            answerId: answerId,
            reactorUserId: "user-current",
            type: type
        )
        await reactionRepository.addReaction(reaction)
    }

    /// Moves the phase to summary
    public func showSummary() {
        revealPhase = .summary
    }

    /// Dismisses the reveal sheet
    public func dismiss() {
        stopPlayback()
        onDismiss?()
    }
}
