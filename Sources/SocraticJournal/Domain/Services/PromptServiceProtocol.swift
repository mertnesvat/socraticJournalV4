// PromptServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining daily prompt operations.
/// All implementations are local-only -- no network calls.
@MainActor
public protocol PromptServiceProtocol: AnyObject {
    /// Get today's prompt for a given circle.
    /// If no prompt has been assigned today, one is selected deterministically
    /// and persisted for the day.
    /// - Parameter circleId: The circle to get the prompt for.
    /// - Returns: Today's assigned Prompt.
    func getTodaysPrompt(for circleId: UUID) async throws -> Prompt

    /// Get the history of assigned prompts for a given circle,
    /// ordered by most recent first.
    /// - Parameter circleId: The circle to fetch history for.
    /// - Returns: Array of previously assigned Prompts.
    func getPromptHistory(for circleId: UUID) async throws -> [Prompt]

    /// Mark a prompt as seen by the current user.
    /// - Parameter id: The prompt identifier.
    func markPromptSeen(id: UUID) async throws
}
