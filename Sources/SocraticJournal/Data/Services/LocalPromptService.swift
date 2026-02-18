// LocalPromptService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftData
import SwiftUI

/// Local prompt service backed by a bundled JSON file and SwiftData persistence.
/// Selects one deterministic prompt per circle per day, avoiding repeats within 90 days
/// and alternating categories between consecutive days.
@Observable
@MainActor
public final class LocalPromptService: PromptServiceProtocol {
    // MARK: - Types

    /// Lightweight Codable struct matching the bundled prompts.json format.
    private struct PromptData: Codable {
        let id: String
        let text: String
        let category: String
        let depth: Int
    }

    private struct PromptFile: Codable {
        let prompts: [PromptData]
    }

    // MARK: - Constants

    /// Number of days before a prompt can be reused for the same circle.
    private static let repeatWindowDays = 90

    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    /// Cached prompts loaded from the bundled JSON file.
    private var promptPool: [PromptData] = []

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.promptPool = Self.loadPromptPool()
    }

    // MARK: - PromptServiceProtocol

    public func getTodaysPrompt(for circleId: UUID) async throws -> Prompt {
        let today = Calendar.current.startOfDay(for: Date())

        // Check if a prompt has already been assigned for today
        if let existing = try fetchTodaysAssignedPrompt(circleId: circleId, date: today) {
            return existing
        }

        // Select a new prompt for today
        let selectedData = try selectPrompt(for: circleId, on: today)

        // Create and persist the assigned prompt
        let prompt = Prompt(
            id: UUID(uuidString: selectedData.id) ?? UUID(),
            text: selectedData.text,
            category: PromptCategory(rawValue: selectedData.category) ?? .dailyMoments,
            depth: selectedData.depth,
            dateAssigned: today,
            circleId: circleId,
            isSeen: false
        )

        modelContext.insert(prompt)
        try modelContext.save()

        return prompt
    }

    public func getPromptHistory(for circleId: UUID) async throws -> [Prompt] {
        let descriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.circleId == circleId && prompt.dateAssigned != nil
            },
            sortBy: [SortDescriptor(\.dateAssigned, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func markPromptSeen(id: UUID) async throws {
        let descriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.id == id
            }
        )
        guard let prompt = try modelContext.fetch(descriptor).first else { return }
        prompt.isSeen = true
        try modelContext.save()
    }

    // MARK: - Private Helpers

    /// Load the prompt pool from the bundled prompts.json resource.
    private static func loadPromptPool() -> [PromptData] {
        guard let url = Bundle.main.url(forResource: "prompts", withExtension: "json") else {
            assertionFailure("prompts.json not found in bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let file = try JSONDecoder().decode(PromptFile.self, from: data)
            return file.prompts
        } catch {
            assertionFailure("Failed to decode prompts.json: \(error)")
            return []
        }
    }

    /// Fetch the prompt already assigned to this circle for the given date.
    private func fetchTodaysAssignedPrompt(circleId: UUID, date: Date) throws -> Prompt? {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date

        let descriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.circleId == circleId
                    && prompt.dateAssigned != nil
                    && prompt.dateAssigned! >= date
                    && prompt.dateAssigned! < tomorrow
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// Select a prompt that hasn't been used in the last 90 days and doesn't repeat
    /// yesterday's category.
    private func selectPrompt(for circleId: UUID, on date: Date) throws -> PromptData {
        guard !promptPool.isEmpty else {
            throw PromptServiceError.noPromptsAvailable
        }

        // Get recently used prompt IDs for this circle (last 90 days)
        let cutoff = Calendar.current.date(byAdding: .day, value: -Self.repeatWindowDays, to: date) ?? date
        let recentDescriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.circleId == circleId
                    && prompt.dateAssigned != nil
                    && prompt.dateAssigned! >= cutoff
            }
        )
        let recentPrompts = try modelContext.fetch(recentDescriptor)
        let recentIds = Set(recentPrompts.map { $0.id.uuidString.lowercased() })

        // Get yesterday's category to avoid repeating it
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        let yesterdayPrompt = try fetchTodaysAssignedPrompt(circleId: circleId, date: yesterday)
        let yesterdayCategory = yesterdayPrompt?.categoryRaw

        // Filter candidates: not recently used, different category than yesterday
        var candidates = promptPool.filter { data in
            !recentIds.contains(data.id.lowercased())
                && data.category != yesterdayCategory
        }

        // If no candidates with different category, relax the category constraint
        if candidates.isEmpty {
            candidates = promptPool.filter { data in
                !recentIds.contains(data.id.lowercased())
            }
        }

        // If all prompts have been used recently, use the full pool
        if candidates.isEmpty {
            candidates = promptPool
        }

        // Use date + circleId as a deterministic seed for consistent daily selection
        let seed = Self.deterministicSeed(date: date, circleId: circleId)
        let index = seed % candidates.count
        return candidates[index]
    }

    /// Generate a deterministic integer seed from a date and circle ID.
    /// This ensures the same prompt is selected for the same circle on the same day,
    /// even if the app is restarted.
    private static func deterministicSeed(date: Date, circleId: UUID) -> Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        // Combine date components with circle ID hash for uniqueness
        let dateValue = year * 10000 + month * 100 + day
        let circleHash = abs(circleId.uuidString.hashValue)
        return abs(dateValue &+ circleHash)
    }
}

// MARK: - Prompt Service Errors

public enum PromptServiceError: LocalizedError {
    case noPromptsAvailable
    case promptNotFound

    public var errorDescription: String? {
        switch self {
        case .noPromptsAvailable:
            return "No prompts are available. Please try again later."
        case .promptNotFound:
            return "Prompt not found."
        }
    }
}
#endif
