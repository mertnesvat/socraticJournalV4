// VoiceRecordingServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for voice recording capabilities
public protocol VoiceRecordingServiceProtocol: AnyObject {
    /// Start recording audio to the specified URL
    func startRecording(to url: URL) throws

    /// Stop recording and return the URL of the recorded file
    func stopRecording() -> URL?

    /// Whether recording is currently in progress
    var isRecording: Bool { get }

    /// Current recording duration in seconds (updated during recording)
    var currentDuration: TimeInterval { get }

    /// Extract waveform amplitude samples from an audio file
    func extractWaveform(from url: URL, sampleCount: Int) async throws -> [Float]
}

/// Protocol for audio playback capabilities
public protocol AudioPlaybackServiceProtocol: AnyObject {
    /// Play audio from a URL
    func play(url: URL) throws

    /// Pause playback
    func pause()

    /// Stop playback
    func stop()

    /// Whether audio is currently playing
    var isPlaying: Bool { get }

    /// Current playback position in seconds
    var currentTime: TimeInterval { get }

    /// Total duration of the loaded audio
    var duration: TimeInterval { get }

    /// Set playback speed (1.0 = normal, 1.5 = faster, 2.0 = double)
    func setPlaybackSpeed(_ speed: Float)

    /// Seek to a specific time
    func seek(to time: TimeInterval)
}
