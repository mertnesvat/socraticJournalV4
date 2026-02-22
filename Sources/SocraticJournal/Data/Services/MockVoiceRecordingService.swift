// MockVoiceRecordingService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import Observation

/// Mock implementation of VoiceRecordingServiceProtocol for SwiftUI previews and testing
/// Simulates recording state transitions without actual audio hardware
@Observable
@MainActor
public final class MockVoiceRecordingService: VoiceRecordingServiceProtocol, @unchecked Sendable {

    // MARK: - Observable State

    public private(set) var isRecording: Bool = false
    public private(set) var currentDuration: TimeInterval = 0

    // MARK: - Private Properties

    private var durationTimer: Timer?
    private var audioLevelContinuation: AsyncStream<Float>.Continuation?
    private var audioLevelTimer: Timer?
    private var isPaused: Bool = false
    private var mockPermissionStatus: AudioPermissionStatus

    // MARK: - Initialization

    public init(permissionStatus: AudioPermissionStatus = .granted) {
        self.mockPermissionStatus = permissionStatus
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

    // MARK: - Permission

    public var permissionStatus: AudioPermissionStatus {
        get async {
            return mockPermissionStatus
        }
    }

    public func requestPermission() async -> Bool {
        mockPermissionStatus = .granted
        return true
    }

    // MARK: - Recording Lifecycle

    public func startRecording() throws {
        guard mockPermissionStatus == .granted else {
            throw VoiceRecordingError.permissionDenied
        }

        isRecording = true
        currentDuration = 0
        isPaused = false

        // Simulate duration ticking
        startDurationTimer()

        // Simulate audio levels
        startAudioLevelSimulation()
    }

    public func stopRecording() -> URL? {
        guard isRecording else { return nil }

        let finalDuration = currentDuration

        stopTimers()
        isRecording = false
        isPaused = false
        currentDuration = 0

        // Enforce minimum duration (3 seconds)
        if finalDuration < 3.0 {
            return nil
        }

        // Return a fake URL for testing
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("mock-recording-\(UUID().uuidString).m4a")
    }

    public func cancelRecording() {
        stopTimers()
        isRecording = false
        isPaused = false
        currentDuration = 0
    }

    public func pauseRecording() {
        guard isRecording, !isPaused else { return }
        isPaused = true
        stopTimers()
    }

    public func resumeRecording() {
        guard isRecording, isPaused else { return }
        isPaused = false
        startDurationTimer()
        startAudioLevelSimulation()
    }

    // MARK: - Test Helpers

    /// Simulates the recording duration for testing purposes
    /// Allows tests to set a specific duration without waiting for real time
    public func simulateDuration(_ duration: TimeInterval) {
        currentDuration = duration
    }

    // MARK: - Private Helpers

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isRecording, !self.isPaused else { return }
                self.currentDuration += 0.1

                // Auto-stop at 60 seconds
                if self.currentDuration >= 60.0 {
                    _ = self.stopRecording()
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
                guard let self, self.isRecording, !self.isPaused else { return }
                // Generate random audio level between 0.1 and 0.8 for realistic waveform preview
                let randomLevel = Float.random(in: 0.1...0.8)
                self.audioLevelContinuation?.yield(randomLevel)
            }
        }
    }

    private func stopTimers() {
        durationTimer?.invalidate()
        durationTimer = nil
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        audioLevelContinuation?.finish()
        audioLevelContinuation = nil
    }

}
