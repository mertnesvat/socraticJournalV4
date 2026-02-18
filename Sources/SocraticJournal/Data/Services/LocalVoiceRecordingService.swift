// LocalVoiceRecordingService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import AVFoundation
import Foundation
import SwiftData
import SwiftUI

/// Local voice recording service using AVAudioRecorder.
/// Records AAC/M4A audio, generates waveform data, and persists metadata via SwiftData.
@Observable
@MainActor
public final class LocalVoiceRecordingService: NSObject, VoiceRecordingServiceProtocol {
    // MARK: - Observable State

    public private(set) var isRecording: Bool = false
    public private(set) var currentAmplitude: Float = 0.0
    public private(set) var recordingDuration: TimeInterval = 0.0

    // MARK: - Private State

    private var audioRecorder: AVAudioRecorder?
    private var meteringTimer: Timer?
    private var durationTimer: Timer?
    private var recordingStartTime: Date?
    private var currentFilePath: String?
    private var currentCircleId: UUID?
    private var currentPromptId: UUID?
    private var amplitudeSamples: [Float] = []

    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        super.init()
    }

    // MARK: - VoiceRecordingServiceProtocol

    public func startRecording(circleId: UUID?, promptId: UUID?) async throws {
        // Request microphone permission
        let granted = await requestMicrophonePermission()
        guard granted else {
            throw VoiceRecordingError.microphonePermissionDenied
        }

        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        // Build file path: VoiceNotes/{circleId}/{date}/{noteId}.m4a
        let noteId = UUID()
        let dateString = Self.dateFormatter.string(from: Date())
        let circleFolder = circleId?.uuidString ?? "uncategorized"
        let relativePath = "VoiceNotes/\(circleFolder)/\(dateString)/\(noteId.uuidString).m4a"

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(relativePath)

        // Create directory structure
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        // Recording settings: AAC/M4A, 44100 Hz, high quality
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()

        guard recorder.record() else {
            throw VoiceRecordingError.recordingFailed
        }

        // Store state
        audioRecorder = recorder
        currentFilePath = relativePath
        currentCircleId = circleId
        currentPromptId = promptId
        amplitudeSamples = []
        recordingStartTime = Date()
        recordingDuration = 0.0
        currentAmplitude = 0.0
        isRecording = true

        // Start metering timer (amplitude sampling every 0.05s)
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMetering()
            }
        }

        // Start duration timer (update every 0.1s)
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDuration()
            }
        }
    }

    public func stopRecording() async throws -> VoiceNote {
        guard let recorder = audioRecorder, let filePath = currentFilePath else {
            throw VoiceRecordingError.noActiveRecording
        }

        // Stop timers and recorder
        stopTimers()
        recorder.stop()
        isRecording = false

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        // Compute final duration
        let duration = recorder.currentTime > 0
            ? recorder.currentTime
            : recordingDuration

        // Generate waveform data from the recorded audio file
        let waveformData = generateWaveformData(from: recorder.url)

        // Create and persist VoiceNote
        let voiceNote = VoiceNote(
            filePath: filePath,
            duration: duration,
            waveformData: waveformData,
            circleId: currentCircleId,
            promptId: currentPromptId
        )

        modelContext.insert(voiceNote)
        try modelContext.save()

        // Clean up state
        resetState()

        return voiceNote
    }

    public func cancelRecording() {
        guard let recorder = audioRecorder else { return }

        stopTimers()
        recorder.stop()

        // Delete the partially recorded file
        let fileURL = recorder.url
        try? FileManager.default.removeItem(at: fileURL)

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        isRecording = false
        resetState()
    }

    // MARK: - Private Helpers

    private func updateMetering() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.updateMeters()

        // Convert decibels to normalized 0...1 amplitude
        let decibels = recorder.averagePower(forChannel: 0)
        // Typical range is -160 dB (silence) to 0 dB (max).
        // We map -50...0 to 0...1 for a more responsive visualization.
        let normalizedAmplitude = max(0.0, min(1.0, (decibels + 50.0) / 50.0))
        currentAmplitude = normalizedAmplitude

        // Sample for waveform data (every ~0.05s, collect up to 1200 for 60s max)
        amplitudeSamples.append(normalizedAmplitude)
    }

    private func updateDuration() {
        guard let startTime = recordingStartTime else { return }
        recordingDuration = Date().timeIntervalSince(startTime)
    }

    private func stopTimers() {
        meteringTimer?.invalidate()
        meteringTimer = nil
        durationTimer?.invalidate()
        durationTimer = nil
    }

    private func resetState() {
        audioRecorder = nil
        currentFilePath = nil
        currentCircleId = nil
        currentPromptId = nil
        amplitudeSamples = []
        recordingStartTime = nil
        currentAmplitude = 0.0
        recordingDuration = 0.0
    }

    /// Generate waveform data by reading the audio file and downsampling to ~80 points.
    private func generateWaveformData(from url: URL) -> [Float] {
        // If we collected live amplitude samples, downsample those
        guard !amplitudeSamples.isEmpty else { return [] }

        let targetCount = 80
        let sampleCount = amplitudeSamples.count

        if sampleCount <= targetCount {
            return amplitudeSamples
        }

        // Downsample by averaging chunks
        var result: [Float] = []
        let chunkSize = sampleCount / targetCount

        for i in 0..<targetCount {
            let start = i * chunkSize
            let end = min(start + chunkSize, sampleCount)
            let chunk = amplitudeSamples[start..<end]
            let average = chunk.reduce(0, +) / Float(chunk.count)
            result.append(average)
        }

        return result
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - Voice Recording Errors

public enum VoiceRecordingError: LocalizedError {
    case microphonePermissionDenied
    case recordingFailed
    case noActiveRecording
    case saveFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone access is required to record voice notes. Please enable it in Settings."
        case .recordingFailed:
            return "Unable to start recording. Please try again."
        case .noActiveRecording:
            return "No active recording to stop."
        case .saveFailed(let error):
            return "Failed to save voice note: \(error.localizedDescription)"
        }
    }
}
#endif
