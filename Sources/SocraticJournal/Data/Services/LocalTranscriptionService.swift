// LocalTranscriptionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import Speech

/// Apple Speech framework implementation of TranscriptionServiceProtocol
/// Performs on-device speech recognition — no cloud APIs needed
public final class LocalTranscriptionService: TranscriptionServiceProtocol, @unchecked Sendable {

    // MARK: - Private

    private let recognizer: SFSpeechRecognizer?
    private let lock = NSLock()

    // MARK: - Init

    public init() {
        // Use device locale with English fallback
        if let deviceRecognizer = SFSpeechRecognizer() {
            self.recognizer = deviceRecognizer
        } else {
            self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
    }

    // MARK: - TranscriptionServiceProtocol

    public var isAvailable: Bool {
        guard let recognizer = recognizer else { return false }
        return recognizer.isAvailable
            && SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    public func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    public func transcribe(audioURL: URL) async -> String? {
        guard let recognizer = recognizer else {
            return nil
        }

        guard recognizer.isAvailable else {
            return nil
        }

        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            return nil
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        // Prefer on-device recognition when available
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        }

        do {
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SFSpeechRecognitionResult, Error>) in
                recognizer.recognitionTask(with: request) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let result = result, result.isFinal else {
                        // Wait for final result
                        return
                    }

                    continuation.resume(returning: result)
                }
            }
            let text = result.bestTranscription.formattedString
            return text.isEmpty ? nil : text
        } catch {
            // Graceful failure — voice notes work fine without transcripts
            return nil
        }
    }
}
#endif
