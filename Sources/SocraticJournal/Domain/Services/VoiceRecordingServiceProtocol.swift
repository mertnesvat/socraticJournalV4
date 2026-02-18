// VoiceRecordingServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol for voice recording operations.
/// Implementations handle microphone access, audio capture, and waveform generation.
@MainActor
public protocol VoiceRecordingServiceProtocol: AnyObject {
    /// Whether a recording session is currently active.
    var isRecording: Bool { get }

    /// The current audio amplitude (0.0 ... 1.0), updated during recording for live waveform.
    var currentAmplitude: Float { get }

    /// Elapsed time in seconds since recording started.
    var recordingDuration: TimeInterval { get }

    /// Begin recording a voice note.
    /// - Parameters:
    ///   - circleId: Optional circle this recording belongs to.
    ///   - promptId: Optional prompt this recording responds to.
    func startRecording(circleId: UUID?, promptId: UUID?) async throws

    /// Stop the current recording session and return the completed VoiceNote.
    /// The VoiceNote metadata is persisted to SwiftData.
    /// - Returns: The saved VoiceNote with waveform data populated.
    func stopRecording() async throws -> VoiceNote

    /// Cancel the current recording, discarding the audio file.
    func cancelRecording()
}
