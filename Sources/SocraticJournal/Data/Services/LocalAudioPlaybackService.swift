// LocalAudioPlaybackService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import AVFoundation

/// AVAudioPlayer-backed implementation of AudioPlaybackServiceProtocol
public final class LocalAudioPlaybackService: NSObject, AudioPlaybackServiceProtocol, @unchecked Sendable {

    // MARK: - Private State

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var _isPlaying = false
    private var _currentTime: TimeInterval = 0
    private var _duration: TimeInterval = 0
    private let lock = NSLock()

    // MARK: - Init

    public override init() {
        super.init()
    }

    // MARK: - AudioPlaybackServiceProtocol

    public var isPlaying: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isPlaying
    }

    public var currentTime: TimeInterval {
        lock.lock()
        defer { lock.unlock() }
        return _currentTime
    }

    public var duration: TimeInterval {
        lock.lock()
        defer { lock.unlock() }
        return _duration
    }

    public func play(url: URL) throws {
        // Configure audio session for playback
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)

        // Stop existing player if any
        stopProgressTimer()
        lock.lock()
        player?.stop()
        lock.unlock()

        let newPlayer = try AVAudioPlayer(contentsOf: url)
        newPlayer.delegate = self
        newPlayer.enableRate = true
        newPlayer.prepareToPlay()
        newPlayer.play()

        lock.lock()
        self.player = newPlayer
        self._isPlaying = true
        self._duration = newPlayer.duration
        self._currentTime = 0
        lock.unlock()

        startProgressTimer()
    }

    public func pause() {
        lock.lock()
        player?.pause()
        _isPlaying = false
        lock.unlock()
        stopProgressTimer()
    }

    public func stop() {
        stopProgressTimer()
        lock.lock()
        player?.stop()
        _isPlaying = false
        _currentTime = 0
        player = nil
        lock.unlock()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    public func setPlaybackSpeed(_ speed: Float) {
        lock.lock()
        player?.rate = speed
        lock.unlock()
    }

    public func seek(to time: TimeInterval) {
        lock.lock()
        player?.currentTime = time
        _currentTime = time
        lock.unlock()
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                let time = self.player?.currentTime ?? 0
                self._currentTime = time
                self.lock.unlock()
            }
        }
    }

    private func stopProgressTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.progressTimer?.invalidate()
            self?.progressTimer = nil
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension LocalAudioPlaybackService: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()
        lock.lock()
        _isPlaying = false
        _currentTime = 0
        lock.unlock()
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopProgressTimer()
        lock.lock()
        _isPlaying = false
        lock.unlock()
    }
}
