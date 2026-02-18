// InMemoryVoiceNoteRepository.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// In-memory voice note repository with UserDefaults persistence
/// Replace with FirestoreVoiceNoteRepository when Firebase is integrated
public final class InMemoryVoiceNoteRepository: VoiceNoteRepositoryProtocol, @unchecked Sendable {
    private var voiceNotes: [String: VoiceNote] // voiceNote.id -> VoiceNote
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults: UserDefaults
    private static let storageKey = "circle_voice_notes_data"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.voiceNotes = [:]
        loadFromDisk()
    }

    public func saveVoiceNote(_ voiceNote: VoiceNote) async throws {
        voiceNotes[voiceNote.id] = voiceNote
        saveToDisk()
    }

    public func getVoiceNotes(circleId: String, promptId: String) async throws -> [VoiceNote] {
        voiceNotes.values
            .filter { $0.circleId == circleId && $0.promptId == promptId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    public func getVoiceNote(id: String) async throws -> VoiceNote? {
        voiceNotes[id]
    }

    public func deleteVoiceNote(id: String) async throws {
        voiceNotes.removeValue(forKey: id)
        saveToDisk()
    }

    public func markAsListened(id: String) async throws {
        voiceNotes[id]?.isListened = true
        saveToDisk()
    }

    public func hasUserResponded(userId: String, promptId: String) async throws -> Bool {
        voiceNotes.values.contains { $0.authorId == userId && $0.promptId == promptId }
    }

    // MARK: - Persistence

    private func saveToDisk() {
        if let data = try? encoder.encode(Array(voiceNotes.values)) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    private func loadFromDisk() {
        if let data = defaults.data(forKey: Self.storageKey),
           let saved = try? decoder.decode([VoiceNote].self, from: data) {
            for note in saved {
                voiceNotes[note.id] = note
            }
        }
    }
}
