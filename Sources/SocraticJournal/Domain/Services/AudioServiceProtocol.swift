// AudioServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining local audio recording and playback operations
public protocol AudioServiceProtocol: Sendable {
    /// Start recording a voice note
    func startRecording() async throws -> URL

    /// Stop recording and return the audio file URL
    func stopRecording() async throws -> URL

    /// Start playback of an audio file
    func startPlayback(url: URL) async throws

    /// Stop audio playback
    func stopPlayback() async

    /// Whether audio is currently being recorded
    func isRecording() async -> Bool

    /// Whether audio is currently being played
    func isPlaying() async -> Bool

    /// Get current recording duration
    func currentRecordingDuration() async -> TimeInterval

    /// Get current playback progress (0.0 to 1.0)
    func playbackProgress() async -> Double

    /// Stream of audio meter levels during recording (normalized 0.0 to 1.0)
    var meterLevelStream: AsyncStream<Float> { get }

    /// Stream of playback progress updates
    var playbackProgressStream: AsyncStream<Double> { get }

    /// Extract waveform data from an audio file
    func extractWaveform(from url: URL, samples: Int) async throws -> [Float]

    /// Request microphone permission
    func requestMicrophonePermission() async -> Bool
}
