// TranscriptionServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol for speech-to-text transcription of audio files.
/// Implementations handle permission requests, availability checks, and transcription.
@MainActor
public protocol TranscriptionServiceProtocol: AnyObject {
    /// Transcribe the audio file at the given URL into text.
    /// - Parameter audioURL: The file URL of the audio to transcribe.
    /// - Returns: The transcribed text, or nil if transcription fails or produces no result.
    func transcribe(audioURL: URL) async throws -> String?

    /// Whether the speech recognition framework is available and authorized on this device.
    var isAvailable: Bool { get }

    /// Request speech recognition permission from the user.
    /// - Returns: `true` if permission was granted, `false` otherwise.
    func requestPermission() async -> Bool
}
