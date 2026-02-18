// LocalTranscriptionService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import Speech

/// On-device speech-to-text transcription using Apple's Speech framework.
/// Uses `SFSpeechRecognizer` with `SFSpeechURLRecognitionRequest` for file-based transcription.
@Observable
@MainActor
public final class LocalTranscriptionService: TranscriptionServiceProtocol {
    // MARK: - State

    public private(set) var isAvailable: Bool = false

    // MARK: - Private

    private let speechRecognizer: SFSpeechRecognizer?

    // MARK: - Init

    public init(locale: Locale = Locale(identifier: "en-US")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        updateAvailability()
    }

    // MARK: - TranscriptionServiceProtocol

    public func transcribe(audioURL: URL) async throws -> String? {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            return nil
        }

        // Check authorization status
        let status = SFSpeechRecognizer.authorizationStatus()
        guard status == .authorized else {
            return nil
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        // Prefer on-device recognition when available
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        }

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    // If recognition fails, return nil rather than throwing
                    // to avoid blocking the recording flow
                    continuation.resume(returning: nil)
                    return
                }

                guard let result, result.isFinal else {
                    // Wait for the final result; ignore partial results
                    return
                }

                let transcript = result.bestTranscription.formattedString
                continuation.resume(returning: transcript.isEmpty ? nil : transcript)
            }
        }
    }

    public func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                let granted = status == .authorized
                Task { @MainActor [weak self] in
                    self?.updateAvailability()
                }
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Private

    private func updateAvailability() {
        let status = SFSpeechRecognizer.authorizationStatus()
        let recognizerAvailable = speechRecognizer?.isAvailable ?? false
        isAvailable = (status == .authorized) && recognizerAvailable
    }
}
#endif
