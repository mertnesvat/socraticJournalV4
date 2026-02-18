// TranscriptionServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining speech-to-text transcription operations
public protocol TranscriptionServiceProtocol: Sendable {
    /// Transcribe an audio file to text
    func transcribe(audioURL: URL) async throws -> String

    /// Request speech recognition permission
    func requestPermission() async -> Bool

    /// Check if transcription is available on this device
    func isAvailable() async -> Bool
}
