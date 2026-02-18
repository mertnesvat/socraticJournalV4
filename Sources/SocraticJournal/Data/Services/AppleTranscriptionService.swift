// AppleTranscriptionService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import Speech

/// On-device speech-to-text using Apple Speech framework (SFSpeechRecognizer).
/// Fully local, free, and private. No server dependency.
public final class AppleTranscriptionService: TranscriptionServiceProtocol, @unchecked Sendable {
    private let recognizer: SFSpeechRecognizer?

    public init(locale: Locale = .current) {
        self.recognizer = SFSpeechRecognizer(locale: locale)
    }

    public func transcribe(audioURL: URL) async throws -> String {
        guard let recognizer, recognizer.isAvailable else {
            throw TranscriptionError.unavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = true

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: TranscriptionError.recognitionFailed(error.localizedDescription))
                    return
                }
                if let result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }

    public func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    public func isAvailable() async -> Bool {
        recognizer?.isAvailable ?? false
    }
}

public enum TranscriptionError: Error, LocalizedError {
    case unavailable
    case recognitionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Speech recognition is not available on this device"
        case .recognitionFailed(let reason):
            return "Transcription failed: \(reason)"
        }
    }
}
#endif
