// LocalPromptGenerationService.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Local prompt generation service using a curated prompt library
/// Replace with AIPromptGenerationService (Firebase Function) when integrated
public final class LocalPromptGenerationService: PromptGenerationServiceProtocol, @unchecked Sendable {

    public init() {}

    public func generatePrompt(for circleId: String, excludingIds: Set<String>, isNewCircle: Bool) async throws -> DailyPrompt {
        let pool = isNewCircle ? Self.icebreakerPrompts : Self.allPrompts
        let available = pool.filter { !excludingIds.contains(stableId(for: $0, circleId: circleId)) }

        // If all prompts used, reset pool
        let selected: PromptEntry
        if available.isEmpty {
            selected = pool[deterministic(circleId: circleId, count: pool.count)]
        } else {
            selected = available[deterministic(circleId: circleId, count: available.count)]
        }

        return DailyPrompt(
            id: stableId(for: selected, circleId: circleId),
            circleId: circleId,
            question: selected.question,
            category: selected.category,
            generatedAt: Date()
        )
    }

    /// Deterministic selection based on date + circleId so all members see the same prompt
    private func deterministic(circleId: String, count: Int) -> Int {
        let dateString = Self.dayFormatter.string(from: Date())
        let seed = "\(dateString)-\(circleId)"
        let hash = abs(seed.hashValue)
        return hash % max(1, count)
    }

    private func stableId(for entry: PromptEntry, circleId: String) -> String {
        let dateString = Self.dayFormatter.string(from: Date())
        return "prompt-\(dateString)-\(circleId)-\(entry.question.hashValue)"
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Prompt Library

    struct PromptEntry {
        let question: String
        let category: PromptCategory
    }

    static let icebreakerPrompts: [PromptEntry] = [
        .init(question: "What's one thing that made you smile today?", category: .icebreaker),
        .init(question: "What song have you had stuck in your head lately?", category: .icebreaker),
        .init(question: "What's the best thing you ate this week?", category: .icebreaker),
        .init(question: "If you could be anywhere right now, where would you be?", category: .icebreaker),
        .init(question: "What's something small you're looking forward to?", category: .icebreaker),
        .init(question: "What made you laugh recently?", category: .icebreaker),
        .init(question: "What's the last photo you took on your phone?", category: .icebreaker),
    ]

    static let allPrompts: [PromptEntry] = icebreakerPrompts + [
        // Reflective
        .init(question: "What's one thing that went better than expected today?", category: .reflective),
        .init(question: "What's something you learned about yourself recently?", category: .reflective),
        .init(question: "What's a decision you're glad you made?", category: .reflective),
        .init(question: "When did you feel most like yourself this week?", category: .reflective),
        .init(question: "What's something you'd do differently if you could redo today?", category: .reflective),
        .init(question: "What's been taking up the most space in your mind lately?", category: .reflective),
        .init(question: "What's a small win you haven't told anyone about?", category: .reflective),

        // Playful
        .init(question: "What's a song that perfectly describes your week?", category: .playful),
        .init(question: "If your day was a movie genre, what would it be?", category: .playful),
        .init(question: "What's the most random thing you googled recently?", category: .playful),
        .init(question: "What fictional character do you relate to most right now?", category: .playful),
        .init(question: "What's your current guilty pleasure?", category: .playful),
        .init(question: "If you could have dinner with anyone alive, who would it be?", category: .playful),
        .init(question: "What's an unpopular opinion you hold?", category: .playful),
        .init(question: "What's something you're weirdly good at?", category: .playful),

        // Vulnerable
        .init(question: "What's something you've been avoiding saying out loud?", category: .vulnerable),
        .init(question: "What's something that's been worrying you?", category: .vulnerable),
        .init(question: "When was the last time you cried, and why?", category: .vulnerable),
        .init(question: "What's a fear you don't often share with people?", category: .vulnerable),
        .init(question: "What do you wish someone would ask you about?", category: .vulnerable),
        .init(question: "What's something you need help with but haven't asked for?", category: .vulnerable),
        .init(question: "What's a mistake you've been thinking about?", category: .vulnerable),

        // Nostalgic
        .init(question: "What's a memory from childhood that still makes you smile?", category: .nostalgic),
        .init(question: "What's a tradition from growing up you wish you still did?", category: .nostalgic),
        .init(question: "What's the best trip you've ever taken?", category: .nostalgic),
        .init(question: "What's a smell that instantly takes you back?", category: .nostalgic),
        .init(question: "Who was your first best friend and what happened?", category: .nostalgic),
        .init(question: "What's a place that feels like home, even if you don't live there?", category: .nostalgic),
        .init(question: "What's a piece of advice someone gave you that stuck?", category: .nostalgic),

        // Aspirational
        .init(question: "What would you do this week if failure wasn't possible?", category: .aspirational),
        .init(question: "What's one thing you want to be better at in 6 months?", category: .aspirational),
        .init(question: "What's a dream you've quietly given up on?", category: .aspirational),
        .init(question: "If money wasn't a factor, what would your days look like?", category: .aspirational),
        .init(question: "What's something you want to start doing for yourself?", category: .aspirational),
        .init(question: "What would make next week better than this one?", category: .aspirational),
        .init(question: "What kind of person do you want to become?", category: .aspirational),

        // Gratitude
        .init(question: "Who made your day better today, and why?", category: .gratitude),
        .init(question: "What's something you used to take for granted but now appreciate?", category: .gratitude),
        .init(question: "What's a simple pleasure that always lifts your mood?", category: .gratitude),
        .init(question: "Who's someone you're grateful to have in your life?", category: .gratitude),
        .init(question: "What's something good that came out of something bad?", category: .gratitude),
        .init(question: "What's a comfort you'd hate to lose?", category: .gratitude),
        .init(question: "What made you feel loved recently?", category: .gratitude),
    ]
}
