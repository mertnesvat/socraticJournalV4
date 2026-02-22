// VoiceRecordingServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service for recording and playing back voice answers
public protocol VoiceRecordingServiceProtocol: Sendable {
    /// Starts recording audio from the microphone
    func startRecording() async throws

    /// Stops the current recording and returns the file URL path
    func stopRecording() async throws -> String

    /// Plays back a recording from the given URL
    func playRecording(url: String) async throws

    /// Stops any currently playing audio
    func stopPlayback() async

    /// Deletes a recording file at the given URL
    func deleteRecording(url: String) async throws

    /// Returns the duration of a recording at the given URL
    func getRecordingDuration(url: String) async throws -> TimeInterval

    /// Whether the service is currently recording
    var isRecording: Bool { get }

    /// Whether the service is currently playing audio
    var isPlaying: Bool { get }

    /// The current audio amplitude level (0.0 to 1.0)
    var currentAmplitude: Float { get }
}
