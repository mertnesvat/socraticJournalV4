// MockVoicePlaybackService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock voice playback service for SwiftUI previews and testing.
/// Simulates playback state changes without requiring actual audio files.
@Observable
@MainActor
public final class MockVoicePlaybackService: VoicePlaybackServiceProtocol {
    // MARK: - State

    public private(set) var isPlaying: Bool = false
    public private(set) var currentTime: TimeInterval = 0.0
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var currentlyPlayingId: UUID? = nil

    // MARK: - Private

    private var simulationTimer: Timer?

    // MARK: - Init

    public init() {}

    // MARK: - VoicePlaybackServiceProtocol

    public func play(voiceNote: VoiceNote) throws {
        // If playing a different note, stop first
        if currentlyPlayingId != nil && currentlyPlayingId != voiceNote.id {
            stop()
        }

        currentlyPlayingId = voiceNote.id
        duration = voiceNote.duration
        isPlaying = true

        // Simulate progress updates
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isPlaying else { return }
                self.currentTime += 0.05
                if self.currentTime >= self.duration {
                    self.currentTime = 0.0
                    self.isPlaying = false
                    self.simulationTimer?.invalidate()
                    self.simulationTimer = nil
                }
            }
        }
    }

    public func pause() {
        isPlaying = false
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    public func stop() {
        isPlaying = false
        currentTime = 0.0
        duration = 0.0
        currentlyPlayingId = nil
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    public func seek(to time: TimeInterval) {
        currentTime = max(0, min(time, duration))
    }
}
#endif
