// MockCharacterQuizService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of CharacterQuizServiceProtocol
/// Provides sample character quiz results for development, previews, and offline use
public final class MockCharacterQuizService: CharacterQuizServiceProtocol, @unchecked Sendable {

    /// Minimum number of journal exchanges required for analysis
    public let minimumEntriesRequired: Int = 5

    /// Simulated delay for realistic preview experience (in seconds)
    private let simulatedDelay: UInt64 = 2_000_000_000 // 2 seconds

    public init() {}

    // MARK: - CharacterQuizServiceProtocol

    public func analyzeCharacterMatch(
        entries: [Exchange],
        franchise: Franchise
    ) async throws -> CharacterQuizResult {
        // Check minimum entries requirement
        guard entries.count >= minimumEntriesRequired else {
            throw CharacterQuizError.insufficientEntries(
                required: minimumEntriesRequired,
                available: entries.count
            )
        }

        // Simulate analysis delay for realistic UX
        try await Task.sleep(nanoseconds: simulatedDelay)

        // Generate pseudo-random but consistent results based on entries
        let seed = generateSeed(from: entries)
        let matches = generateMatches(for: franchise, seed: seed, entryCount: entries.count)

        return CharacterQuizResult(
            franchise: franchise,
            matches: matches,
            analyzedAt: Date(),
            journalEntriesUsed: entries.count
        )
    }

    public func generateSampleResult(for franchise: Franchise) async throws -> CharacterQuizResult {
        // Shorter delay for sample generation
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

        let matches = generateSampleMatches(for: franchise)

        return CharacterQuizResult(
            franchise: franchise,
            matches: matches,
            analyzedAt: Date(),
            journalEntriesUsed: 10
        )
    }

    // MARK: - Private Helpers

    /// Generate a seed value from journal entries for consistent pseudo-random results
    private func generateSeed(from entries: [Exchange]) -> Int {
        var seed = 0
        for entry in entries {
            seed = seed &+ entry.answer.hashValue
        }
        return abs(seed)
    }

    /// Generate character matches based on franchise and seed
    private func generateMatches(
        for franchise: Franchise,
        seed: Int,
        entryCount: Int
    ) -> [CharacterMatchEntry] {
        let characters = FictionalCharacter.characters(for: franchise)

        // Create shuffled indices based on seed
        var indices = Array(0..<characters.count)
        var shuffledIndices: [Int] = []
        var tempSeed = seed

        while !indices.isEmpty {
            let index = abs(tempSeed) % indices.count
            shuffledIndices.append(indices.remove(at: index))
            tempSeed = tempSeed &* 31 &+ 17
        }

        // Generate matches for top 5 characters (or all if less than 5)
        let matchCount = min(5, characters.count)
        var matches: [CharacterMatchEntry] = []

        for i in 0..<matchCount {
            let characterIndex = shuffledIndices[i]
            let character = characters[characterIndex]

            // Calculate confidence based on position and seed
            let baseConfidence = 95 - (i * 12) // 95, 83, 71, 59, 47
            let variation = abs((seed &+ i) % 10) - 5 // -5 to +4
            let confidence = max(15, min(98, baseConfidence + variation))

            let explanation = generateExplanation(for: character, rank: i + 1, entryCount: entryCount)

            matches.append(CharacterMatchEntry(
                character: character,
                confidencePercentage: confidence,
                explanation: explanation
            ))
        }

        return matches
    }

    /// Generate sample matches with predefined top characters for each franchise
    private func generateSampleMatches(for franchise: Franchise) -> [CharacterMatchEntry] {
        switch franchise {
        case .lordOfTheRings:
            return [
                CharacterMatchEntry(
                    character: .gandalf,
                    confidencePercentage: 87,
                    explanation: "Your journal entries reveal a deep wisdom and tendency to guide others through difficult decisions. Like Gandalf, you see the bigger picture and understand that true strength comes from empowering others rather than wielding power directly. Your reflections show patience and a belief that even small actions can change the world."
                ),
                CharacterMatchEntry(
                    character: .aragorn,
                    confidencePercentage: 74,
                    explanation: "There's a quiet strength in your reflections, reminiscent of Aragorn's journey from ranger to king. You show signs of wrestling with responsibility and the weight of expectations, yet your entries reveal a deep commitment to doing what's right."
                ),
                CharacterMatchEntry(
                    character: .sam,
                    confidencePercentage: 62,
                    explanation: "Your loyalty and steadfast nature shine through your writing. Like Samwise Gamgee, you value friendship deeply and find meaning in supporting those you care about through their darkest moments."
                ),
                CharacterMatchEntry(
                    character: .frodo,
                    confidencePercentage: 51,
                    explanation: "Your entries suggest you understand the weight of bearing difficult responsibilities. Like Frodo, you approach challenges with quiet determination despite moments of doubt."
                ),
                CharacterMatchEntry(
                    character: .eowyn,
                    confidencePercentage: 43,
                    explanation: "There are glimpses of Eowyn's spirit in your reflections - a desire to break free from limitations and prove your worth through meaningful action."
                )
            ]

        case .harryPotter:
            return [
                CharacterMatchEntry(
                    character: .hermione,
                    confidencePercentage: 85,
                    explanation: "Your thoughtful, analytical approach to self-reflection mirrors Hermione's intellectual curiosity. You value preparation and knowledge, but your entries also reveal deep loyalty and a strong moral compass that guides your decisions."
                ),
                CharacterMatchEntry(
                    character: .luna,
                    confidencePercentage: 72,
                    explanation: "Like Luna Lovegood, you demonstrate a unique perspective on the world. Your journal entries show someone comfortable with being different and capable of seeing truths that others might miss."
                ),
                CharacterMatchEntry(
                    character: .harry,
                    confidencePercentage: 64,
                    explanation: "Your reflections reveal someone who, like Harry, often feels the weight of circumstances beyond their control but consistently chooses courage over comfort."
                ),
                CharacterMatchEntry(
                    character: .dumbledore,
                    confidencePercentage: 55,
                    explanation: "There's wisdom in your writing that echoes Dumbledore's understanding that our choices define us more than our abilities. You reflect deeply on the consequences of actions."
                ),
                CharacterMatchEntry(
                    character: .neville,
                    confidencePercentage: 46,
                    explanation: "Your entries show a quiet courage reminiscent of Neville - the determination to stand up even when afraid and the capacity for growth that surprises even yourself."
                )
            ]

        case .starWars:
            return [
                CharacterMatchEntry(
                    character: .obiWan,
                    confidencePercentage: 88,
                    explanation: "Your reflections demonstrate the patience and wisdom of Obi-Wan Kenobi. You show a commitment to principles while carrying the weight of past decisions. Like Obi-Wan, you understand that guiding others often means stepping back and trusting them to find their own way."
                ),
                CharacterMatchEntry(
                    character: .luke,
                    confidencePercentage: 75,
                    explanation: "There's a hopeful idealism in your journal entries that echoes Luke Skywalker. You believe in redemption and the possibility of change, even when evidence might suggest otherwise."
                ),
                CharacterMatchEntry(
                    character: .leia,
                    confidencePercentage: 66,
                    explanation: "Your entries reveal leadership qualities and determination reminiscent of Princess Leia. You balance compassion with the strength needed to make difficult decisions."
                ),
                CharacterMatchEntry(
                    character: .yoda,
                    confidencePercentage: 54,
                    explanation: "Like Yoda, your reflections show an appreciation for patience and the understanding that wisdom often comes from stillness and reflection rather than action."
                ),
                CharacterMatchEntry(
                    character: .rey,
                    confidencePercentage: 47,
                    explanation: "Your journal entries suggest someone on a journey of self-discovery, much like Rey. You're learning that your identity is defined by your choices, not your origins."
                )
            ]
        }
    }

    /// Generate a personalized explanation for a character match
    private func generateExplanation(
        for character: FictionalCharacter,
        rank: Int,
        entryCount: Int
    ) -> String {
        let traits = character.personalityTraits.prefix(3).joined(separator: ", ")
        let intensity = rank == 1 ? "strongly" : (rank <= 3 ? "notably" : "somewhat")

        let baseExplanations: [String] = [
            "Based on your \(entryCount) journal entries, you \(intensity) resonate with \(character.name)'s qualities of \(traits). Your reflections reveal similar patterns of thought and emotional processing.",
            "Your journal entries \(intensity) echo the characteristics we associate with \(character.name). The themes of \(traits) appear throughout your reflections, suggesting a meaningful connection.",
            "Analysis of your \(entryCount) entries shows you \(intensity) align with \(character.name)'s journey. Your writing demonstrates \(traits) in ways that mirror this character's arc.",
            "Through your reflections, we see \(intensity) evident traces of \(character.name)'s defining qualities: \(traits). Your introspective style suggests a kindred spirit."
        ]

        // Select explanation based on character id hash for consistency
        let index = abs(character.id.hashValue) % baseExplanations.count
        return baseExplanations[index]
    }
}
