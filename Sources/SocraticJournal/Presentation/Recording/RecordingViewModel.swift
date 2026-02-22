// RecordingViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The current phase of the recording flow
public enum RecordingState: Equatable {
    case idle
    case recording
    case recorded(audioURL: String)
    case submitting
}

/// ViewModel managing the recording lifecycle -- from idle through recording, preview, and submit
@Observable
@MainActor
public final class RecordingViewModel {

    // MARK: - State

    public private(set) var state: RecordingState = .idle
    public private(set) var elapsedTime: TimeInterval = 0
    public private(set) var recordedAmplitudes: [Float] = []
    public private(set) var errorMessage: String?
    public private(set) var recordingDuration: TimeInterval = 0
    public private(set) var didSubmit: Bool = false

    /// The question being answered
    public let question: DailyQuestion

    /// Maximum recording duration in seconds
    private let maxDuration: TimeInterval = 60

    // MARK: - Service Proxied Properties

    /// Whether the service is currently recording audio
    public var isRecording: Bool {
        voiceRecordingService.isRecording
    }

    /// Whether the service is currently playing back audio
    public var isPlaying: Bool {
        voiceRecordingService.isPlaying
    }

    /// The current microphone amplitude (0.0 to 1.0)
    public var currentAmplitude: Float {
        voiceRecordingService.currentAmplitude
    }

    /// Current playback time from the service
    public var currentPlaybackTime: TimeInterval {
        if let service = voiceRecordingService as? VoiceRecordingService {
            return service.currentPlaybackTime
        }
        return 0
    }

    /// Total duration of the playback from the service
    public var totalPlaybackDuration: TimeInterval {
        if let service = voiceRecordingService as? VoiceRecordingService {
            return service.totalDuration
        }
        return recordingDuration
    }

    // MARK: - Dependencies

    private let voiceRecordingService: VoiceRecordingServiceProtocol
    private var recordingTimer: Timer?

    // MARK: - Init

    public init(
        question: DailyQuestion,
        voiceRecordingService: VoiceRecordingServiceProtocol
    ) {
        self.question = question
        self.voiceRecordingService = voiceRecordingService
    }

    // MARK: - Actions

    /// Begins recording audio from the microphone
    public func startRecording() async {
        errorMessage = nil
        elapsedTime = 0
        recordedAmplitudes = []

        do {
            try await voiceRecordingService.startRecording()
            state = .recording
            startTimer()
            triggerHaptic(.medium)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Stops the current recording and transitions to the preview state
    public func stopRecording() async {
        stopTimer()

        do {
            let audioURL = try await voiceRecordingService.stopRecording()
            recordingDuration = elapsedTime
            state = .recorded(audioURL: audioURL)
            triggerHaptic(.light)
        } catch {
            errorMessage = error.localizedDescription
            state = .idle
        }
    }

    /// Plays back the recorded audio for preview
    public func playRecording() async {
        guard case .recorded(let audioURL) = state else { return }
        errorMessage = nil

        do {
            try await voiceRecordingService.playRecording(url: audioURL)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Stops any active audio playback
    public func stopPlayback() async {
        await voiceRecordingService.stopPlayback()
    }

    /// Discards the current recording and resets to idle for re-recording
    public func reRecord() async {
        // Stop playback if active
        if isPlaying {
            await voiceRecordingService.stopPlayback()
        }

        // Delete the recorded file
        if case .recorded(let audioURL) = state {
            try? await voiceRecordingService.deleteRecording(url: audioURL)
        }

        // Reset state
        elapsedTime = 0
        recordedAmplitudes = []
        recordingDuration = 0
        errorMessage = nil
        state = .idle
    }

    /// Submits the voice answer -- saves and transitions to done
    public func submit() async {
        guard case .recorded(let audioURL) = state else { return }

        // Stop playback if still playing
        if isPlaying {
            await voiceRecordingService.stopPlayback()
        }

        state = .submitting
        triggerHaptic(.heavy)

        // Simulate submission delay (mock save)
        // In production this would save the VoiceAnswer to the repository
        do {
            let duration = try await voiceRecordingService.getRecordingDuration(url: audioURL)

            let _ = VoiceAnswer(
                id: UUID().uuidString,
                questionId: question.id,
                userId: "current_user",
                audioURL: audioURL,
                duration: duration,
                createdAt: Date(),
                isListened: false
            )

            // Brief delay for the submission feel
            try? await Task.sleep(for: .milliseconds(800))

            didSubmit = true
        } catch {
            errorMessage = error.localizedDescription
            state = .recorded(audioURL: audioURL)
        }
    }

    /// Handles the record button tap -- toggles between start and stop
    public func toggleRecording() async {
        switch state {
        case .idle:
            await startRecording()
        case .recording:
            await stopRecording()
        default:
            break
        }
    }

    // MARK: - Timer

    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.elapsedTime += 0.1

                // Collect amplitude sample for waveform
                let amplitude = self.currentAmplitude
                self.recordedAmplitudes.append(amplitude)

                // Auto-stop at max duration
                if self.elapsedTime >= self.maxDuration {
                    await self.stopRecording()
                }
            }
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    // MARK: - Haptics

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

#endif
