// PromptGenerationServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for generating daily prompts
/// Local implementation uses a curated prompt bank; Cloud implementation calls AI API
public protocol PromptGenerationServiceProtocol: Sendable {
    /// Generate a prompt for a circle
    /// - Parameters:
    ///   - circleId: The circle to generate a prompt for
    ///   - weekNumber: How many weeks the circle has been active (affects depth tier)
    ///   - recentPrompts: Recent prompt texts to avoid repetition
    /// - Returns: The generated prompt text
    func generatePrompt(circleId: UUID, weekNumber: Int, recentPrompts: [String]) async throws -> String
}

/// Depth tiers for prompt progression
public enum PromptTier: Int, Codable, Sendable {
    /// Weeks 1-2: Light, fun questions
    case light = 1
    /// Weeks 3-4: Medium depth questions
    case medium = 2
    /// Weeks 5+: Deep connection questions
    case deep = 3

    public static func forWeek(_ weekNumber: Int) -> PromptTier {
        switch weekNumber {
        case 1...2: return .light
        case 3...4: return .medium
        default: return .deep
        }
    }
}
