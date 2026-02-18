// AudioService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation

/// Audio recording and playback service using AVAudioRecorder/AVAudioPlayer
@MainActor
public final class AudioService: NSObject, AudioServiceProtocol, @unchecked Sendable {
    // MARK: - State

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var recordingURL: URL?
    private var meterTimer: Timer?
    private var playbackTimer: Timer?
    private var recordingStartTime: Date?

    private var meterContinuation: AsyncStream<Float>.Continuation?
    public let meterLevelStream: AsyncStream<Float>

    private var progressContinuation: AsyncStream<Double>.Continuation?
    public let playbackProgressStream: AsyncStream<Double>

    // MARK: - Init

    public override init() {
        var meterCont: AsyncStream<Float>.Continuation?
        meterLevelStream = AsyncStream { cont in
            meterCont = cont
        }

        var progressCont: AsyncStream<Double>.Continuation?
        playbackProgressStream = AsyncStream { cont in
            progressCont = cont
        }

        super.init()
        meterContinuation = meterCont
        progressContinuation = progressCont
    }

    // MARK: - AudioServiceProtocol

    public nonisolated func startRecording() async throws -> URL {
        try await MainActor.run {
            try configureAudioSession(for: .recording)

            let url = generateRecordingURL()
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            recordingURL = url
            recordingStartTime = Date()

            startMeterUpdates()
            return url
        }
    }

    public nonisolated func stopRecording() async throws -> URL {
        try await MainActor.run {
            guard let recorder, let url = recordingURL else {
                throw AudioError.notRecording
            }
            recorder.stop()
            stopMeterUpdates()
            self.recorder = nil
            recordingStartTime = nil
            return url
        }
    }

    public nonisolated func startPlayback(url: URL) async throws {
        try await MainActor.run {
            try configureAudioSession(for: .playback)

            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()

            startPlaybackUpdates()
        }
    }

    public nonisolated func stopPlayback() async {
        await MainActor.run {
            player?.stop()
            player = nil
            stopPlaybackUpdates()
        }
    }

    public nonisolated func isRecording() async -> Bool {
        await MainActor.run {
            recorder?.isRecording ?? false
        }
    }

    public nonisolated func isPlaying() async -> Bool {
        await MainActor.run {
            player?.isPlaying ?? false
        }
    }

    public nonisolated func currentRecordingDuration() async -> TimeInterval {
        await MainActor.run {
            guard let start = recordingStartTime else { return 0 }
            return Date().timeIntervalSince(start)
        }
    }

    public nonisolated func playbackProgress() async -> Double {
        await MainActor.run {
            guard let player, player.duration > 0 else { return 0 }
            return player.currentTime / player.duration
        }
    }

    public nonisolated func extractWaveform(from url: URL, samples: Int) async throws -> [Float] {
        // Read the audio file and extract amplitude samples
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let frameCount = UInt32(file.length)

        guard frameCount > 0, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return Array(repeating: 0, count: samples)
        }

        try file.read(into: buffer)

        guard let channelData = buffer.floatChannelData?[0] else {
            return Array(repeating: 0, count: samples)
        }

        let totalFrames = Int(buffer.frameLength)
        let framesPerSample = max(1, totalFrames / samples)
        var waveform: [Float] = []

        for i in 0..<samples {
            let start = i * framesPerSample
            let end = min(start + framesPerSample, totalFrames)
            guard start < totalFrames else {
                waveform.append(0)
                continue
            }

            var sum: Float = 0
            for j in start..<end {
                sum += abs(channelData[j])
            }
            let avg = sum / Float(end - start)
            waveform.append(avg)
        }

        // Normalize to 0.0-1.0
        let maxVal = waveform.max() ?? 1.0
        if maxVal > 0 {
            waveform = waveform.map { $0 / maxVal }
        }

        return waveform
    }

    public nonisolated func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Private Helpers

    private enum SessionMode {
        case recording, playback
    }

    private func configureAudioSession(for mode: SessionMode) throws {
        let session = AVAudioSession.sharedInstance()
        switch mode {
        case .recording:
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        case .playback:
            try session.setCategory(.playback, mode: .default)
        }
        try session.setActive(true)
    }

    private func generateRecordingURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
        let filename = "recording_\(UUID().uuidString).m4a"
        return dir.appendingPathComponent(filename)
    }

    private func startMeterUpdates() {
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let recorder = self.recorder, recorder.isRecording else { return }
                recorder.updateMeters()
                let power = recorder.averagePower(forChannel: 0)
                // Convert dB to normalized 0.0-1.0 (dB range roughly -60 to 0)
                let normalized = max(0, min(1, (power + 60) / 60))
                self.meterContinuation?.yield(normalized)
            }
        }
    }

    private func stopMeterUpdates() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func startPlaybackUpdates() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player, player.isPlaying else { return }
                let progress = player.currentTime / max(player.duration, 0.001)
                self.progressContinuation?.yield(progress)
            }
        }
    }

    private func stopPlaybackUpdates() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        progressContinuation?.yield(0)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    public nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.stopPlaybackUpdates()
            self.player = nil
        }
    }
}

// MARK: - Audio Errors

public enum AudioError: Error, LocalizedError {
    case notRecording
    case notPlaying
    case permissionDenied
    case recordingFailed(String)
    case playbackFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notRecording: return "No active recording"
        case .notPlaying: return "No audio playing"
        case .permissionDenied: return "Microphone access denied"
        case .recordingFailed(let msg): return "Recording failed: \(msg)"
        case .playbackFailed(let msg): return "Playback failed: \(msg)"
        }
    }
}
#endif
