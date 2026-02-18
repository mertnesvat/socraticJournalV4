// InMemoryPromptRepository.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// In-memory prompt repository with UserDefaults persistence
/// Replace with FirestorePromptRepository when Firebase is integrated
public final class InMemoryPromptRepository: PromptRepositoryProtocol, @unchecked Sendable {
    private var prompts: [String: [DailyPrompt]] // circleId -> prompts
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults: UserDefaults
    private static let storageKey = "circle_prompts_data"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.prompts = [:]
        loadFromDisk()
    }

    public func getTodaysPrompt(for circleId: String) async throws -> DailyPrompt? {
        prompts[circleId]?.first { $0.isToday }
    }

    public func savePrompt(_ prompt: DailyPrompt) async throws {
        var circlePrompts = prompts[prompt.circleId] ?? []
        // Replace if same day prompt exists
        circlePrompts.removeAll { $0.id == prompt.id }
        circlePrompts.insert(prompt, at: 0)
        prompts[prompt.circleId] = circlePrompts
        saveToDisk()
    }

    public func getPromptHistory(for circleId: String, limit: Int) async throws -> [DailyPrompt] {
        let circlePrompts = prompts[circleId] ?? []
        return Array(circlePrompts.sorted { $0.generatedAt > $1.generatedAt }.prefix(limit))
    }

    public func getUsedPromptIds(for circleId: String) async throws -> Set<String> {
        Set((prompts[circleId] ?? []).map(\.id))
    }

    public func incrementResponseCount(promptId: String) async throws {
        for (circleId, circlePrompts) in prompts {
            if let index = circlePrompts.firstIndex(where: { $0.id == promptId }) {
                prompts[circleId]?[index].responseCount += 1
                saveToDisk()
                return
            }
        }
    }

    // MARK: - Persistence

    private func saveToDisk() {
        if let data = try? encoder.encode(prompts) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    private func loadFromDisk() {
        if let data = defaults.data(forKey: Self.storageKey),
           let saved = try? decoder.decode([String: [DailyPrompt]].self, from: data) {
            prompts = saved
        }
    }
}
