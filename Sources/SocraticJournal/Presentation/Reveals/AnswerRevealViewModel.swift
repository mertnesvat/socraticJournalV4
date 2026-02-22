// AnswerRevealViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel managing the answer reveal screen where users unlock and listen to friends' voice answers
@Observable
@MainActor
public final class AnswerRevealViewModel {

    // MARK: - State

    public private(set) var reveals: [AnswerReveal] = []
    public private(set) var friendAnswers: [String: VoiceAnswer] = [:]  // answerId -> VoiceAnswer
    public private(set) var friends: [String: User] = [:]               // userId -> User
    public private(set) var hasAnswered: Bool = false
    public private(set) var isLoading: Bool = false
    public private(set) var currentlyPlayingId: String?
    public private(set) var errorMessage: String?
    public private(set) var reactions: [String: String] = [:]           // revealId -> emoji

    let questionId: String

    // MARK: - Dependencies

    private let revealService: AnswerRevealServiceProtocol
    private let friendService: FriendServiceProtocol
    private let voiceService: VoiceRecordingServiceProtocol

    // MARK: - Computed

    /// Number of unlocked reveals
    public var answeredCount: Int {
        reveals.filter { $0.isUnlocked }.count
    }

    /// Total friend answers available
    public var totalFriendCount: Int {
        reveals.count
    }

    /// Navigation subtitle text (e.g. "3 of 5 friends answered")
    public var subtitleText: String {
        if reveals.isEmpty {
            return "No friends answered yet"
        }
        return "\(totalFriendCount) of \(friends.count) friends answered"
    }

    // MARK: - Init

    public init(
        questionId: String,
        revealService: AnswerRevealServiceProtocol,
        friendService: FriendServiceProtocol,
        voiceService: VoiceRecordingServiceProtocol
    ) {
        self.questionId = questionId
        self.revealService = revealService
        self.friendService = friendService
        self.voiceService = voiceService
    }

    // MARK: - Actions

    /// Loads reveals, friends, and answer state
    public func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load in parallel
            async let revealsResult = revealService.getRevealsForQuestion(questionId: questionId)
            async let friendsResult = friendService.getFriends()
            async let answeredResult = revealService.hasAnsweredQuestion(questionId: questionId)

            let (loadedReveals, loadedFriends, answered) = try await (revealsResult, friendsResult, answeredResult)

            reveals = loadedReveals
            hasAnswered = answered

            // Build friends lookup by userId
            var friendsMap: [String: User] = [:]
            for friend in loadedFriends {
                friendsMap[friend.id] = friend
            }
            friends = friendsMap

            // Fetch voice answers for unlocked reveals
            for reveal in loadedReveals where reveal.isUnlocked {
                do {
                    let answer = try await revealService.getFriendAnswer(answerId: reveal.friendAnswerId)
                    friendAnswers[reveal.friendAnswerId] = answer
                } catch {
                    // Non-fatal: skip this answer
                    #if DEBUG
                    print("[AnswerRevealVM] Failed to fetch answer \(reveal.friendAnswerId): \(error)")
                    #endif
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Plays or unlocks and plays a friend's answer
    public func playFriendAnswer(revealId: String) async {
        guard let index = reveals.firstIndex(where: { $0.id == revealId }) else { return }

        // If currently playing this one, stop it
        if currentlyPlayingId == revealId {
            await stopPlayback()
            return
        }

        // Stop any current playback first
        if currentlyPlayingId != nil {
            await stopPlayback()
        }

        let reveal = reveals[index]

        // Unlock if needed
        if !reveal.isUnlocked {
            do {
                let unlocked = try await revealService.unlockAnswer(revealId: revealId)
                reveals[index] = unlocked

                // Fetch the friend's voice answer
                let answer = try await revealService.getFriendAnswer(answerId: unlocked.friendAnswerId)
                friendAnswers[unlocked.friendAnswerId] = answer
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }

        // Play the audio
        let updatedReveal = reveals[index]
        guard let answer = friendAnswers[updatedReveal.friendAnswerId] else { return }

        do {
            currentlyPlayingId = revealId
            try await voiceService.playRecording(url: answer.audioURL)
        } catch {
            // Playback may fail for mock URLs -- that is expected in dev
            currentlyPlayingId = revealId
            #if DEBUG
            print("[AnswerRevealVM] Playback error (expected for mock URLs): \(error)")
            #endif
        }
    }

    /// Stops any current playback
    public func stopPlayback() async {
        await voiceService.stopPlayback()
        currentlyPlayingId = nil
    }

    /// Adds an emoji reaction to a reveal
    public func addReaction(revealId: String, emoji: String) {
        if reactions[revealId] == emoji {
            reactions.removeValue(forKey: revealId)
        } else {
            reactions[revealId] = emoji
        }
    }

    // MARK: - Helpers

    /// Returns the User who authored the friend answer for a given reveal
    public func friendForReveal(_ reveal: AnswerReveal) -> User? {
        guard let answer = friendAnswers[reveal.friendAnswerId] ?? voiceAnswerFromMock(reveal.friendAnswerId) else {
            return nil
        }
        return friends[answer.userId]
    }

    /// Returns the VoiceAnswer for a given reveal
    public func answerForReveal(_ reveal: AnswerReveal) -> VoiceAnswer? {
        return friendAnswers[reveal.friendAnswerId]
    }

    /// Fallback: look up voice answer from mock data for display purposes
    private func voiceAnswerFromMock(_ answerId: String) -> VoiceAnswer? {
        return MockDataProvider.voiceAnswers.first { $0.id == answerId }
    }

    /// Returns friend User from mock data for a reveal even if not yet fetched
    public func friendForRevealFallback(_ reveal: AnswerReveal) -> User? {
        // Try the fetched friends first
        if let friend = friendForReveal(reveal) {
            return friend
        }
        // Fallback: find the voice answer in mock data and look up the user
        if let answer = MockDataProvider.voiceAnswers.first(where: { $0.id == reveal.friendAnswerId }) {
            return MockDataProvider.allUsers.first { $0.id == answer.userId }
        }
        return nil
    }
}

#endif
