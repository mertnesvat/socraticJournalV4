// VoiceNoteRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for voice note data persistence
/// Local implementation uses JSON files + file system; Firebase uses Firestore + Storage
public protocol VoiceNoteRepositoryProtocol: Sendable {
    /// Save a voice note (metadata only — audio file is already on disk)
    func save(_ voiceNote: VoiceNote) async throws

    /// Fetch all voice notes for a given prompt
    func fetchForPrompt(promptId: UUID) async throws -> [VoiceNote]

    /// Fetch a specific voice note by ID
    func fetch(id: UUID) async throws -> VoiceNote?

    /// Update a voice note (e.g., to add transcript)
    func update(_ voiceNote: VoiceNote) async throws

    /// Delete a voice note and its associated audio file
    func delete(id: UUID) async throws

    /// Fetch all voice notes by a user across all circles
    func fetchByUser(userId: UUID) async throws -> [VoiceNote]
}
