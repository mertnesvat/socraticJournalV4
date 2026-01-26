// MockCharacterMatchService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Mock character match service for testing and offline use
public final class MockCharacterMatchService: @unchecked Sendable {
    public static let shared = MockCharacterMatchService()

    private init() {}

    /// Generate a mock character match result for testing
    public func analyzeCharacterMatch(
        journalEntries: [JournalEntryData],
        franchise: CharacterFranchise
    ) async throws -> CharacterMatchResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        let characters = mockCharacters(for: franchise)

        // Generate pseudo-random but consistent matches based on entry count
        let seed = journalEntries.count
        let shuffled = characters.shuffled()

        let matches = [
            CharacterMatch(
                character: shuffled[seed % characters.count],
                confidence: 60 + (seed * 3) % 25,
                reasoning: "Based on your journal entries, you share key personality traits with this character including \(sampleTraits(for: shuffled[0]))."
            ),
            CharacterMatch(
                character: shuffled[(seed + 1) % characters.count],
                confidence: 15 + (seed * 2) % 15,
                reasoning: "You also demonstrate some qualities of this character, particularly in how you \(sampleBehavior())."
            ),
            CharacterMatch(
                character: shuffled[(seed + 2) % characters.count],
                confidence: 5 + seed % 10,
                reasoning: "At times, your entries show glimpses of this character's approach to \(sampleTheme())."
            )
        ]

        return CharacterMatchResult(
            matches: matches,
            franchise: franchise,
            analyzedAt: Date()
        )
    }

    private func mockCharacters(for franchise: CharacterFranchise) -> [String] {
        switch franchise {
        case .lordOfTheRings:
            return ["Frodo", "Sam", "Gandalf", "Aragorn", "Legolas", "Gimli", "Boromir", "Galadriel", "Eowyn", "Faramir"]
        case .harryPotter:
            return ["Harry", "Hermione", "Ron", "Dumbledore", "Snape", "Luna", "Neville", "Sirius", "Hagrid", "McGonagall"]
        case .starWars:
            return ["Luke", "Leia", "Han", "Obi-Wan", "Yoda", "Anakin", "Padme", "Rey", "Finn", "Ahsoka"]
        }
    }

    private func sampleTraits(for character: String) -> String {
        let traits = ["resilience and determination", "loyalty and compassion", "wisdom and patience", "courage and honor", "creativity and curiosity"]
        return traits.randomElement() ?? traits[0]
    }

    private func sampleBehavior() -> String {
        let behaviors = ["approach challenges", "connect with others", "reflect on experiences", "handle difficult emotions", "pursue your goals"]
        return behaviors.randomElement() ?? behaviors[0]
    }

    private func sampleTheme() -> String {
        let themes = ["personal growth", "relationships", "overcoming obstacles", "finding meaning", "self-discovery"]
        return themes.randomElement() ?? themes[0]
    }
}
#endif
