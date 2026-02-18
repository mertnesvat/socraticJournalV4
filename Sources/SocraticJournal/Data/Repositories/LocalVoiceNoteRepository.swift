// LocalVoiceNoteRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// JSON file-backed implementation of VoiceNoteRepositoryProtocol
/// Metadata stored as individual JSON files: {documentsDir}/voicenotes/{voiceNoteId}.json
/// Audio files are stored at the path in VoiceNote.localAudioPath (relative to documents dir)
public final class LocalVoiceNoteRepository: VoiceNoteRepositoryProtocol, Sendable {

    // MARK: - Constants

    private static let metadataDirectory = "voicenotes"

    // MARK: - Private

    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Init

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        self.encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Create metadata directory on init
        let dir = Self.metadataDirectoryURL()
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
    }

    // MARK: - VoiceNoteRepositoryProtocol

    public func save(_ voiceNote: VoiceNote) async throws {
        let url = Self.metadataURL(for: voiceNote.id)
        let data = try encoder.encode(voiceNote)
        try data.write(to: url, options: .atomic)
    }

    public func fetchForPrompt(promptId: UUID) async throws -> [VoiceNote] {
        let all = try await loadAll()
        return all.filter { $0.promptId == promptId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func fetch(id: UUID) async throws -> VoiceNote? {
        let url = Self.metadataURL(for: id)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(VoiceNote.self, from: data)
    }

    public func update(_ voiceNote: VoiceNote) async throws {
        // Overwrite is the same as save for JSON files
        try await save(voiceNote)
    }

    public func delete(id: UUID) async throws {
        // Load to get audio path before deleting metadata
        if let voiceNote = try await fetch(id: id) {
            // Delete audio file
            let documentsDir = Self.documentsDirectory()
            let audioURL = documentsDir.appendingPathComponent(voiceNote.localAudioPath)
            if fileManager.fileExists(atPath: audioURL.path) {
                try fileManager.removeItem(at: audioURL)
            }
        }

        // Delete metadata JSON
        let metadataURL = Self.metadataURL(for: id)
        if fileManager.fileExists(atPath: metadataURL.path) {
            try fileManager.removeItem(at: metadataURL)
        }
    }

    public func fetchByUser(userId: UUID) async throws -> [VoiceNote] {
        let all = try await loadAll()
        return all.filter { $0.userId == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Private Helpers

    private func loadAll() async throws -> [VoiceNote] {
        let dir = Self.metadataDirectoryURL()
        guard fileManager.fileExists(atPath: dir.path) else { return [] }

        let contents = try fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )

        let jsonFiles = contents.filter { $0.pathExtension == "json" }

        var notes: [VoiceNote] = []
        for fileURL in jsonFiles {
            if let data = try? Data(contentsOf: fileURL),
               let note = try? decoder.decode(VoiceNote.self, from: data) {
                notes.append(note)
            }
        }
        return notes
    }

    private static func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private static func metadataDirectoryURL() -> URL {
        documentsDirectory().appendingPathComponent(metadataDirectory, isDirectory: true)
    }

    private static func metadataURL(for id: UUID) -> URL {
        metadataDirectoryURL().appendingPathComponent("\(id.uuidString).json")
    }
}
