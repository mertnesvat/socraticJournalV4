// AudioPlaybackService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation
import Observation

/// Audio playback service implementation using AVAudioPlayer
/// Provides playback with metering support for real-time waveform visualization
/// Handles audio session configuration, route changes (headphone plug/unplug),
/// and playback completion via AVAudioPlayerDelegate
@Observable
@MainActor
public final class AudioPlaybackService: NSObject, AudioPlaybackServiceProtocol, @unchecked Sendable {

    // MARK: - Constants

    private static let meteringInterval: TimeInterval = 0.033 // ~30fps

    // MARK: - Observable State

    public private(set) var isPlaying: Bool = false
    public private(set) var currentTime: TimeInterval = 0
    public private(set) var duration: TimeInterval = 0

    // MARK: - Private Properties

    private var audioPlayer: AVAudioPlayer?
    private var meteringTimer: Timer?
    private var progressTimer: Timer?
    private var audioLevelContinuation: AsyncStream<Float>.Continuation?
    private var playbackFinishedContinuation: AsyncStream<Void>.Continuation?

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

    // MARK: - Initialization

    public override init() {
        super.init()
    }

    // MARK: - Playback Lifecycle

    public func play(url: URL) throws {
        // Stop any existing playback first
        stopInternal()

        // Configure audio session for playback
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            throw AudioPlaybackError.audioSessionFailed
        }

        // Create and configure the audio player
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.isMeteringEnabled = true
            player.delegate = self

            guard player.prepareToPlay() else {
                throw AudioPlaybackError.fileNotFound
            }

            guard player.play() else {
                throw AudioPlaybackError.playbackFailed
            }

            self.audioPlayer = player
            self.duration = player.duration
            self.currentTime = 0
            self.isPlaying = true

            // Start metering and progress timers
            startMeteringTimer()
            startProgressTimer()

            // Register for audio route change notifications
            registerForRouteChangeNotifications()
        } catch let error as AudioPlaybackError {
            throw error
        } catch {
            throw AudioPlaybackError.playbackFailed
        }
    }

    public func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }

        player.pause()
        isPlaying = false
        stopTimers()
    }

    public func stop() {
        stopInternal()
    }

    public func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }

        let clampedTime = max(0, min(time, player.duration))
        player.currentTime = clampedTime
        currentTime = clampedTime

        // If we were playing, update metering immediately
        if player.isPlaying {
            player.updateMeters()
        }
    }

    // MARK: - Private Helpers

    private func stopInternal() {
        guard let player = audioPlayer else { return }

        player.stop()
        stopTimers()
        unregisterFromRouteChangeNotifications()

        isPlaying = false
        currentTime = 0
        duration = 0
        audioPlayer = nil
    }

    private func startMeteringTimer() {
        meteringTimer = Timer.scheduledTimer(
            withTimeInterval: Self.meteringInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateMetering()
            }
        }
    }

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateProgress()
            }
        }
    }

    private func stopTimers() {
        meteringTimer?.invalidate()
        meteringTimer = nil
        progressTimer?.invalidate()
        progressTimer = nil

        // Finish the audio levels stream
        audioLevelContinuation?.finish()
        audioLevelContinuation = nil
    }

    private func updateMetering() {
        guard let player = audioPlayer, player.isPlaying else { return }

        player.updateMeters()
        let averagePower = player.averagePower(forChannel: 0)

        // Normalize from dB (-160...0) to 0...1 range
        let normalizedLevel = Self.normalizeAudioLevel(averagePower)

        audioLevelContinuation?.yield(normalizedLevel)
    }

    /// Normalizes audio power from dB scale (-160...0) to linear scale (0...1)
    static func normalizeAudioLevel(_ decibels: Float) -> Float {
        // Clamp to valid range
        let clampedDB = max(-60.0, min(decibels, 0.0))
        // Convert from -60...0 dB to 0...1 linear scale
        let normalized = (clampedDB + 60.0) / 60.0
        return max(0.0, min(1.0, normalized))
    }

    private func updateProgress() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
    }

    // MARK: - Route Change Handling

    private func registerForRouteChangeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    private func unregisterFromRouteChangeNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc
    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        // Pause playback when headphones are unplugged
        if reason == .oldDeviceUnavailable {
            Task { @MainActor [weak self] in
                self?.pause()
            }
        }
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlaybackService: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.isPlaying = false
            self.currentTime = self.duration
            self.stopTimers()
            self.unregisterFromRouteChangeNotifications()
            self.playbackFinishedContinuation?.yield(())
        }
    }

    nonisolated public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.stopInternal()
        }
    }
}
#endif
