// LocalPromptRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// JSON file-backed implementation of PromptRepositoryProtocol
/// Stores each prompt as a separate JSON file: {documentsDir}/prompts/{circleId}/{promptId}.json
public final class LocalPromptRepository: PromptRepositoryProtocol, @unchecked Sendable {

    // MARK: - Properties

    private let lock = NSLock()
    private let baseDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Init

    public init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.baseDirectory = documentsPath.appendingPathComponent("prompts", isDirectory: true)

        self.encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Ensure base directory exists
        try? FileManager.default.createDirectory(
            at: baseDirectory,
            withIntermediateDirectories: true
        )
    }

    // MARK: - PromptRepositoryProtocol

    public func save(_ prompt: DailyPrompt) async throws {
        lock.lock()
        defer { lock.unlock() }

        let circleDir = circleDirectory(for: prompt.circleId)
        try? FileManager.default.createDirectory(at: circleDir, withIntermediateDirectories: true)

        let url = fileURL(circleId: prompt.circleId, promptId: prompt.id)
        let data = try encoder.encode(prompt)
        try data.write(to: url, options: .atomic)
    }

    public func update(_ prompt: DailyPrompt) async throws {
        // For JSON file storage, update is the same as save (overwrite)
        try await save(prompt)
    }

    public func fetchToday(circleId: UUID) async throws -> DailyPrompt? {
        lock.lock()
        defer { lock.unlock() }

        let allPrompts = try loadAll(circleId: circleId)
        return allPrompts.first { $0.isToday }
    }

    public func fetchHistory(circleId: UUID, limit: Int?) async throws -> [DailyPrompt] {
        lock.lock()
        defer { lock.unlock() }

        let allPrompts = try loadAll(circleId: circleId)
        let sorted = allPrompts.sorted { $0.generatedAt > $1.generatedAt }

        if let limit = limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }

    public func fetch(id: UUID) async throws -> DailyPrompt? {
        lock.lock()
        defer { lock.unlock() }

        // We need to search across all circle directories since we only have the prompt ID
        return try findPrompt(id: id)
    }

    public func fetchRecent(circleId: UUID, count: Int) async throws -> [DailyPrompt] {
        lock.lock()
        defer { lock.unlock() }

        let allPrompts = try loadAll(circleId: circleId)
        let sorted = allPrompts.sorted { $0.generatedAt > $1.generatedAt }
        return Array(sorted.prefix(count))
    }

    // MARK: - Private Helpers

    private func circleDirectory(for circleId: UUID) -> URL {
        baseDirectory.appendingPathComponent(circleId.uuidString, isDirectory: true)
    }

    private func fileURL(circleId: UUID, promptId: UUID) -> URL {
        circleDirectory(for: circleId).appendingPathComponent("\(promptId.uuidString).json")
    }

    /// Load all prompts for a given circle from disk.
    /// Must be called within a lock.
    private func loadAll(circleId: UUID) throws -> [DailyPrompt] {
        let circleDir = circleDirectory(for: circleId)
        guard FileManager.default.fileExists(atPath: circleDir.path) else { return [] }

        let contents = try FileManager.default.contentsOfDirectory(
            at: circleDir,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )

        return contents
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> DailyPrompt? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(DailyPrompt.self, from: data)
            }
    }

    /// Search all circle directories for a prompt by ID.
    /// Must be called within a lock.
    private func findPrompt(id: UUID) throws -> DailyPrompt? {
        guard FileManager.default.fileExists(atPath: baseDirectory.path) else { return nil }

        let circleDirs = try FileManager.default.contentsOfDirectory(
            at: baseDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )

        for circleDir in circleDirs where circleDir.hasDirectoryPath {
            let promptURL = circleDir.appendingPathComponent("\(id.uuidString).json")
            if FileManager.default.fileExists(atPath: promptURL.path) {
                let data = try Data(contentsOf: promptURL)
                return try decoder.decode(DailyPrompt.self, from: data)
            }
        }

        return nil
    }
}
#endif
