// VoiceAnswer.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a voice-recorded answer to a daily question
public struct VoiceAnswer: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    public let questionId: String
    public let userId: String
    public let audioFileURL: URL?
    public let duration: TimeInterval
    public let createdAt: Date
    public var isListened: Bool

    public init(
        id: String = UUID().uuidString,
        questionId: String,
        userId: String,
        audioFileURL: URL? = nil,
        duration: TimeInterval = 0,
        createdAt: Date = Date(),
        isListened: Bool = false
    ) {
        self.id = id
        self.questionId = questionId
        self.userId = userId
        self.audioFileURL = audioFileURL
        self.duration = duration
        self.createdAt = createdAt
        self.isListened = isListened
    }
}
