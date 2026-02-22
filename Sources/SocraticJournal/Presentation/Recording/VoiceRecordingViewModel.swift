// VoiceRecordingViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import Observation

/// State machine describing the voice recording flow
public enum RecordingState: Sendable {
    case idle
    case recording
    case preview
    case submitting
}

/// ViewModel driving the voice recording screen
/// Manages the recording lifecycle, preview playback, and answer submission
@Observable
@MainActor
public final class VoiceRecordingViewModel {
    // MARK: - State

    /// Current state of the recording flow
    public private(set) var recordingState: RecordingState = .idle

    /// Duration of the current or completed recording in seconds
    public private(set) var currentDuration: TimeInterval = 0

    /// Current audio input level (0.0 to 1.0) for waveform visualization
    public private(set) var audioLevel: Float = 0

    /// URL of the recorded audio file after recording stops
    public private(set) var recordedFileURL: URL?

    /// Current error to display, if any
    public var error: VoiceRecordingError?

    /// Controls error alert presentation
    public var showErrorAlert: Bool = false

    /// Controls re-record confirmation alert presentation
    public var showReRecordConfirmation: Bool = false

    /// The daily question being answered
    public let question: DailyQuestion

    // MARK: - Dependencies

    private let recordingService: VoiceRecordingServiceProtocol
    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol
    private let streakRepository: StreakRepositoryProtocol
    private let playbackService: AudioPlaybackServiceProtocol

    /// Callback invoked after the answer is successfully submitted
    private let onAnswerSubmitted: (() -> Void)?

    /// Task tracking the audio level listener so it can be cancelled
    private var audioLevelTask: Task<Void, Never>?

    /// Task tracking the recording duration timer
    private var durationTimerTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(
        question: DailyQuestion,
        recordingService: VoiceRecordingServiceProtocol,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol,
        playbackService: AudioPlaybackServiceProtocol,
        onAnswerSubmitted: (() -> Void)? = nil
    ) {
        self.question = question
        self.recordingService = recordingService
        self.voiceAnswerRepository = voiceAnswerRepository
        self.streakRepository = streakRepository
        self.playbackService = playbackService
        self.onAnswerSubmitted = onAnswerSubmitted
    }

    // MARK: - Actions

    /// Starts a new recording session
    /// Requests microphone permission if not yet determined, then begins recording
    public func startRecording() async {
        // Check permission
        let status = await recordingService.permissionStatus
        switch status {
        case .notDetermined:
            let granted = await recordingService.requestPermission()
            guard granted else {
                error = .permissionDenied
                showErrorAlert = true
                return
            }
        case .denied:
            error = .permissionDenied
            showErrorAlert = true
            return
        case .granted:
            break
        }

        // Start recording
        do {
            try recordingService.startRecording()
            recordingState = .recording
            currentDuration = 0
            audioLevel = 0

            // Start listening to audio levels
            listenToAudioLevels()

            // Start duration tracking
            startDurationTracking()
        } catch {
            self.error = .recordingFailed
            showErrorAlert = true
        }
    }

    /// Stops the current recording
    /// Transitions to preview if the recording meets minimum duration, otherwise shows an error
    public func stopRecording() {
        durationTimerTask?.cancel()
        durationTimerTask = nil
        audioLevelTask?.cancel()
        audioLevelTask = nil

        // Capture the final duration before stopping (since stop resets it)
        let finalDuration = recordingService.currentDuration

        let fileURL = recordingService.stopRecording()

        if let fileURL = fileURL {
            recordedFileURL = fileURL
            currentDuration = finalDuration
            recordingState = .preview
        } else {
            // Recording was too short
            error = .tooShort
            showErrorAlert = true
            recordingState = .idle
            currentDuration = 0
        }
    }

    /// Cancels the current recording and returns to idle state
    public func cancelRecording() {
        durationTimerTask?.cancel()
        durationTimerTask = nil
        audioLevelTask?.cancel()
        audioLevelTask = nil
        recordingService.cancelRecording()
        recordingState = .idle
        currentDuration = 0
        audioLevel = 0
        recordedFileURL = nil
    }

    /// Submits the recorded answer
    /// Creates a VoiceAnswer, saves it via the repository, records the streak, and calls the completion callback
    public func submitAnswer() async {
        guard let fileURL = recordedFileURL else { return }

        recordingState = .submitting

        let answer = VoiceAnswer(
            questionId: question.id,
            userId: "user-current",
            audioFileURL: fileURL,
            duration: currentDuration,
            createdAt: Date()
        )

        await voiceAnswerRepository.saveAnswer(answer)
        await streakRepository.recordAnswer()

        recordingState = .idle
        currentDuration = 0
        recordedFileURL = nil

        onAnswerSubmitted?()
    }

    /// Prompts the user to confirm re-recording, which will erase the current recording
    public func reRecord() {
        showReRecordConfirmation = true
    }

    /// Confirms re-recording: deletes the current recording and resets to idle
    public func confirmReRecord() {
        playbackService.stop()

        // Delete the recorded file
        if let fileURL = recordedFileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }

        recordedFileURL = nil
        currentDuration = 0
        recordingState = .idle
    }

    /// Plays the recorded audio file in preview mode
    public func playPreview() async {
        guard let fileURL = recordedFileURL else { return }
        do {
            try playbackService.play(url: fileURL)
        } catch {
            // Playback failure is non-critical; silently ignore
        }
    }

    /// Pauses the preview playback
    public func pausePreview() {
        playbackService.pause()
    }

    /// Cleans up resources when the view is dismissed without submitting
    public func cleanup() {
        durationTimerTask?.cancel()
        durationTimerTask = nil
        audioLevelTask?.cancel()
        audioLevelTask = nil

        // If recording, cancel it
        if recordingState == .recording {
            recordingService.cancelRecording()
        }

        // Stop any playback
        playbackService.stop()

        // Delete recorded file if not submitted
        if let fileURL = recordedFileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // MARK: - Formatted Duration

    /// Returns the current duration formatted as MM:SS
    public var formattedDuration: String {
        let minutes = Int(currentDuration) / 60
        let seconds = Int(currentDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Helpers

    /// Listens to the recording service's audio level stream and updates the audioLevel property
    private func listenToAudioLevels() {
        audioLevelTask?.cancel()
        audioLevelTask = Task { [weak self] in
            guard let self else { return }
            for await level in self.recordingService.audioLevels {
                if Task.isCancelled { break }
                self.audioLevel = level
            }
        }
    }

    /// Tracks recording duration by polling the recording service
    private func startDurationTracking() {
        durationTimerTask?.cancel()
        durationTimerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                self.currentDuration = self.recordingService.currentDuration

                // Auto-stop at 60 seconds
                if self.currentDuration >= 60.0 {
                    self.stopRecording()
                    break
                }

                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
}
