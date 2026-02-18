// MockVoiceRecordingService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock voice recording service for SwiftUI previews and testing.
/// Simulates recording without requiring microphone access or SwiftData.
@Observable
@MainActor
public final class MockVoiceRecordingService: VoiceRecordingServiceProtocol {
    // MARK: - State

    public private(set) var isRecording: Bool = false
    public private(set) var currentAmplitude: Float = 0.0
    public private(set) var recordingDuration: TimeInterval = 0.0

    // MARK: - Private

    private var simulationTimer: Timer?

    // MARK: - Init

    public init() {}

    // MARK: - VoiceRecordingServiceProtocol

    public func startRecording(circleId: UUID?, promptId: UUID?) async throws {
        isRecording = true
        recordingDuration = 0.0
        currentAmplitude = 0.0

        // Simulate amplitude changes
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isRecording else { return }
                self.recordingDuration += 0.1
                // Generate a somewhat realistic-looking random amplitude
                self.currentAmplitude = Float.random(in: 0.1...0.9)
            }
        }
    }

    public func stopRecording() async throws -> VoiceNote {
        simulationTimer?.invalidate()
        simulationTimer = nil
        isRecording = false

        let duration = recordingDuration
        recordingDuration = 0.0
        currentAmplitude = 0.0

        return VoiceNote(
            filePath: "VoiceNotes/mock/\(UUID().uuidString).m4a",
            duration: max(duration, 3.0),
            waveformData: Self.sampleWaveformData,
            circleId: nil,
            promptId: nil,
            userId: nil
        )
    }

    public func cancelRecording() {
        simulationTimer?.invalidate()
        simulationTimer = nil
        isRecording = false
        recordingDuration = 0.0
        currentAmplitude = 0.0
    }

    // MARK: - Sample Data

    /// Realistic-looking waveform data for previews.
    static let sampleWaveformData: [Float] = {
        (0..<80).map { i in
            let base = Float(i) / 80.0
            let wave = sin(base * .pi * 4) * 0.3
            let noise = Float.random(in: -0.15...0.15)
            return max(0.05, min(1.0, 0.4 + wave + noise))
        }
    }()
}
#endif
