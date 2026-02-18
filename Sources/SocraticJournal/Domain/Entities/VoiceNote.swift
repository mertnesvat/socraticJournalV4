// VoiceNote.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// A recorded voice note, stored locally as an M4A audio file.
/// Metadata is persisted via SwiftData; the actual audio lives on disk.
@Model
public final class VoiceNote {
    @Attribute(.unique) public var id: UUID
    /// Relative path from Documents directory (e.g., "VoiceNotes/{circleId}/{date}/{noteId}.m4a").
    /// Stored as a string so SwiftData can persist it without URL encoding issues.
    public var filePath: String
    public var duration: TimeInterval
    /// Amplitude samples (50-100 floats in 0...1 range) for waveform visualization.
    public var waveformData: [Float]
    public var createdAt: Date
    /// Optional link to the circle this note belongs to.
    public var circleId: UUID?
    /// Optional link to the prompt this note responds to.
    public var promptId: UUID?
    /// The user who recorded this note.
    public var userId: UUID?
    /// Speech-to-text transcript of the audio, populated after transcription completes.
    public var transcript: String?

    /// Absolute file URL computed from the stored relative path.
    public var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(filePath)
    }

    public init(
        id: UUID = UUID(),
        filePath: String,
        duration: TimeInterval,
        waveformData: [Float] = [],
        createdAt: Date = Date(),
        circleId: UUID? = nil,
        promptId: UUID? = nil,
        userId: UUID? = nil,
        transcript: String? = nil
    ) {
        self.id = id
        self.filePath = filePath
        self.duration = duration
        self.waveformData = waveformData
        self.createdAt = createdAt
        self.circleId = circleId
        self.promptId = promptId
        self.userId = userId
        self.transcript = transcript
    }
}
