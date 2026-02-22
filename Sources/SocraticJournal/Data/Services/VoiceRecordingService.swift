// VoiceRecordingService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation

/// Real AVAudioRecorder/AVAudioPlayer implementation of VoiceRecordingServiceProtocol.
/// Records audio in AAC format at 44.1kHz with real-time metering for waveform visualization.
@Observable
@MainActor
public final class VoiceRecordingService: VoiceRecordingServiceProtocol, @unchecked Sendable {

    // MARK: - Public State

    public private(set) var isRecording: Bool = false
    public private(set) var isPlaying: Bool = false
    public private(set) var currentAmplitude: Float = 0
    public private(set) var currentPlaybackTime: TimeInterval = 0
    public private(set) var totalDuration: TimeInterval = 0

    // MARK: - Private State

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var meteringTimer: Timer?
    private var playbackTimer: Timer?
    private var recordingStartTime: Date?
    private var maxRecordingDuration: TimeInterval = 60
    private var playerDelegate: AudioPlayerDelegate?

    // MARK: - Recording Directory

    private var recordingsDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsDir = documentsPath.appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: recordingsDir, withIntermediateDirectories: true)
        return recordingsDir
    }

    // MARK: - Initialization

    public init() {
        setupInterruptionObserver()
        setupRouteChangeObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - VoiceRecordingServiceProtocol

    public func startRecording() async throws {
        // Request microphone permission
        let permissionGranted = await requestMicrophonePermission()
        guard permissionGranted else {
            throw VoiceRecordingError.microphonePermissionDenied
        }

        // Stop any current recording or playback
        if isRecording {
            _ = try await stopRecording()
        }
        if isPlaying {
            await stopPlayback()
        }

        // Configure audio session
        try configureAudioSession()

        // Generate file URL with timestamp
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileURL = recordingsDirectory.appendingPathComponent("recording_\(timestamp).m4a")

        // Configure recorder settings: AAC at 44.1kHz, mono channel
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // Create and start the recorder
        let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()

        guard recorder.record() else {
            throw VoiceRecordingError.recordingFailed
        }

        audioRecorder = recorder
        isRecording = true
        currentAmplitude = 0
        recordingStartTime = Date()

        // Start metering timer at 50ms intervals for real-time amplitude updates
        startMeteringTimer()

        #if DEBUG
        print("[VoiceRecordingService] Recording started: \(fileURL.lastPathComponent)")
        #endif
    }

    public func stopRecording() async throws -> String {
        guard let recorder = audioRecorder, isRecording else {
            throw VoiceRecordingError.notRecording
        }

        // Stop metering and recording
        stopMeteringTimer()
        recorder.stop()

        let fileURL = recorder.url
        audioRecorder = nil
        isRecording = false
        currentAmplitude = 0
        recordingStartTime = nil

        // Deactivate the audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        #if DEBUG
        print("[VoiceRecordingService] Recording stopped: \(fileURL.lastPathComponent)")
        #endif

        return fileURL.path
    }

    public func playRecording(url: String) async throws {
        // Stop any current playback
        if isPlaying {
            await stopPlayback()
        }

        let fileURL = URL(fileURLWithPath: url)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw VoiceRecordingError.fileNotFound
        }

        // Configure audio session for playback
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)

        // Create and start the player
        let player = try AVAudioPlayer(contentsOf: fileURL)
        player.prepareToPlay()

        // Set up delegate to detect playback completion
        let delegate = AudioPlayerDelegate { [weak self] in
            Task { @MainActor in
                self?.handlePlaybackFinished()
            }
        }
        playerDelegate = delegate
        player.delegate = delegate

        guard player.play() else {
            throw VoiceRecordingError.playbackFailed
        }

        audioPlayer = player
        isPlaying = true
        totalDuration = player.duration
        currentPlaybackTime = 0

        // Start playback progress timer
        startPlaybackTimer()

        #if DEBUG
        print("[VoiceRecordingService] Playback started: \(fileURL.lastPathComponent)")
        #endif
    }

    public func stopPlayback() async {
        stopPlaybackTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        playerDelegate = nil
        isPlaying = false
        currentPlaybackTime = 0

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        #if DEBUG
        print("[VoiceRecordingService] Playback stopped")
        #endif
    }

    public func deleteRecording(url: String) async throws {
        let fileURL = URL(fileURLWithPath: url)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw VoiceRecordingError.fileNotFound
        }

        try FileManager.default.removeItem(at: fileURL)

        #if DEBUG
        print("[VoiceRecordingService] Recording deleted: \(fileURL.lastPathComponent)")
        #endif
    }

    public func getRecordingDuration(url: String) async throws -> TimeInterval {
        let fileURL = URL(fileURLWithPath: url)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw VoiceRecordingError.fileNotFound
        }

        let player = try AVAudioPlayer(contentsOf: fileURL)
        return player.duration
    }

    // MARK: - Audio Session Configuration

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try session.setActive(true)
    }

    // MARK: - Microphone Permission

    private func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Metering Timer

    private func startMeteringTimer() {
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMetering()
            }
        }
    }

    private func stopMeteringTimer() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }

    private func updateMetering() {
        guard let recorder = audioRecorder, isRecording else { return }

        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        // Normalize: averagePower returns -160 (silence) to 0 (max).
        // Map to 0...1 range using a 60 dB dynamic range.
        let normalizedPower = max(0, 1 - (abs(power) / 60))
        currentAmplitude = normalizedPower

        // Auto-stop at max duration
        if let startTime = recordingStartTime,
           Date().timeIntervalSince(startTime) >= maxRecordingDuration {
            Task {
                _ = try? await self.stopRecording()
            }
        }
    }

    // MARK: - Playback Timer

    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePlaybackProgress()
            }
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func updatePlaybackProgress() {
        guard let player = audioPlayer, isPlaying else { return }
        currentPlaybackTime = player.currentTime
    }

    private func handlePlaybackFinished() {
        stopPlaybackTimer()
        audioPlayer = nil
        playerDelegate = nil
        isPlaying = false
        currentPlaybackTime = 0
    }

    // MARK: - Interruption Handling

    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleInterruption(notification)
            }
        }
    }

    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began (e.g., phone call). Stop recording/playback.
            if isRecording {
                Task {
                    _ = try? await self.stopRecording()
                }
            }
            if isPlaying {
                Task {
                    await self.stopPlayback()
                }
            }
            #if DEBUG
            print("[VoiceRecordingService] Audio session interrupted")
            #endif

        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                try? AVAudioSession.sharedInstance().setActive(true)
                #if DEBUG
                print("[VoiceRecordingService] Audio session interruption ended, resuming")
                #endif
            }

        @unknown default:
            break
        }
    }

    // MARK: - Route Change Handling

    private func setupRouteChangeObserver() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleRouteChange(notification)
            }
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .oldDeviceUnavailable:
            // Headphones unplugged — pause playback
            if isPlaying {
                Task {
                    await self.stopPlayback()
                }
            }
            #if DEBUG
            print("[VoiceRecordingService] Audio route changed: old device unavailable")
            #endif

        default:
            break
        }
    }
}

// MARK: - Audio Player Delegate

private final class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

// MARK: - Voice Recording Errors

public enum VoiceRecordingError: LocalizedError {
    case microphonePermissionDenied
    case recordingFailed
    case notRecording
    case playbackFailed
    case fileNotFound

    public var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone access is required to record audio. Please enable it in Settings."
        case .recordingFailed:
            return "Failed to start recording. Please try again."
        case .notRecording:
            return "No active recording to stop."
        case .playbackFailed:
            return "Failed to play the recording. The file may be corrupted."
        case .fileNotFound:
            return "Recording file not found. It may have been deleted."
        }
    }
}

#endif
