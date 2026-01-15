// MockPersonalityAnalysisService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of PersonalityAnalysisServiceProtocol
/// Provides sample personality analysis for development and offline use
public final class MockPersonalityAnalysisService: PersonalityAnalysisServiceProtocol, @unchecked Sendable {

    public init() {}

    // MARK: - PersonalityAnalysisServiceProtocol

    public func analyzePersonality(from sessions: [JournalSession]) async throws -> BigFiveProfile {
        // Simulate analysis delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Extract evidence from sessions
        let answers = sessions.flatMap { $0.exchanges.map { $0.answer } }

        // Generate personalized profile based on entry count and content
        let entryCount = sessions.count
        let seed = entryCount.hashValue

        return BigFiveProfile(
            openness: generateTrait(
                type: .openness,
                baseSeed: seed,
                offset: 0,
                evidence: extractEvidence(from: answers, keywords: ["creative", "new", "curious", "explore", "learn", "idea", "imagine", "different"])
            ),
            conscientiousness: generateTrait(
                type: .conscientiousness,
                baseSeed: seed,
                offset: 1,
                evidence: extractEvidence(from: answers, keywords: ["plan", "organize", "goal", "discipline", "work", "effort", "careful", "commit"])
            ),
            extraversion: generateTrait(
                type: .extraversion,
                baseSeed: seed,
                offset: 2,
                evidence: extractEvidence(from: answers, keywords: ["people", "social", "friend", "talk", "share", "energy", "excited", "together"])
            ),
            agreeableness: generateTrait(
                type: .agreeableness,
                baseSeed: seed,
                offset: 3,
                evidence: extractEvidence(from: answers, keywords: ["help", "care", "kind", "understand", "support", "trust", "harmony", "empathy"])
            ),
            neuroticism: generateTrait(
                type: .neuroticism,
                baseSeed: seed,
                offset: 4,
                evidence: extractEvidence(from: answers, keywords: ["worry", "anxious", "stress", "fear", "difficult", "struggle", "overwhelm", "doubt"])
            ),
            summary: generateSummary(entryCount: entryCount),
            analyzedAt: Date()
        )
    }

    public func generateSampleProfile() async throws -> BigFiveProfile {
        // Simulate delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

        return BigFiveProfile(
            openness: PersonalityTrait(
                type: .openness,
                score: 72,
                label: "High",
                description: "You show strong intellectual curiosity and openness to new experiences. Your journal entries reveal a mind that enjoys exploring ideas and questioning assumptions.",
                evidence: [
                    "\"I've been thinking about trying something completely different...\"",
                    "\"What if I looked at this from another perspective?\""
                ]
            ),
            conscientiousness: PersonalityTrait(
                type: .conscientiousness,
                score: 58,
                label: "Moderate",
                description: "You balance flexibility with structure. While you value organization, you also adapt when circumstances require it.",
                evidence: [
                    "\"I'm working on being more consistent with my goals...\"",
                    "\"Taking it one step at a time helps me stay focused.\""
                ]
            ),
            extraversion: PersonalityTrait(
                type: .extraversion,
                score: 45,
                label: "Moderate",
                description: "You appreciate both social connection and solitary reflection. Your energy comes from a balance of interactions and introspection.",
                evidence: [
                    "\"Sometimes I need time alone to process things...\"",
                    "\"That conversation really energized me.\""
                ]
            ),
            agreeableness: PersonalityTrait(
                type: .agreeableness,
                score: 68,
                label: "Moderately High",
                description: "You show strong empathy and concern for others. Your reflections often consider the perspectives and feelings of people around you.",
                evidence: [
                    "\"I want to understand where they're coming from...\"",
                    "\"Helping others gives me a sense of purpose.\""
                ]
            ),
            neuroticism: PersonalityTrait(
                type: .neuroticism,
                score: 52,
                label: "Moderate",
                description: "You experience emotions with appropriate depth. While you're aware of your concerns and worries, you also show resilience in processing them.",
                evidence: [
                    "\"I've been working through some difficult feelings...\"",
                    "\"It's okay to feel uncertain sometimes.\""
                ]
            ),
            summary: "This is a sample profile based on typical journaling patterns. Continue journaling to receive your personalized personality insights based on your unique reflections and experiences.",
            analyzedAt: Date()
        )
    }

    // MARK: - Private Helpers

    private func generateTrait(
        type: TraitType,
        baseSeed: Int,
        offset: Int,
        evidence: [String]
    ) -> PersonalityTrait {
        // Generate consistent score based on seed
        let score = generateScore(seed: baseSeed, offset: offset)
        let label = scoreLabel(score)
        let description = generateDescription(type: type, score: score, label: label)

        return PersonalityTrait(
            type: type,
            score: score,
            label: label,
            description: description,
            evidence: evidence.isEmpty ? generateFallbackEvidence(type: type) : evidence
        )
    }

    private func generateScore(seed: Int, offset: Int) -> Int {
        // Generate pseudo-random but consistent score between 35-85
        let hash = abs((seed &* 31) &+ offset)
        return 35 + (hash % 51)
    }

    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 0..<30: return "Low"
        case 30..<45: return "Moderately Low"
        case 45..<55: return "Moderate"
        case 55..<70: return "Moderately High"
        default: return "High"
        }
    }

    private func generateDescription(type: TraitType, score: Int, label: String) -> String {
        let intensity = label.lowercased().contains("high") ? "strong" : (label.lowercased().contains("low") ? "measured" : "balanced")

        switch type {
        case .openness:
            return "Your journal entries reveal a \(intensity) intellectual curiosity. You \(score > 55 ? "frequently explore new ideas and perspectives" : "appreciate both familiar patterns and novel approaches")."

        case .conscientiousness:
            return "Your reflections show a \(intensity) approach to organization and goals. You \(score > 55 ? "value structure and follow-through in your pursuits" : "balance flexibility with purposeful action")."

        case .extraversion:
            return "Your entries suggest a \(intensity) connection to social energy. You \(score > 55 ? "draw vitality from interactions and shared experiences" : "find meaning in both connection and solitary reflection")."

        case .agreeableness:
            return "Your reflections demonstrate \(intensity) empathy and consideration for others. You \(score > 55 ? "prioritize harmony and understanding in relationships" : "balance personal boundaries with compassion for others")."

        case .neuroticism:
            return "Your entries show a \(intensity) emotional awareness. You \(score > 55 ? "deeply process your emotional experiences, which shows sensitivity" : "navigate emotional terrain with measured awareness and resilience")."
        }
    }

    private func extractEvidence(from answers: [String], keywords: [String]) -> [String] {
        var evidence: [String] = []

        for answer in answers {
            let lowercased = answer.lowercased()
            if keywords.contains(where: { lowercased.contains($0) }) {
                // Take first 100 characters as evidence quote
                let preview = String(answer.prefix(100))
                let quote = preview.count < answer.count ? "\"\(preview)...\"" : "\"\(preview)\""
                evidence.append(quote)

                if evidence.count >= 3 {
                    break
                }
            }
        }

        return evidence
    }

    private func generateFallbackEvidence(type: TraitType) -> [String] {
        switch type {
        case .openness:
            return [
                "\"I've been exploring new ways of thinking about this...\"",
                "\"What if there's another perspective I haven't considered?\""
            ]
        case .conscientiousness:
            return [
                "\"I'm trying to be more intentional with my time...\"",
                "\"Setting clear goals helps me stay focused.\""
            ]
        case .extraversion:
            return [
                "\"Conversations with others help me process my thoughts...\"",
                "\"I value the connections in my life.\""
            ]
        case .agreeableness:
            return [
                "\"I want to understand their point of view...\"",
                "\"Being there for others matters to me.\""
            ]
        case .neuroticism:
            return [
                "\"I've been sitting with some difficult emotions...\"",
                "\"It's okay to acknowledge when things feel overwhelming.\""
            ]
        }
    }

    private func generateSummary(entryCount: Int) -> String {
        let summaries = [
            "Your journal entries reveal a thoughtful individual who values self-reflection. You show a balance between analytical thinking and emotional awareness, approaching life's challenges with both curiosity and care. Your personality profile suggests someone who seeks understanding through introspection.",

            "Based on your reflections, you demonstrate a rich inner life combined with genuine interest in personal growth. Your entries show someone who processes experiences deeply and values authentic self-expression. You approach questions about meaning and purpose with earnest inquiry.",

            "Your personality profile paints a picture of someone engaged in continuous self-discovery. You balance openness to new perspectives with appreciation for established values. Your journal entries reveal thoughtful consideration of both emotional and practical matters.",

            "Through your reflections, a pattern emerges of someone seeking clarity and understanding. You show the capacity for both introspection and action, processing experiences with care while remaining engaged with the world around you. Your entries suggest a commitment to personal authenticity."
        ]

        return summaries[entryCount % summaries.count]
    }
}
