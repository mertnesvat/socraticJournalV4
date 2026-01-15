// MockClarityScoreService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of ClarityScoreServiceProtocol
/// Calculates scores based on exchange content analysis
public final class MockClarityScoreService: ClarityScoreServiceProtocol, @unchecked Sendable {

    public init() {}

    // MARK: - Emotional Words for Analysis

    private let emotionalWords: Set<String> = [
        // Positive emotions
        "happy", "joy", "love", "grateful", "thankful", "blessed", "excited", "hopeful",
        "proud", "peaceful", "calm", "content", "inspired", "motivated", "confident",
        // Negative emotions (also valuable for emotional depth)
        "sad", "angry", "frustrated", "anxious", "worried", "scared", "afraid", "hurt",
        "lonely", "confused", "overwhelmed", "stressed", "disappointed", "regret",
        // Reflective words
        "feel", "felt", "feeling", "realize", "realized", "understand", "understood",
        "believe", "think", "wonder", "hope", "wish", "need", "want", "fear",
        "heart", "soul", "mind", "spirit", "growth", "change", "transform"
    ]

    // MARK: - Encouraging Messages

    private let highQualityMessages = [
        "Your deep reflection today reveals a mind truly engaged with its inner wisdom. This is the kind of self-examination that leads to lasting insight.",
        "What a profound journey you've taken today. Your willingness to explore difficult questions shows remarkable courage and self-awareness.",
        "Your thoughtful responses demonstrate the power of genuine introspection. Socrates would be proud of your philosophical spirit.",
        "Today you've touched something meaningful. The depth of your reflection creates fertile ground for wisdom to grow."
    ]

    private let moderateQualityMessages = [
        "You've taken meaningful steps in your reflection today. Each question explored is a seed planted for future understanding.",
        "Your willingness to pause and reflect is a gift to yourself. Even moderate exploration opens doors to insight.",
        "Today's session shows your commitment to self-understanding. Keep nurturing this practice of questioning.",
        "You've engaged thoughtfully with important questions. This foundation of reflection will serve you well."
    ]

    private let quickCheckInMessages = [
        "Sometimes a quick check-in is exactly what's needed. The important thing is that you showed up for yourself today.",
        "Brief reflections can still carry profound meaning. What matters is that you took time for inner work.",
        "Every journey begins with small steps. Your willingness to reflect, even briefly, is valuable.",
        "Quick sessions still honor the practice of self-examination. Consider returning when you have more time to explore."
    ]

    // MARK: - Wisdom Quotes

    private let philosophyQuotes: [(text: String, author: String, source: String?)] = [
        ("The unexamined life is not worth living.", "Socrates", nil),
        ("Know thyself.", "Delphic Maxim", nil),
        ("He who knows others is wise; he who knows himself is enlightened.", "Lao Tzu", "Tao Te Ching"),
        ("The only true wisdom is in knowing you know nothing.", "Socrates", nil),
        ("Knowing yourself is the beginning of all wisdom.", "Aristotle", nil)
    ]

    private let growthQuotes: [(text: String, author: String, source: String?)] = [
        ("The impediment to action advances action. What stands in the way becomes the way.", "Marcus Aurelius", "Meditations"),
        ("No man ever steps in the same river twice, for it's not the same river and he's not the same man.", "Heraclitus", nil),
        ("The wound is the place where the Light enters you.", "Rumi", nil),
        ("Out of your vulnerabilities will come your strength.", "Sigmund Freud", nil),
        ("What we achieve inwardly will change outer reality.", "Plutarch", nil)
    ]

    private let courageQuotes: [(text: String, author: String, source: String?)] = [
        ("Courage is not the absence of fear, but rather the judgment that something else is more important than fear.", "Ambrose Redmoon", nil),
        ("Life shrinks or expands in proportion to one's courage.", "Anais Nin", nil),
        ("You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.", "Eleanor Roosevelt", nil),
        ("Courage is resistance to fear, mastery of fear - not absence of fear.", "Mark Twain", nil)
    ]

    private let peacefulQuotes: [(text: String, author: String, source: String?)] = [
        ("Within you, there is a stillness and a sanctuary to which you can retreat at any time.", "Hermann Hesse", "Siddhartha"),
        ("The greatest weapon against stress is our ability to choose one thought over another.", "William James", nil),
        ("Peace comes from within. Do not seek it without.", "Buddha", nil),
        ("In the midst of movement and chaos, keep stillness inside of you.", "Deepak Chopra", nil)
    ]

    // MARK: - ClarityScoreServiceProtocol

    public func calculateScore(from exchanges: [Exchange]) async throws -> ClarityScore {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        guard !exchanges.isEmpty else {
            throw ClarityScoreServiceError.insufficientExchanges
        }

        // Calculate completion score (30% weight)
        // Based on answered vs skipped questions
        let answeredCount = exchanges.filter { !$0.skipped }.count
        let completionScore = (answeredCount * 100) / exchanges.count

        // Calculate depth score (40% weight)
        // Based on average word count of non-skipped answers
        let nonSkippedAnswers = exchanges.filter { !$0.skipped }.map { $0.answer }
        let depthScore: Int
        if nonSkippedAnswers.isEmpty {
            depthScore = 0
        } else {
            let totalWords = nonSkippedAnswers.reduce(0) { $0 + wordCount($1) }
            let avgWords = totalWords / nonSkippedAnswers.count
            // Scale: 0-10 words = 0-20, 10-30 words = 20-60, 30-50 words = 60-80, 50+ words = 80-100
            depthScore = calculateDepthFromWordCount(avgWords)
        }

        // Calculate emotional score (30% weight)
        // Based on presence of emotional/reflective words
        let emotionalScore: Int
        if nonSkippedAnswers.isEmpty {
            emotionalScore = 0
        } else {
            let allText = nonSkippedAnswers.joined(separator: " ").lowercased()
            let emotionalWordCount = countEmotionalWords(in: allText)
            let totalWordCount = wordCount(allText)
            // Higher ratio of emotional words = higher score
            let ratio = totalWordCount > 0 ? Double(emotionalWordCount) / Double(totalWordCount) : 0
            emotionalScore = min(Int(ratio * 500), 100) // Scale so ~20% emotional words = 100
        }

        // Calculate weighted total
        let weightedTotal = Int(
            Double(completionScore) * 0.30 +
            Double(depthScore) * 0.40 +
            Double(emotionalScore) * 0.30
        )

        // Determine label and message
        let quality = ScoreQuality.from(score: weightedTotal)
        let label = quality.rawValue
        let message: String

        switch quality {
        case .high:
            message = highQualityMessages.randomElement() ?? highQualityMessages[0]
        case .moderate:
            message = moderateQualityMessages.randomElement() ?? moderateQualityMessages[0]
        case .quick:
            message = quickCheckInMessages.randomElement() ?? quickCheckInMessages[0]
        }

        return ClarityScore(
            total: weightedTotal,
            completion: completionScore,
            depth: depthScore,
            emotional: emotionalScore,
            label: label,
            message: message
        )
    }

    public func generateWisdomQuote(for exchanges: [Exchange], score: ClarityScore) async throws -> WisdomQuote {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Analyze session content to pick appropriate quote category
        let allText = exchanges.map { $0.answer }.joined(separator: " ").lowercased()

        let quotePool: [(text: String, author: String, source: String?)]

        // Simple keyword matching to select quote category
        if containsAny(text: allText, words: ["fear", "afraid", "scared", "worry", "anxious", "courage", "brave"]) {
            quotePool = courageQuotes
        } else if containsAny(text: allText, words: ["grow", "change", "transform", "learn", "become", "evolve", "progress"]) {
            quotePool = growthQuotes
        } else if containsAny(text: allText, words: ["peace", "calm", "stress", "overwhelm", "rest", "quiet", "still"]) {
            quotePool = peacefulQuotes
        } else {
            // Default to philosophy quotes
            quotePool = philosophyQuotes
        }

        let selected = quotePool.randomElement() ?? philosophyQuotes[0]

        return WisdomQuote(
            text: selected.text,
            author: selected.author,
            source: selected.source
        )
    }

    // MARK: - Private Helpers

    private func wordCount(_ text: String) -> Int {
        let words = text.split(whereSeparator: { $0.isWhitespace || $0.isPunctuation })
        return words.count
    }

    private func calculateDepthFromWordCount(_ avgWords: Int) -> Int {
        switch avgWords {
        case 0..<10:
            return avgWords * 2 // 0-20
        case 10..<30:
            return 20 + (avgWords - 10) * 2 // 20-60
        case 30..<50:
            return 60 + (avgWords - 30) // 60-80
        default:
            return min(80 + (avgWords - 50) / 2, 100) // 80-100
        }
    }

    private func countEmotionalWords(in text: String) -> Int {
        let words = text.lowercased().split(whereSeparator: { $0.isWhitespace || $0.isPunctuation })
        return words.filter { emotionalWords.contains(String($0)) }.count
    }

    private func containsAny(text: String, words: [String]) -> Bool {
        for word in words {
            if text.contains(word) {
                return true
            }
        }
        return false
    }
}
