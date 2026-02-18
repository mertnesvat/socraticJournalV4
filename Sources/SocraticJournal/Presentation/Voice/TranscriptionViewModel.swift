// TranscriptionViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import Speech

/// ViewModel for managing speech-to-text transcription of voice notes
/// Handles permission checking, transcription execution, and persistence
@Observable
@MainActor
public final class TranscriptionViewModel {

    // MARK: - State

    public private(set) var isTranscribing = false
    public private(set) var permissionGranted = false
    public private(set) var permissionDenied = false
    public var error: String?

    // MARK: - Dependencies

    private let transcriptionService: TranscriptionServiceProtocol
    private let voiceNoteRepository: VoiceNoteRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Init

    public init(
        transcriptionService: TranscriptionServiceProtocol,
        voiceNoteRepository: VoiceNoteRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.transcriptionService = transcriptionService
        self.voiceNoteRepository = voiceNoteRepository
        self.analyticsService = analyticsService
    }

    // MARK: - Permission

    public func checkPermission() {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            permissionGranted = true
            permissionDenied = false
        case .denied, .restricted:
            permissionGranted = false
            permissionDenied = true
        case .notDetermined:
            permissionGranted = false
            permissionDenied = false
        @unknown default:
            permissionGranted = false
            permissionDenied = false
        }
    }

    // MARK: - Transcription

    /// Transcribe the audio from a voice note and save the result
    /// - Parameter voiceNote: The voice note to transcribe
    /// - Returns: The updated voice note with transcript, or the original if transcription failed
    @discardableResult
    public func transcribeAndSave(voiceNote: VoiceNote) async -> VoiceNote {
        // Skip if already transcribed
        if voiceNote.transcript != nil {
            return voiceNote
        }

        // Check/request permission
        if !permissionGranted && !permissionDenied {
            let granted = await transcriptionService.requestPermission()
            permissionGranted = granted
            permissionDenied = !granted
        }

        guard permissionGranted else {
            error = "Speech recognition permission not granted."
            return voiceNote
        }

        isTranscribing = true
        error = nil

        // Build the full audio file URL
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsDir.appendingPathComponent(voiceNote.localAudioPath)

        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            error = "Audio file not found."
            isTranscribing = false
            return voiceNote
        }

        // Perform transcription
        let transcript = await transcriptionService.transcribe(audioURL: audioURL)

        isTranscribing = false

        guard let transcript = transcript, !transcript.isEmpty else {
            // Graceful failure: no error shown to user, voice note works fine without transcript
            return voiceNote
        }

        // Update voice note with transcript
        var updatedNote = voiceNote
        updatedNote.transcript = transcript
        analyticsService?.logEvent(.transcriptViewed)

        // Persist the updated voice note
        do {
            try await voiceNoteRepository.update(updatedNote)
        } catch {
            self.error = "Failed to save transcript."
        }

        return updatedNote
    }
}
#endif
