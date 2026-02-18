// TranscriptionServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for speech-to-text transcription
/// Local implementation uses Apple Speech framework; could be swapped for cloud API
public protocol TranscriptionServiceProtocol: Sendable {
    /// Transcribe audio from a file URL
    /// - Parameter audioURL: URL of the audio file to transcribe
    /// - Returns: The transcribed text, or nil if transcription failed
    func transcribe(audioURL: URL) async -> String?

    /// Check if transcription is available on this device
    var isAvailable: Bool { get }

    /// Request speech recognition permission
    /// - Returns: Whether permission was granted
    func requestPermission() async -> Bool
}
