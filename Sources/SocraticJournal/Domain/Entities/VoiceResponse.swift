// VoiceResponse.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// A voice response links a VoiceNote to a Prompt and CircleMember within a Circle.
/// Tracks whether the current user has listened to this response.
@Model
public final class VoiceResponse {
    @Attribute(.unique) public var id: UUID
    /// The VoiceNote containing the audio recording.
    public var voiceNoteId: UUID
    /// The Prompt this response answers.
    public var promptId: UUID
    /// The CircleMember who recorded this response.
    public var memberId: UUID
    /// The Circle this response belongs to.
    public var circleId: UUID
    /// Whether the current user has listened to this response.
    public var isHeard: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        voiceNoteId: UUID,
        promptId: UUID,
        memberId: UUID,
        circleId: UUID,
        isHeard: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.voiceNoteId = voiceNoteId
        self.promptId = promptId
        self.memberId = memberId
        self.circleId = circleId
        self.isHeard = isHeard
        self.createdAt = createdAt
    }
}
