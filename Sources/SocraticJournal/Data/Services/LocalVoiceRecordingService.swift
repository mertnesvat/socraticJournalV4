// LocalVoiceRecordingService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import AVFoundation

/// AVAudioRecorder-backed implementation of VoiceRecordingServiceProtocol
/// Records to .m4a files using AAC format at 44.1kHz mono
public final class LocalVoiceRecordingService: NSObject, VoiceRecordingServiceProtocol, @unchecked Sendable {

    // MARK: - State

    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var durationTimer: Timer?
    private var _isRecording = false
    private var _currentDuration: TimeInterval = 0
    private let lock = NSLock()

    // MARK: - VoiceRecordingServiceProtocol

    public var isRecording: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isRecording
    }

    public var currentDuration: TimeInterval {
        lock.lock()
        defer { lock.unlock() }
        return _currentDuration
    }

    // MARK: - Init

    public override init() {
        super.init()
    }

    // MARK: - Recording

    public func startRecording(to url: URL) throws {
        // Configure audio session for recording
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        // Create parent directories if needed
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

        // AAC format settings: mono, 44.1kHz
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.delegate = self
        recorder.isMeteringEnabled = true

        guard recorder.record() else {
            throw VoiceRecordingError.recordingFailed("Failed to start recorder")
        }

        lock.lock()
        self.recorder = recorder
        self.recordingURL = url
        self._isRecording = true
        self._currentDuration = 0
        lock.unlock()

        startDurationTimer()
    }

    public func stopRecording() -> URL? {
        stopDurationTimer()

        lock.lock()
        let url = recordingURL
        recorder?.stop()
        recorder = nil
        _isRecording = false
        lock.unlock()

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        return url
    }

    // MARK: - Waveform Extraction

    public func extractWaveform(from url: URL, sampleCount: Int) async throws -> [Float] {
        return try await Task.detached(priority: .userInitiated) {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)

            guard frameCount > 0 else { return Array(repeating: 0, count: sampleCount) }

            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                throw VoiceRecordingError.waveformExtractionFailed("Cannot create PCM buffer")
            }

            try file.read(into: buffer)

            guard let channelData = buffer.floatChannelData?[0] else {
                return Array(repeating: 0, count: sampleCount)
            }

            let totalFrames = Int(buffer.frameLength)
            let framesPerSegment = max(1, totalFrames / sampleCount)
            var samples: [Float] = []

            for segmentIndex in 0..<sampleCount {
                let startFrame = segmentIndex * framesPerSegment
                let endFrame = min(startFrame + framesPerSegment, totalFrames)

                guard startFrame < totalFrames else {
                    samples.append(0)
                    continue
                }

                // Calculate RMS amplitude for this segment
                var sum: Float = 0
                let count = endFrame - startFrame
                for frame in startFrame..<endFrame {
                    let sample = channelData[frame]
                    sum += sample * sample
                }
                let rms = count > 0 ? sqrt(sum / Float(count)) : 0
                samples.append(rms)
            }

            // Normalize to 0-1 range
            let maxAmplitude = samples.max() ?? 1
            if maxAmplitude > 0 {
                return samples.map { $0 / maxAmplitude }
            }
            return samples
        }.value
    }

    // MARK: - Duration Timer

    private func startDurationTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                if self._isRecording {
                    self._currentDuration += 0.1
                }
                self.lock.unlock()
            }
        }
    }

    private func stopDurationTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.durationTimer?.invalidate()
            self?.durationTimer = nil
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension LocalVoiceRecordingService: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopDurationTimer()
            lock.lock()
            _isRecording = false
            lock.unlock()
        }
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        stopDurationTimer()
        lock.lock()
        _isRecording = false
        lock.unlock()
    }
}

// MARK: - Errors

public enum VoiceRecordingError: LocalizedError {
    case recordingFailed(String)
    case waveformExtractionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .recordingFailed(let reason): return "Recording failed: \(reason)"
        case .waveformExtractionFailed(let reason): return "Waveform extraction failed: \(reason)"
        }
    }
}
