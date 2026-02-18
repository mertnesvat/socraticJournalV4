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

    // MARK: - Feedback

    /// Submit feedback (thumbs up/down) for a prompt in a circle.
    /// Creates or updates existing feedback for the given prompt.
    /// - Parameters:
    ///   - promptId: The prompt being rated.
    ///   - circleId: The circle context.
    ///   - rating: The user's rating.
    ///   - category: The prompt's category (denormalized for efficient queries).
    func submitFeedback(promptId: UUID, circleId: UUID, rating: PromptRating, category: PromptCategory) throws

    /// Get existing feedback for a prompt in a circle, if any.
    /// - Parameters:
    ///   - promptId: The prompt identifier.
    ///   - circleId: The circle identifier.
    /// - Returns: The existing PromptFeedback, or nil if none exists.
    func getFeedback(promptId: UUID, circleId: UUID) throws -> PromptFeedback?

    // MARK: - Streak

    /// Compute the streak data for a circle by counting consecutive active days.
    /// - Parameter circleId: The circle to compute streaks for.
    /// - Returns: Tuple of (currentStreak, longestStreak, lastActiveDate).
    func computeStreak(for circleId: UUID) throws -> (current: Int, longest: Int, lastActiveDate: Date?)
}
