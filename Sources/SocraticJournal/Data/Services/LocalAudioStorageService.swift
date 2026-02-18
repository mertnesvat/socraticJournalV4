// LocalAudioStorageService.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Local filesystem audio storage service
/// Replace with FirebaseStorageService when Firebase Storage is integrated
public final class LocalAudioStorageService: AudioStorageServiceProtocol, @unchecked Sendable {
    private let fileManager = FileManager.default
    private let baseDirectory: URL

    public init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        baseDirectory = docs.appendingPathComponent("circle_audio", isDirectory: true)

        // Ensure base directory exists
        try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
    }

    public func uploadAudio(from localURL: URL, circleId: String, promptId: String, userId: String) async throws -> String {
        let dir = baseDirectory
            .appendingPathComponent(circleId, isDirectory: true)
            .appendingPathComponent(promptId, isDirectory: true)

        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)

        let destURL = dir.appendingPathComponent("\(userId).m4a")

        // Remove existing file if any
        if fileManager.fileExists(atPath: destURL.path) {
            try fileManager.removeItem(at: destURL)
        }

        try fileManager.copyItem(at: localURL, to: destURL)

        // Return a relative path that serves as the "remote" identifier
        return "circle_audio/\(circleId)/\(promptId)/\(userId).m4a"
    }

    public func downloadAudio(remotePath: String) async throws -> URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = docs.appendingPathComponent(remotePath)

        guard fileManager.fileExists(atPath: localURL.path) else {
            throw AudioStorageError.fileNotFound(remotePath)
        }

        return localURL
    }

    public func deleteAudio(remotePath: String) async throws {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = docs.appendingPathComponent(remotePath)

        if fileManager.fileExists(atPath: localURL.path) {
            try fileManager.removeItem(at: localURL)
        }
    }

    public func isAudioCached(remotePath: String) async -> Bool {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = docs.appendingPathComponent(remotePath)
        return fileManager.fileExists(atPath: localURL.path)
    }
}

/// Audio storage errors
public enum AudioStorageError: Error, LocalizedError {
    case fileNotFound(String)
    case uploadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path): return "Audio file not found: \(path)"
        case .uploadFailed(let msg): return "Upload failed: \(msg)"
        }
    }
}
