// AudioStorageServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining audio file storage operations
/// Abstracts local vs remote storage (Firebase Storage, etc.)
public protocol AudioStorageServiceProtocol: Sendable {
    /// Upload an audio file and return a URL/path for retrieval
    func uploadAudio(from localURL: URL, circleId: String, promptId: String, userId: String) async throws -> String

    /// Download an audio file to a local cache and return the local URL
    func downloadAudio(remotePath: String) async throws -> URL

    /// Delete an audio file
    func deleteAudio(remotePath: String) async throws

    /// Check if an audio file exists locally in cache
    func isAudioCached(remotePath: String) async -> Bool
}
