// LocalVoicePlaybackService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation
import os.log
import SwiftUI

/// Local voice playback service using AVAudioPlayer.
/// Manages audio session configuration, timer-based progress updates,
/// and interruption handling (e.g., phone calls).
@Observable
@MainActor
public final class LocalVoicePlaybackService: NSObject, VoicePlaybackServiceProtocol {
    // MARK: - Observable State

    public private(set) var isPlaying: Bool = false
    public private(set) var currentTime: TimeInterval = 0.0
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var currentlyPlayingId: UUID? = nil

    // MARK: - Private State

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private var audioSessionConfigured: Bool = false

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.StudioNext.Circle",
        category: "VoicePlayback"
    )

    // MARK: - Init

    public override init() {
        super.init()
        configureAudioSession()
        registerForInterruptions()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - VoicePlaybackServiceProtocol

    public func play(voiceNote: VoiceNote) throws {
        // If already playing a different note, stop the current one first
        if currentlyPlayingId != nil && currentlyPlayingId != voiceNote.id {
            stop()
        }

        // If resuming the same note that was paused, just resume
        if currentlyPlayingId == voiceNote.id, let player = audioPlayer {
            player.play()
            isPlaying = true
            startProgressTimer()
            return
        }

        // Load new audio file
        let fileURL = voiceNote.fileURL

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.warning("Audio file not found at path: \(fileURL.path)")
            throw VoicePlaybackError.fileNotFound(voiceNote.filePath)
        }

        do {
            // Ensure audio session is active for playback
            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.delegate = self
            player.prepareToPlay()

            audioPlayer = player
            currentlyPlayingId = voiceNote.id
            duration = player.duration

            player.play()
            isPlaying = true
            startProgressTimer()
        } catch {
            logger.error("Failed to create audio player: \(error.localizedDescription)")
            resetState()
            throw VoicePlaybackError.playbackFailed(error)
        }
    }

    public func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.pause()
        isPlaying = false
        stopProgressTimer()
        // Update currentTime one final time
        currentTime = player.currentTime
    }

    public func stop() {
        audioPlayer?.stop()
        stopProgressTimer()
        resetState()
    }

    public func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        let clampedTime = max(0, min(time, player.duration))
        player.currentTime = clampedTime
        currentTime = clampedTime
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        guard !audioSessionConfigured else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            audioSessionConfigured = true
        } catch {
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Interruption Handling

    private func registerForInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        Task { @MainActor in
            switch type {
            case .began:
                // Pause playback on interruption (e.g., phone call)
                if isPlaying {
                    pause()
                }
            case .ended:
                // Optionally resume after interruption
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume), let player = audioPlayer {
                        player.play()
                        isPlaying = true
                        startProgressTimer()
                    }
                }
            @unknown default:
                break
            }
        }
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func updateProgress() {
        guard let player = audioPlayer, player.isPlaying else { return }
        currentTime = player.currentTime
    }

    // MARK: - State Management

    private func resetState() {
        audioPlayer = nil
        isPlaying = false
        currentTime = 0.0
        duration = 0.0
        currentlyPlayingId = nil
    }
}

// MARK: - AVAudioPlayerDelegate

extension LocalVoicePlaybackService: @preconcurrency AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()
        isPlaying = false
        currentTime = 0.0
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error {
            logger.error("Audio decode error: \(error.localizedDescription)")
        }
        stop()
    }
}

// MARK: - Voice Playback Errors

public enum VoicePlaybackError: LocalizedError {
    case fileNotFound(String)
    case playbackFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Audio file not found: \(path)"
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        }
    }
}
#endif
