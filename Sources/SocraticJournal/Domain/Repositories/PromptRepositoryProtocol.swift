// PromptRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for daily prompt data persistence
/// Local implementation uses JSON files; Firestore implementation uses cloud database
public protocol PromptRepositoryProtocol: Sendable {
    /// Save a new prompt
    func save(_ prompt: DailyPrompt) async throws

    /// Update an existing prompt (e.g., to add a respondedUserId)
    func update(_ prompt: DailyPrompt) async throws

    /// Fetch today's prompt for a circle (nil if none generated yet)
    func fetchToday(circleId: UUID) async throws -> DailyPrompt?

    /// Fetch prompt history for a circle, most recent first
    func fetchHistory(circleId: UUID, limit: Int?) async throws -> [DailyPrompt]

    /// Fetch a specific prompt by ID
    func fetch(id: UUID) async throws -> DailyPrompt?

    /// Fetch the most recent N prompts for deduplication
    func fetchRecent(circleId: UUID, count: Int) async throws -> [DailyPrompt]
}
