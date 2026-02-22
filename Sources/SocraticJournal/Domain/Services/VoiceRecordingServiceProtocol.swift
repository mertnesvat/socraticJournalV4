// VoiceRecordingServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the voice recording service for capturing audio answers
/// Manages recording lifecycle, audio levels monitoring, and microphone permissions
@MainActor
public protocol VoiceRecordingServiceProtocol: Sendable {
    /// Starts a new audio recording session
    /// - Throws: `VoiceRecordingError` if recording cannot be started
    func startRecording() throws

    /// Stops the current recording and returns the audio file URL
    /// - Returns: URL of the recorded audio file, or nil if recording was too short
    func stopRecording() -> URL?

    /// Cancels the current recording and discards the audio file
    func cancelRecording()

    /// Pauses the current recording
    func pauseRecording()

    /// Resumes a paused recording
    func resumeRecording()

    /// Whether the service is currently recording audio
    var isRecording: Bool { get }

    /// The current duration of the active recording in seconds
    var currentDuration: TimeInterval { get }

    /// An async stream of audio level values (0.0 to 1.0) for waveform visualization
    var audioLevels: AsyncStream<Float> { get }

    /// The current microphone permission status
    var permissionStatus: AudioPermissionStatus { get async }

    /// Requests microphone permission from the user
    /// - Returns: Whether permission was granted
    func requestPermission() async -> Bool
}
