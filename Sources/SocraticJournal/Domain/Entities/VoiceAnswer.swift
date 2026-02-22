// VoiceAnswer.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A voice-recorded answer to a daily question
public struct VoiceAnswer: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let questionId: String
    public let userId: String
    public var audioURL: String
    public let duration: TimeInterval
    public let createdAt: Date
    public var isListened: Bool

    public init(
        id: String,
        questionId: String,
        userId: String,
        audioURL: String,
        duration: TimeInterval,
        createdAt: Date,
        isListened: Bool = false
    ) {
        self.id = id
        self.questionId = questionId
        self.userId = userId
        self.audioURL = audioURL
        self.duration = duration
        self.createdAt = createdAt
        self.isListened = isListened
    }
}
