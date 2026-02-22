// FriendAnswer.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a friend's answer to a daily question, with unlock state
public struct FriendAnswer: Codable, Sendable, Identifiable, Hashable {
    public let answer: VoiceAnswer
    public let friend: UserProfile
    public let isUnlocked: Bool

    /// Uses the underlying answer's id as the stable identifier
    public var id: String { answer.id }

    public init(
        answer: VoiceAnswer,
        friend: UserProfile,
        isUnlocked: Bool = false
    ) {
        self.answer = answer
        self.friend = friend
        self.isUnlocked = isUnlocked
    }
}
