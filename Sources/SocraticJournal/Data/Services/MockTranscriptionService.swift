// MockTranscriptionService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock transcription service for SwiftUI previews and testing.
/// Returns sample transcript text without requiring the Speech framework.
@Observable
@MainActor
public final class MockTranscriptionService: TranscriptionServiceProtocol {
    // MARK: - State

    public private(set) var isAvailable: Bool = true

    // MARK: - Configuration

    /// The transcript text to return. Set to nil to simulate transcription failure.
    public var mockTranscript: String? = "This is a sample transcription of a voice note for testing purposes."

    /// Simulated delay before returning the transcript, in seconds.
    public var simulatedDelay: TimeInterval = 1.0

    // MARK: - Init

    public init() {}

    // MARK: - TranscriptionServiceProtocol

    public func transcribe(audioURL: URL) async throws -> String? {
        // Simulate processing time
        if simulatedDelay > 0 {
            try await Task.sleep(for: .seconds(simulatedDelay))
        }
        return mockTranscript
    }

    public func requestPermission() async -> Bool {
        return true
    }
}
#endif
