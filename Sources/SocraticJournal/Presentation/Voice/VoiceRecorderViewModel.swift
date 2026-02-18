// VoiceRecorderViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation
import SwiftUI
import UIKit

/// ViewModel for the voice recording experience.
/// Manages recording lifecycle, timer display, amplitude updates, and playback preview.
@Observable
@MainActor
public final class VoiceRecorderViewModel {
    // MARK: - Types

    public enum RecordingState: Equatable {
        case idle
        case recording
        case done(VoiceNote)

        public static func == (lhs: RecordingState, rhs: RecordingState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.recording, .recording):
                return true
            case (.done(let a), .done(let b)):
                return a.id == b.id
            default:
                return false
            }
        }
    }

    // MARK: - Observable State

    private(set) var state: RecordingState = .idle
    private(set) var error: Error?
    /// Bindable from the view so SwiftUI `.alert(isPresented:)` can dismiss it.
    var showPermissionAlert: Bool = false

    /// Formatted elapsed time (MM:SS).
    var formattedDuration: String {
        let total = Int(voiceRecordingService.recordingDuration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Whether to show the "That's perfect!" nudge at 30s.
    var showNudge: Bool {
        guard case .recording = state else { return false }
        let duration = voiceRecordingService.recordingDuration
        return duration >= 30.0 && duration < 35.0
    }

    /// The current live amplitude for waveform visualization.
    var currentAmplitude: Float {
        voiceRecordingService.currentAmplitude
    }

    /// Whether recording is active.
    var isRecording: Bool {
        voiceRecordingService.isRecording
    }

    /// The recording duration from the service.
    var recordingDuration: TimeInterval {
        voiceRecordingService.recordingDuration
    }

    // MARK: - Dependencies

    private let voiceRecordingService: VoiceRecordingServiceProtocol
    private let circleId: UUID?
    private let promptId: UUID?
    private let maxDuration: TimeInterval = 60.0

    /// Timer to auto-stop at max duration.
    private var autoStopTimer: Timer?

    // MARK: - Haptics

    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Audio Playback

    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying: Bool = false

    // MARK: - Init

    public init(
        voiceRecordingService: VoiceRecordingServiceProtocol,
        circleId: UUID? = nil,
        promptId: UUID? = nil
    ) {
        self.voiceRecordingService = voiceRecordingService
        self.circleId = circleId
        self.promptId = promptId
    }

    // MARK: - Actions

    /// Start recording a voice note.
    func startRecording() async {
        // Check permission first
        let permissionStatus = AVAudioApplication.shared.recordPermission
        if permissionStatus == .denied {
            showPermissionAlert = true
            return
        }

        error = nil

        do {
            mediumImpact.impactOccurred()
            try await voiceRecordingService.startRecording(circleId: circleId, promptId: promptId)
            state = .recording

            // Schedule auto-stop at 60s
            autoStopTimer = Timer.scheduledTimer(withTimeInterval: maxDuration, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    await self?.stopRecording()
                }
            }
        } catch {
            if let voiceError = error as? VoiceRecordingError,
               voiceError == .microphonePermissionDenied {
                showPermissionAlert = true
            } else {
                self.error = error
            }
        }
    }

    /// Stop recording and transition to done state.
    func stopRecording() async {
        autoStopTimer?.invalidate()
        autoStopTimer = nil

        do {
            lightImpact.impactOccurred()
            let voiceNote = try await voiceRecordingService.stopRecording()
            state = .done(voiceNote)
        } catch {
            self.error = error
            state = .idle
        }
    }

    /// Cancel the current recording and return to idle.
    func cancelRecording() {
        autoStopTimer?.invalidate()
        autoStopTimer = nil
        voiceRecordingService.cancelRecording()
        stopPlayback()
        state = .idle
    }

    /// Discard the completed recording and return to idle for re-recording.
    func reRecord() {
        stopPlayback()
        // Delete the voice note file if it exists
        if case .done(let voiceNote) = state {
            try? FileManager.default.removeItem(at: voiceNote.fileURL)
        }
        state = .idle
    }

    /// Confirm the completed recording. Returns the VoiceNote if available.
    func confirmRecording() -> VoiceNote? {
        stopPlayback()
        if case .done(let voiceNote) = state {
            return voiceNote
        }
        return nil
    }

    // MARK: - Playback Preview

    /// Toggle playback of the completed recording.
    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard case .done(let voiceNote) = state else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: voiceNote.fileURL)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            self.error = error
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    /// Dismiss the permission alert.
    func dismissPermissionAlert() {
        showPermissionAlert = false
    }

    /// Clear error state.
    func clearError() {
        error = nil
    }
}

// MARK: - VoiceRecordingError Equatable

extension VoiceRecordingError: Equatable {
    public static func == (lhs: VoiceRecordingError, rhs: VoiceRecordingError) -> Bool {
        switch (lhs, rhs) {
        case (.microphonePermissionDenied, .microphonePermissionDenied):
            return true
        case (.recordingFailed, .recordingFailed):
            return true
        case (.noActiveRecording, .noActiveRecording):
            return true
        default:
            return false
        }
    }
}
#endif
