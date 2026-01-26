// MockCharacterQuizService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of CharacterQuizServiceProtocol
/// Provides sample character matches for development, testing, and offline use
public final class MockCharacterQuizService: CharacterQuizServiceProtocol, @unchecked Sendable {

    public init() {}

    // MARK: - CharacterQuizServiceProtocol

    public func matchCharacters(request: CharacterMatchRequest) async throws -> CharacterMatchResult {
        // Simulate analysis delay (1.5-2.5 seconds)
        try await Task.sleep(nanoseconds: UInt64.random(in: 1_500_000_000...2_500_000_000))

        // Validate universe
        guard let universe = FictionalUniverse.allUniverses.first(where: { $0.id == request.universeId }) else {
            throw CharacterQuizError.invalidUniverse(request.universeId)
        }

        // Generate matches based on journal content analysis
        let matches = generateMatches(
            from: request.journalEntries,
            universe: universe
        )

        return CharacterMatchResult(
            matches: matches,
            universe: universe.name,
            analysisSummary: generateAnalysisSummary(for: universe, entryCount: request.journalEntries.count),
            generatedAt: Date()
        )
    }

    public func generateSampleMatch(for universeId: String) async throws -> CharacterMatchResult {
        // Simulate delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

        // Get universe
        guard let universe = FictionalUniverse.allUniverses.first(where: { $0.id == universeId }) else {
            throw CharacterQuizError.invalidUniverse(universeId)
        }

        // Generate sample matches (first 3 characters with sample confidence)
        let sampleMatches = universe.characters.prefix(3).enumerated().map { index, character in
            CharacterMatch(
                characterId: character.id,
                characterName: character.name,
                confidence: [0.85, 0.72, 0.58][index],
                reasoning: generateSampleReasoning(for: character),
                excerpts: [] // Sample matches don't include excerpts
            )
        }

        return CharacterMatchResult(
            matches: Array(sampleMatches),
            universe: universe.name,
            analysisSummary: "This is a sample result. Continue journaling to discover your true character match based on your personal reflections.",
            generatedAt: Date()
        )
    }

    // MARK: - Private Helpers

    private func generateMatches(
        from journalEntries: [JournalEntryData],
        universe: FictionalUniverse
    ) -> [CharacterMatch] {
        // Extract answer texts from journal entries
        let entryTexts = journalEntries.map { "\($0.question)\n\($0.answer)" }
        // Extract traits from journal entries
        let extractedTraits = extractTraits(from: entryTexts)

        // Score each character based on trait matches
        var characterScores: [(character: FictionalCharacter, score: Double)] = []

        for character in universe.characters {
            let matchingTraits = character.traits.filter { trait in
                extractedTraits.contains { $0.lowercased().contains(trait.lowercased()) ||
                    trait.lowercased().contains($0.lowercased()) }
            }

            // Base score from trait matches
            var score = Double(matchingTraits.count) / Double(max(character.traits.count, 1))

            // Add some randomness for variety
            score += Double.random(in: -0.1...0.1)

            // Normalize to 0.3-0.95 range
            score = min(0.95, max(0.3, score * 0.7 + 0.3))

            characterScores.append((character, score))
        }

        // Sort by score descending and take top 5
        let topMatches = characterScores
            .sorted { $0.score > $1.score }
            .prefix(5)

        return topMatches.map { item in
            CharacterMatch(
                characterId: item.character.id,
                characterName: item.character.name,
                confidence: item.score,
                reasoning: generateReasoning(for: item.character, traits: extractedTraits),
                excerpts: [] // Mock service doesn't provide excerpts
            )
        }
    }

    private func extractTraits(from entries: [String]) -> Set<String> {
        // Keywords that map to personality traits
        let traitKeywords: [String: [String]] = [
            "brave": ["courage", "fear", "stand up", "face", "challenge", "difficult"],
            "compassionate": ["care", "help", "understand", "feel", "empathy", "kind"],
            "wise": ["think", "learn", "reflect", "consider", "perspective", "insight"],
            "loyal": ["friend", "trust", "support", "always", "together", "commit"],
            "determined": ["goal", "persist", "keep going", "won't give up", "achieve"],
            "curious": ["wonder", "explore", "discover", "question", "new", "different"],
            "humble": ["grateful", "appreciate", "thankful", "learn from", "mistake"],
            "protective": ["protect", "safe", "defend", "family", "loved ones"],
            "independent": ["myself", "own", "alone", "self", "individual"],
            "optimistic": ["hope", "better", "positive", "bright", "future"],
            "conflicted": ["torn", "struggle", "both", "difficult choice", "unsure"],
            "noble": ["right", "honor", "duty", "responsibility", "principle"]
        ]

        var extractedTraits = Set<String>()
        let combinedText = entries.joined(separator: " ").lowercased()

        for (trait, keywords) in traitKeywords {
            if keywords.contains(where: { combinedText.contains($0) }) {
                extractedTraits.insert(trait)
            }
        }

        // If no traits found, add some defaults based on journaling itself
        if extractedTraits.isEmpty {
            extractedTraits = ["thoughtful", "introspective", "curious"]
        }

        return extractedTraits
    }

    private func generateReasoning(for character: FictionalCharacter, traits: Set<String>) -> String {
        let matchingTraits = character.traits.filter { trait in
            traits.contains { $0.lowercased() == trait.lowercased() ||
                trait.lowercased().contains($0.lowercased()) ||
                $0.lowercased().contains(trait.lowercased()) }
        }

        let traitDescription: String
        if matchingTraits.isEmpty {
            traitDescription = "your thoughtful approach to self-reflection"
        } else if matchingTraits.count == 1 {
            traitDescription = "your \(matchingTraits[0]) nature"
        } else {
            let lastTrait = matchingTraits.last!
            let otherTraits = matchingTraits.dropLast().joined(separator: ", ")
            traitDescription = "your \(otherTraits) and \(lastTrait) qualities"
        }

        let reasoningTemplates = [
            "Your journal entries reveal \(traitDescription), which strongly resonates with \(character.name)'s core characteristics. Like \(character.name), you approach challenges with similar depth and authenticity.",
            "Based on your reflections, \(traitDescription) aligns closely with how \(character.name) navigates their world. Your writing shows a kindred spirit in how you process experiences.",
            "The themes in your journal suggest \(traitDescription), mirroring the essence of \(character.name). Your inner journey shares meaningful parallels with this character's story.",
            "\(character.name) embodies \(traitDescription) that your journal entries also demonstrate. The way you explore your thoughts reflects similar values and approach to life."
        ]

        return reasoningTemplates.randomElement()!
    }

    private func generateSampleReasoning(for character: FictionalCharacter) -> String {
        let trait = character.traits.first ?? "unique"
        return "This is a sample match. \(character.name) is known for being \(trait). Continue journaling to discover your personalized character match based on your own reflections."
    }

    private func generateAnalysisSummary(for universe: FictionalUniverse, entryCount: Int) -> String {
        let summaries = [
            "Your personality was analyzed across \(entryCount) journal entries, examining themes of growth, relationships, and personal values. These insights were matched against the rich character archetypes from \(universe.name).",
            "Based on \(entryCount) reflections, we identified key personality patterns and emotional themes. These were compared to the diverse cast of \(universe.name) to find your closest character matches.",
            "Analysis of \(entryCount) journal entries revealed your unique personality fingerprint. By examining your values, challenges, and aspirations, we found meaningful connections within \(universe.name).",
            "Your \(entryCount) journal entries provided deep insight into your character. The themes and emotions you explored were matched against the archetypal personalities of \(universe.name)."
        ]

        return summaries.randomElement()!
    }
}
