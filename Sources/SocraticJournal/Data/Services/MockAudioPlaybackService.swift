// MockAudioPlaybackService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import Observation

/// Mock implementation of AudioPlaybackServiceProtocol for SwiftUI previews and testing
/// Simulates playback state transitions without actual audio hardware
@Observable
@MainActor
public final class MockAudioPlaybackService: AudioPlaybackServiceProtocol, @unchecked Sendable {

    // MARK: - Observable State

    public private(set) var isPlaying: Bool = false
    public private(set) var currentTime: TimeInterval = 0
    public private(set) var duration: TimeInterval

    // MARK: - Private Properties

    private var progressTimer: Timer?
    private var audioLevelTimer: Timer?
    private var audioLevelContinuation: AsyncStream<Float>.Continuation?
    private var playbackFinishedContinuation: AsyncStream<Void>.Continuation?

    // MARK: - Initialization

    /// Creates a mock playback service with a configurable duration
    /// - Parameter duration: The simulated audio duration in seconds (default: 15.0)
    public init(duration: TimeInterval = 15.0) {
        self.duration = duration
    }

    // MARK: - Audio Levels Stream

    public var audioLevels: AsyncStream<Float> {
        AsyncStream { [weak self] continuation in
            Task { @MainActor [weak self] in
                self?.audioLevelContinuation = continuation
            }
            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    self?.audioLevelContinuation = nil
                }
            }
        }
    }

    // MARK: - Playback Finished Stream

    public var playbackFinished: AsyncStream<Void> {
        AsyncStream { [weak self] continuation in
            Task { @MainActor [weak self] in
                self?.playbackFinishedContinuation = continuation
            }
            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    self?.playbackFinishedContinuation = nil
                }
            }
        }
    }

    // MARK: - Playback Lifecycle

    public func play(url: URL) throws {
        isPlaying = true
        startProgressTimer()
        startAudioLevelSimulation()
    }

    public func pause() {
        guard isPlaying else { return }
        isPlaying = false
        stopTimers()
    }

    public func stop() {
        isPlaying = false
        currentTime = 0
        stopTimers()
    }

    public func seek(to time: TimeInterval) {
        currentTime = max(0, min(time, duration))
    }

    // MARK: - Test Helpers

    /// Simulates the playback reaching the end of audio
    public func simulatePlaybackFinished() {
        isPlaying = false
        currentTime = duration
        stopTimers()
        playbackFinishedContinuation?.yield(())
    }

    /// Sets the current time directly for testing
    public func simulateCurrentTime(_ time: TimeInterval) {
        currentTime = time
    }

    // MARK: - Private Helpers

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying else { return }
                self.currentTime += 0.05

                // Simulate playback finishing
                if self.currentTime >= self.duration {
                    self.simulatePlaybackFinished()
                }
            }
        }
    }

    private func startAudioLevelSimulation() {
        audioLevelTimer = Timer.scheduledTimer(
            withTimeInterval: 0.033,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying else { return }
                // Generate random audio level between 0.1 and 0.8 for realistic waveform preview
                let randomLevel = Float.random(in: 0.1...0.8)
                self.audioLevelContinuation?.yield(randomLevel)
            }
        }
    }

    private func stopTimers() {
        progressTimer?.invalidate()
        progressTimer = nil
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        audioLevelContinuation?.finish()
        audioLevelContinuation = nil
    }
}
