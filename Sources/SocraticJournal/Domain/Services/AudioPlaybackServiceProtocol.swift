// AudioPlaybackServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the audio playback service for playing recorded voice answers
/// Manages playback lifecycle, audio levels monitoring for waveform visualization,
/// and playback completion notifications
@MainActor
public protocol AudioPlaybackServiceProtocol: Sendable {
    /// Starts playing audio from the given file URL
    /// - Parameter url: Local file URL of the audio to play
    /// - Throws: Error if the audio file cannot be played
    func play(url: URL) throws

    /// Pauses the current playback
    func pause()

    /// Stops the current playback and resets position to the beginning
    func stop()

    /// Seeks to a specific time position in the audio
    /// - Parameter time: The time interval to seek to in seconds
    func seek(to time: TimeInterval)

    /// Whether the service is currently playing audio
    var isPlaying: Bool { get }

    /// The current playback position in seconds
    var currentTime: TimeInterval { get }

    /// The total duration of the currently loaded audio in seconds
    var duration: TimeInterval { get }

    /// An async stream of audio level values (0.0 to 1.0) for waveform visualization
    var audioLevels: AsyncStream<Float> { get }

    /// An async stream that emits when playback finishes naturally (reaches end of audio)
    var playbackFinished: AsyncStream<Void> { get }
}
