// PersonalityAnalysisServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the personality analysis service
/// Analyzes journal entries to generate Big Five personality profiles
public protocol PersonalityAnalysisServiceProtocol: Sendable {
    /// Analyzes journal sessions to generate a Big Five personality profile
    /// - Parameter sessions: Array of completed journal sessions
    /// - Returns: A Big Five personality profile
    func analyzePersonality(from sessions: [JournalSession]) async throws -> BigFiveProfile

    /// Generates a sample personality profile for preview
    /// - Returns: A sample Big Five profile with disclaimer
    func generateSampleProfile() async throws -> BigFiveProfile
}

/// Errors that can occur in the personality analysis service
public enum PersonalityAnalysisError: Error, LocalizedError {
    case insufficientData(required: Int, available: Int)
    case analysisUnavailable
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .insufficientData(let required, let available):
            return "Need at least \(required) journal entries. Currently have \(available)."
        case .analysisUnavailable:
            return "Personality analysis is currently unavailable."
        case .invalidResponse:
            return "Received an invalid response from the analysis service."
        }
    }
}

/// Unlock state for character discovery feature
public enum CharacterDiscoveryUnlockState: Equatable, Sendable {
    /// Feature is locked, user needs to journal more
    case locked(progress: Double, entriesNeeded: Int)
    /// Feature is in sample mode with preview data
    case sample(progress: Double)
    /// Feature is fully unlocked
    case available(progress: Double)

    /// Progress percentage (0-100)
    public var progressPercent: Double {
        switch self {
        case .locked(let progress, _): return progress
        case .sample(let progress): return progress
        case .available(let progress): return progress
        }
    }

    /// Whether the full profile is accessible
    public var isUnlocked: Bool {
        if case .available = self { return true }
        return false
    }

    /// Whether sample data should be shown
    public var showsSample: Bool {
        if case .sample = self { return true }
        return false
    }

    /// Message to display to user
    public var statusMessage: String {
        switch self {
        case .locked(_, let entriesNeeded):
            return "Journal \(entriesNeeded) more time\(entriesNeeded == 1 ? "" : "s") to unlock"
        case .sample:
            return "Preview mode - continue journaling for your personal insights"
        case .available:
            return "Your personality profile is ready"
        }
    }

    /// Calculates unlock state based on total entries
    /// Uses logarithmic formula: 25 * ln(entries + 1)
    /// - Parameter totalEntries: Total number of journal entries
    /// - Returns: The unlock state
    public static func calculate(totalEntries: Int) -> CharacterDiscoveryUnlockState {
        let progress = 25.0 * log(Double(totalEntries + 1))
        let cappedProgress = min(100.0, progress)

        if cappedProgress < 30 {
            // Calculate entries needed to reach 30%
            // 30 = 25 * ln(x + 1)
            // ln(x + 1) = 1.2
            // x + 1 = e^1.2 ≈ 3.32
            // x ≈ 2.32, so need 3 entries minimum
            let targetEntries = Int(ceil(exp(30.0 / 25.0) - 1))
            let entriesNeeded = max(1, targetEntries - totalEntries)
            return .locked(progress: cappedProgress, entriesNeeded: entriesNeeded)
        } else if cappedProgress < 40 {
            return .sample(progress: cappedProgress)
        } else {
            return .available(progress: cappedProgress)
        }
    }
}
