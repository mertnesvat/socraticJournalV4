// VoiceNoteRepositoryProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining voice note data operations
public protocol VoiceNoteRepositoryProtocol: Sendable {
    /// Save a voice note
    func saveVoiceNote(_ voiceNote: VoiceNote) async throws

    /// Fetch all voice notes for a specific circle and prompt
    func getVoiceNotes(circleId: String, promptId: String) async throws -> [VoiceNote]

    /// Fetch a single voice note by ID
    func getVoiceNote(id: String) async throws -> VoiceNote?

    /// Delete a voice note
    func deleteVoiceNote(id: String) async throws

    /// Mark a voice note as listened
    func markAsListened(id: String) async throws

    /// Check if a user has responded to a specific prompt
    func hasUserResponded(userId: String, promptId: String) async throws -> Bool
}
