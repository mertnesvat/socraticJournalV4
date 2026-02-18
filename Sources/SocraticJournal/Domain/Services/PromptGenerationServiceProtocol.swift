// PromptGenerationServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining prompt generation operations
/// Abstracts local library vs AI-powered generation
public protocol PromptGenerationServiceProtocol: Sendable {
    /// Generate a prompt for a circle, avoiding previously used prompts
    func generatePrompt(for circleId: String, excludingIds: Set<String>, isNewCircle: Bool) async throws -> DailyPrompt
}
