// VoiceRecordingService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation
import Observation

/// Voice recording service implementation using AVAudioRecorder
/// Records audio in AAC format (.m4a) with metering support for waveform visualization
@Observable
@MainActor
public final class VoiceRecordingService: VoiceRecordingServiceProtocol, @unchecked Sendable {

    // MARK: - Constants

    private static let maxRecordingDuration: TimeInterval = 60.0
    private static let minRecordingDuration: TimeInterval = 3.0
    private static let meteringInterval: TimeInterval = 0.033 // ~30fps

    // MARK: - Observable State

    public private(set) var isRecording: Bool = false
    public private(set) var currentDuration: TimeInterval = 0

    // MARK: - Private Properties

    private var audioRecorder: AVAudioRecorder?
    private var currentFileURL: URL?
    private var recordingStartTime: Date?
    private var meteringTimer: Timer?
    private var durationTimer: Timer?
    private var audioLevelContinuation: AsyncStream<Float>.Continuation?
    private var isPaused: Bool = false
    private var accumulatedDuration: TimeInterval = 0
    private var pauseTime: Date?

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
            switch AVAudioApplication.shared.recordPermission {
            case .undetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .granted:
                return .granted
            @unknown default:
                return .notDetermined
            }
        }
    }

    public func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Recording Lifecycle

    public func startRecording() throws {
        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            throw VoiceRecordingError.audioSessionFailed
        }

        // Create file URL in temp directory with UUID-based naming
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).m4a")

        // Configure recording settings for AAC format
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // Create and configure recorder
        do {
            let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder.isMeteringEnabled = true

            guard recorder.prepareToRecord() else {
                throw VoiceRecordingError.recordingFailed
            }

            guard recorder.record() else {
                throw VoiceRecordingError.recordingFailed
            }

            self.audioRecorder = recorder
            self.currentFileURL = fileURL
            self.recordingStartTime = Date()
            self.accumulatedDuration = 0
            self.isPaused = false
            self.isRecording = true
            self.currentDuration = 0

            // Start metering timer for audio levels
            startMeteringTimer()

            // Start duration timer
            startDurationTimer()

            // Register for interruption notifications
            registerForInterruptionNotifications()

        } catch let error as VoiceRecordingError {
            throw error
        } catch {
            throw VoiceRecordingError.recordingFailed
        }
    }

    public func stopRecording() -> URL? {
        guard let recorder = audioRecorder else { return nil }

        let finalDuration = calculateCurrentDuration()

        // Stop recording and timers
        recorder.stop()
        stopTimers()
        unregisterFromInterruptionNotifications()

        isRecording = false
        isPaused = false
        currentDuration = 0

        let fileURL = currentFileURL

        // Clean up state
        audioRecorder = nil
        currentFileURL = nil
        recordingStartTime = nil
        accumulatedDuration = 0

        // Enforce minimum duration
        if finalDuration < Self.minRecordingDuration {
            // Delete the too-short recording
            if let url = fileURL {
                try? FileManager.default.removeItem(at: url)
            }
            return nil
        }

        return fileURL
    }

    public func cancelRecording() {
        guard let recorder = audioRecorder else { return }

        // Stop recording
        recorder.stop()
        stopTimers()
        unregisterFromInterruptionNotifications()

        // Delete the audio file
        if let fileURL = currentFileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }

        // Reset all state
        audioRecorder = nil
        currentFileURL = nil
        recordingStartTime = nil
        accumulatedDuration = 0
        isPaused = false
        isRecording = false
        currentDuration = 0
    }

    public func pauseRecording() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }

        recorder.pause()
        isPaused = true
        pauseTime = Date()

        // Accumulate duration up to this point
        if let startTime = recordingStartTime {
            accumulatedDuration += Date().timeIntervalSince(startTime)
        }

        stopTimers()
    }

    public func resumeRecording() {
        guard let recorder = audioRecorder, isPaused else { return }

        recorder.record()
        isPaused = false
        recordingStartTime = Date()
        pauseTime = nil

        startMeteringTimer()
        startDurationTimer()
    }

    // MARK: - Private Helpers

    private func calculateCurrentDuration() -> TimeInterval {
        if isPaused {
            return accumulatedDuration
        }

        guard let startTime = recordingStartTime else {
            return accumulatedDuration
        }

        return accumulatedDuration + Date().timeIntervalSince(startTime)
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

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateDuration()
            }
        }
    }

    private func stopTimers() {
        meteringTimer?.invalidate()
        meteringTimer = nil
        durationTimer?.invalidate()
        durationTimer = nil

        // Finish the audio levels stream
        audioLevelContinuation?.finish()
        audioLevelContinuation = nil
    }

    private func updateMetering() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }

        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)

        // Normalize from dB (-160...0) to 0...1 range
        // AVAudioRecorder reports average power in dB where 0 dB is max and -160 dB is silence
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

    private func updateDuration() {
        let duration = calculateCurrentDuration()
        currentDuration = duration

        // Auto-stop at maximum duration
        if duration >= Self.maxRecordingDuration {
            _ = stopRecording()
        }
    }

    // MARK: - Interruption Handling

    private func registerForInterruptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    private func unregisterFromInterruptionNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc
    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Audio session was interrupted - pause recording
            pauseRecording()
        case .ended:
            // Check if we should resume
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                resumeRecording()
            }
        @unknown default:
            break
        }
    }

    // MARK: - Cleanup

    /// Deletes a temporary audio file at the given URL
    public func cleanupAudioFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

}
#endif
