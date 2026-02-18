// PromptRepositoryProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining prompt data operations
public protocol PromptRepositoryProtocol: Sendable {
    /// Fetch today's prompt for a circle
    func getTodaysPrompt(for circleId: String) async throws -> DailyPrompt?

    /// Save a prompt
    func savePrompt(_ prompt: DailyPrompt) async throws

    /// Fetch prompt history for a circle
    func getPromptHistory(for circleId: String, limit: Int) async throws -> [DailyPrompt]

    /// Get IDs of prompts already used in a circle (for deduplication)
    func getUsedPromptIds(for circleId: String) async throws -> Set<String>

    /// Increment the response count for a prompt
    func incrementResponseCount(promptId: String) async throws
}
