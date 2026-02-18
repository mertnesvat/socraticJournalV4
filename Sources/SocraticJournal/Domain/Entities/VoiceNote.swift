// VoiceNote.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents a voice note recorded as a response to a daily prompt
public struct VoiceNote: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let circleId: String
    public let promptId: String
    public let authorId: String
    public var audioURL: String
    public let duration: TimeInterval
    public var transcript: String?
    public let createdAt: Date
    public var waveformData: [Float]
    public var isListened: Bool

    public init(
        id: String = UUID().uuidString,
        circleId: String,
        promptId: String,
        authorId: String,
        audioURL: String,
        duration: TimeInterval,
        transcript: String? = nil,
        createdAt: Date = Date(),
        waveformData: [Float] = [],
        isListened: Bool = false
    ) {
        self.id = id
        self.circleId = circleId
        self.promptId = promptId
        self.authorId = authorId
        self.audioURL = audioURL
        self.duration = duration
        self.transcript = transcript
        self.createdAt = createdAt
        self.waveformData = waveformData
        self.isListened = isListened
    }

    /// Formatted duration string (e.g., "0:23")
    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Truncated transcript for preview display
    public var transcriptSnippet: String? {
        guard let transcript, !transcript.isEmpty else { return nil }
        if transcript.count <= 80 { return transcript }
        return String(transcript.prefix(80)) + "..."
    }

    public static let minDuration: TimeInterval = 5
    public static let maxDuration: TimeInterval = 60
    public static let recommendedMinDuration: TimeInterval = 15
    public static let recommendedMaxDuration: TimeInterval = 30
}
