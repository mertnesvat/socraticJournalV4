// LocalPromptGenerationService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Loads prompts from the bundled prompt_bank.json and selects prompts
/// based on the circle's week number (depth tier) while avoiding recent repeats.
public final class LocalPromptGenerationService: PromptGenerationServiceProtocol, @unchecked Sendable {

    // MARK: - Types

    private struct PromptBank: Codable {
        let tiers: Tiers

        struct Tiers: Codable {
            let light: [String]
            let medium: [String]
            let deep: [String]
        }
    }

    // MARK: - Properties

    private let lock = NSLock()
    private var promptBank: PromptBank?

    // MARK: - Init

    public init() {
        self.promptBank = Self.loadPromptBank()
    }

    // MARK: - PromptGenerationServiceProtocol

    public func generatePrompt(circleId: UUID, weekNumber: Int, recentPrompts: [String]) async throws -> String {
        lock.lock()
        defer { lock.unlock() }

        guard let bank = promptBank else {
            throw PromptGenerationError.promptBankNotFound
        }

        let tier = PromptTier.forWeek(weekNumber)
        let recentSet = Set(recentPrompts)

        // Get prompts for the primary tier, filtering out recent ones
        let primaryPrompts = prompts(for: tier, from: bank).filter { !recentSet.contains($0) }

        if let selected = primaryPrompts.randomElement() {
            return selected
        }

        // Fallback: try other tiers in order of proximity
        let fallbackTiers = Self.fallbackOrder(for: tier)
        for fallbackTier in fallbackTiers {
            let fallbackPrompts = prompts(for: fallbackTier, from: bank).filter { !recentSet.contains($0) }
            if let selected = fallbackPrompts.randomElement() {
                return selected
            }
        }

        // Last resort: pick any prompt ignoring recency filter
        let allPrompts = bank.tiers.light + bank.tiers.medium + bank.tiers.deep
        guard let anyPrompt = allPrompts.randomElement() else {
            throw PromptGenerationError.noPromptsAvailable
        }
        return anyPrompt
    }

    // MARK: - Private Helpers

    private func prompts(for tier: PromptTier, from bank: PromptBank) -> [String] {
        switch tier {
        case .light:
            return bank.tiers.light
        case .medium:
            return bank.tiers.medium
        case .deep:
            return bank.tiers.deep
        }
    }

    /// Returns fallback tiers ordered by proximity to the primary tier.
    /// For light: try medium then deep.
    /// For medium: try light then deep.
    /// For deep: try medium then light.
    private static func fallbackOrder(for tier: PromptTier) -> [PromptTier] {
        switch tier {
        case .light:
            return [.medium, .deep]
        case .medium:
            return [.light, .deep]
        case .deep:
            return [.medium, .light]
        }
    }

    private static func loadPromptBank() -> PromptBank? {
        guard let url = Bundle.main.url(forResource: "prompt_bank", withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(PromptBank.self, from: data)
        } catch {
            return nil
        }
    }
}

// MARK: - Errors

public enum PromptGenerationError: LocalizedError {
    case promptBankNotFound
    case noPromptsAvailable

    public var errorDescription: String? {
        switch self {
        case .promptBankNotFound:
            return "Could not load prompt bank. Please reinstall the app."
        case .noPromptsAvailable:
            return "No prompts available. Please try again later."
        }
    }
}
#endif
