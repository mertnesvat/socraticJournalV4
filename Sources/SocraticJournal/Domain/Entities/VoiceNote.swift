// VoiceNote.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a voice note response to a daily prompt
public struct VoiceNote: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let circleId: UUID
    public let promptId: UUID
    public let userId: UUID
    /// Path to the audio file on local disk (relative to documents directory)
    public var localAudioPath: String
    /// Duration of the voice note in seconds
    public let duration: TimeInterval
    /// Transcript of the voice note (generated via Speech framework)
    public var transcript: String?
    public let createdAt: Date
    /// Waveform amplitude samples for visualization (normalized 0-1)
    public var waveformSamples: [Float]?

    public init(
        id: UUID = UUID(),
        circleId: UUID,
        promptId: UUID,
        userId: UUID,
        localAudioPath: String,
        duration: TimeInterval,
        transcript: String? = nil,
        createdAt: Date = Date(),
        waveformSamples: [Float]? = nil
    ) {
        self.id = id
        self.circleId = circleId
        self.promptId = promptId
        self.userId = userId
        self.localAudioPath = localAudioPath
        self.duration = duration
        self.transcript = transcript
        self.createdAt = createdAt
        self.waveformSamples = waveformSamples
    }

    /// Formatted duration string (e.g., "0:23")
    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Truncated transcript for snippet display (~20 words)
    public var transcriptSnippet: String? {
        guard let transcript = transcript else { return nil }
        let words = transcript.split(separator: " ")
        if words.count <= 20 { return transcript }
        return words.prefix(20).joined(separator: " ") + "..."
    }
}
