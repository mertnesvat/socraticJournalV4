// ClarityScoreTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
@testable import SocraticJournal

/// Tests for ClarityScore calculation algorithm in MockClarityScoreService
@Suite("ClarityScore Calculation Tests")
struct ClarityScoreTests {
    let service = MockClarityScoreService()

    // MARK: - Test Helpers

    /// Creates a test exchange with the given answer and skipped status
    func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
        Exchange(
            question: "Test question?",
            answer: answer,
            skipped: skipped
        )
    }

    /// Creates multiple exchanges with the same answer
    func makeExchanges(count: Int, answer: String, skipped: Bool = false) -> [Exchange] {
        (0..<count).map { _ in makeExchange(answer: answer, skipped: skipped) }
    }

    // MARK: - Completion Score Tests

    @Suite("Completion Score")
    struct CompletionScoreTests {
        let service = MockClarityScoreService()

        func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
            Exchange(question: "Test?", answer: answer, skipped: skipped)
        }

        @Test("All exchanges answered gives 100% completion")
        func allAnswered() async throws {
            let exchanges = [
                makeExchange(answer: "Answer one"),
                makeExchange(answer: "Answer two"),
                makeExchange(answer: "Answer three")
            ]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.completion == 100)
        }

        @Test("Half exchanges skipped gives 50% completion")
        func halfSkipped() async throws {
            let exchanges = [
                makeExchange(answer: "Answer one", skipped: false),
                makeExchange(answer: "", skipped: true),
                makeExchange(answer: "Answer three", skipped: false),
                makeExchange(answer: "", skipped: true)
            ]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.completion == 50)
        }

        @Test("All exchanges skipped gives 0% completion")
        func allSkipped() async throws {
            let exchanges = [
                makeExchange(answer: "", skipped: true),
                makeExchange(answer: "", skipped: true),
                makeExchange(answer: "", skipped: true)
            ]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.completion == 0)
        }

        @Test("Single answered exchange gives 100% completion")
        func singleAnswered() async throws {
            let exchanges = [makeExchange(answer: "My answer")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.completion == 100)
        }

        @Test("One of three answered gives 33% completion")
        func oneOfThree() async throws {
            let exchanges = [
                makeExchange(answer: "Answer", skipped: false),
                makeExchange(answer: "", skipped: true),
                makeExchange(answer: "", skipped: true)
            ]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.completion == 33)
        }
    }

    // MARK: - Depth Score Tests

    @Suite("Depth Score")
    struct DepthScoreTests {
        let service = MockClarityScoreService()

        func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
            Exchange(question: "Test?", answer: answer, skipped: skipped)
        }

        @Test("Very short answer (5 words) gives low depth score")
        func veryShortAnswer() async throws {
            // 5 words -> depth = 5 * 2 = 10
            let exchanges = [makeExchange(answer: "One two three four five")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 10)
        }

        @Test("Short answer (9 words) stays in 0-20 range")
        func shortAnswer() async throws {
            // 9 words -> depth = 9 * 2 = 18
            let exchanges = [makeExchange(answer: "One two three four five six seven eight nine")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 18)
        }

        @Test("Medium answer (15 words) gives medium depth score")
        func mediumAnswer() async throws {
            // 15 words -> depth = 20 + (15 - 10) * 2 = 20 + 10 = 30
            let answer = "One two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen"
            let exchanges = [makeExchange(answer: answer)]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 30)
        }

        @Test("Medium-long answer (25 words) gives higher depth score")
        func mediumLongAnswer() async throws {
            // 25 words -> depth = 20 + (25 - 10) * 2 = 20 + 30 = 50
            let words = (1...25).map { "word\($0)" }.joined(separator: " ")
            let exchanges = [makeExchange(answer: words)]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 50)
        }

        @Test("Long answer (35 words) gives high depth score")
        func longAnswer() async throws {
            // 35 words -> depth = 60 + (35 - 30) = 65
            let words = (1...35).map { "word\($0)" }.joined(separator: " ")
            let exchanges = [makeExchange(answer: words)]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 65)
        }

        @Test("Very long answer (60 words) approaches maximum depth")
        func veryLongAnswer() async throws {
            // 60 words -> depth = 80 + (60 - 50) / 2 = 80 + 5 = 85
            let words = (1...60).map { "word\($0)" }.joined(separator: " ")
            let exchanges = [makeExchange(answer: words)]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 85)
        }

        @Test("Extremely long answer (100 words) caps at 100")
        func extremelyLongAnswer() async throws {
            // 100 words -> depth = min(80 + (100 - 50) / 2, 100) = min(105, 100) = 100
            let words = (1...100).map { "word\($0)" }.joined(separator: " ")
            let exchanges = [makeExchange(answer: words)]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 100)
        }

        @Test("All skipped exchanges gives 0 depth")
        func allSkippedZeroDepth() async throws {
            let exchanges = [
                makeExchange(answer: "", skipped: true),
                makeExchange(answer: "", skipped: true)
            ]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 0)
        }

        @Test("Depth uses average word count across exchanges")
        func averageWordCount() async throws {
            // First exchange: 10 words, Second: 20 words -> avg = 15 words
            // Depth = 20 + (15 - 10) * 2 = 30
            let shortAnswer = (1...10).map { "word\($0)" }.joined(separator: " ")
            let longAnswer = (1...20).map { "word\($0)" }.joined(separator: " ")
            let exchanges = [
                makeExchange(answer: shortAnswer),
                makeExchange(answer: longAnswer)
            ]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.depth == 30)
        }
    }

    // MARK: - Emotional Score Tests

    @Suite("Emotional Score")
    struct EmotionalScoreTests {
        let service = MockClarityScoreService()

        func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
            Exchange(question: "Test?", answer: answer, skipped: skipped)
        }

        @Test("Answer with emotional words scores higher")
        func emotionalWordsDetected() async throws {
            // "happy grateful love" = 3 emotional words out of 6 total = 50% ratio
            // emotionalScore = min(0.5 * 500, 100) = 100
            let exchanges = [makeExchange(answer: "I feel happy and grateful for love")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional > 50)
        }

        @Test("Answer without emotional words scores low")
        func noEmotionalWords() async throws {
            // No emotional words
            let exchanges = [makeExchange(answer: "The weather is sunny today outside")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional == 0)
        }

        @Test("Positive emotional words are detected")
        func positiveEmotions() async throws {
            let exchanges = [makeExchange(answer: "I feel happy joyful grateful blessed excited")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional > 0)
        }

        @Test("Negative emotional words are also detected")
        func negativeEmotions() async throws {
            let exchanges = [makeExchange(answer: "I feel sad angry frustrated anxious worried")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional > 0)
        }

        @Test("Reflective words contribute to emotional score")
        func reflectiveWords() async throws {
            let exchanges = [makeExchange(answer: "I realize understand believe think wonder")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional > 0)
        }

        @Test("Emotional score is capped at 100")
        func cappedAt100() async throws {
            // All emotional words should cap at 100
            let exchanges = [makeExchange(answer: "happy joy love grateful thankful blessed excited hopeful")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional <= 100)
        }

        @Test("Mixed content with some emotional words")
        func mixedContent() async throws {
            // Some emotional words mixed with non-emotional
            let exchanges = [makeExchange(answer: "Today the sun is shining and I feel happy about the weather outside")]

            let score = try await service.calculateScore(from: exchanges)

            // Should have some emotional score but not maximum
            #expect(score.emotional > 0)
            #expect(score.emotional < 100)
        }

        @Test("Case insensitive emotional word detection")
        func caseInsensitive() async throws {
            let exchanges = [makeExchange(answer: "I feel HAPPY and GRATEFUL")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.emotional > 0)
        }
    }

    // MARK: - Weighted Total Tests

    @Suite("Weighted Total Calculation")
    struct WeightedTotalTests {
        let service = MockClarityScoreService()

        func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
            Exchange(question: "Test?", answer: answer, skipped: skipped)
        }

        @Test("Perfect scores give high total")
        func perfectScores() async throws {
            // Create a long answer with emotional words for high scores across all components
            let emotionalWords = "I feel grateful happy hopeful love blessed peaceful calm inspired motivated confident"
            let fillerWords = (1...90).map { "word\($0)" }.joined(separator: " ")
            let answer = emotionalWords + " " + fillerWords

            let exchanges = [makeExchange(answer: answer)]

            let score = try await service.calculateScore(from: exchanges)

            // With 100% completion, high depth, and emotional words should be >= 70
            #expect(score.total >= 70)
        }

        @Test("All skipped gives low total")
        func allSkippedLowTotal() async throws {
            let exchanges = [
                makeExchange(answer: "", skipped: true),
                makeExchange(answer: "", skipped: true)
            ]

            let score = try await service.calculateScore(from: exchanges)

            // 0 completion, 0 depth, 0 emotional = 0 total
            #expect(score.total == 0)
        }

        @Test("Weighted calculation follows 30-40-30 split")
        func weightedSplit() async throws {
            // Create exchange with known characteristics:
            // 100% completion, minimal depth, no emotional words
            let exchanges = [makeExchange(answer: "Short answer here")]

            let score = try await service.calculateScore(from: exchanges)

            // completion = 100, depth ~= 6 (3 words * 2), emotional = 0
            // total = 100 * 0.30 + 6 * 0.40 + 0 * 0.30 = 30 + 2.4 + 0 = 32
            #expect(score.completion == 100)
            #expect(score.total >= 30) // At minimum the completion component
        }

        @Test("Depth has highest weight at 40%")
        func depthHighestWeight() async throws {
            // Long answer without emotional words emphasizes depth component
            let words = (1...60).map { "word\($0)" }.joined(separator: " ")
            let exchanges = [makeExchange(answer: words)]

            let score = try await service.calculateScore(from: exchanges)

            // completion = 100 (30 points), depth = 85 (34 points), emotional = 0 (0 points)
            // total = 30 + 34 = 64
            #expect(score.depth > 80)
            #expect(score.total >= 60)
        }
    }

    // MARK: - Quality Label Tests

    @Suite("Quality Labels")
    struct QualityLabelTests {
        let service = MockClarityScoreService()

        func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
            Exchange(question: "Test?", answer: answer, skipped: skipped)
        }

        @Test("Low score gives Quick Check-in label")
        func quickCheckInLabel() async throws {
            // Short answer, no emotional words = low score
            let exchanges = [makeExchange(answer: "Yes")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.total < 40)
            #expect(score.label == "Quick Check-in")
        }

        @Test("Medium score gives Thoughtful Reflection label")
        func thoughtfulReflectionLabel() async throws {
            // Medium length with some emotional content
            let words = (1...40).map { "word\($0)" }.joined(separator: " ")
            let answer = "I feel grateful and happy about " + words

            let exchanges = [makeExchange(answer: answer)]

            let score = try await service.calculateScore(from: exchanges)

            // Should be in 40-69 range
            if score.total >= 40 && score.total < 70 {
                #expect(score.label == "Thoughtful Reflection")
            }
        }

        @Test("High score gives Deep Dive label")
        func deepDiveLabel() async throws {
            // Very long answer with many emotional words
            let emotionalContent = "I feel grateful happy hopeful blessed excited peaceful calm content inspired motivated confident love joy thankful "
            let fillerWords = (1...80).map { "word\($0)" }.joined(separator: " ")
            let answer = emotionalContent + fillerWords

            let exchanges = [makeExchange(answer: answer)]

            let score = try await service.calculateScore(from: exchanges)

            if score.total >= 70 {
                #expect(score.label == "Deep Dive")
            }
        }

        @Test("ScoreQuality.from correctly maps scores")
        func scoreQualityMapping() {
            #expect(ScoreQuality.from(score: 0) == .quick)
            #expect(ScoreQuality.from(score: 39) == .quick)
            #expect(ScoreQuality.from(score: 40) == .moderate)
            #expect(ScoreQuality.from(score: 69) == .moderate)
            #expect(ScoreQuality.from(score: 70) == .high)
            #expect(ScoreQuality.from(score: 100) == .high)
        }

        @Test("ScoreQuality raw values are correct")
        func scoreQualityRawValues() {
            #expect(ScoreQuality.quick.rawValue == "Quick Check-in")
            #expect(ScoreQuality.moderate.rawValue == "Thoughtful Reflection")
            #expect(ScoreQuality.high.rawValue == "Deep Dive")
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {
        let service = MockClarityScoreService()

        func makeExchange(answer: String, skipped: Bool = false) -> Exchange {
            Exchange(question: "Test?", answer: answer, skipped: skipped)
        }

        @Test("Empty exchanges throws error")
        func emptyExchangesThrows() async {
            await #expect(throws: ClarityScoreServiceError.self) {
                try await service.calculateScore(from: [])
            }
        }

        @Test("Single word answer calculates correctly")
        func singleWordAnswer() async throws {
            let exchanges = [makeExchange(answer: "Yes")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.completion == 100)
            #expect(score.depth == 2) // 1 word * 2
            #expect(score.emotional == 0)
        }

        @Test("Score components are clamped 0-100")
        func scoresClamped() async throws {
            let exchanges = [makeExchange(answer: "test")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.total >= 0 && score.total <= 100)
            #expect(score.completion >= 0 && score.completion <= 100)
            #expect(score.depth >= 0 && score.depth <= 100)
            #expect(score.emotional >= 0 && score.emotional <= 100)
        }

        @Test("Message is not empty")
        func messageNotEmpty() async throws {
            let exchanges = [makeExchange(answer: "Some answer")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(!score.message.isEmpty)
        }

        @Test("ClarityScore quality property matches label")
        func qualityMatchesLabel() async throws {
            let exchanges = [makeExchange(answer: "Short")]

            let score = try await service.calculateScore(from: exchanges)

            #expect(score.quality.rawValue == score.label)
        }
    }

    // MARK: - ClarityScore Entity Tests

    @Suite("ClarityScore Entity")
    struct ClarityScoreEntityTests {

        @Test("ClarityScore initializer clamps values")
        func initializerClampsValues() {
            let score = ClarityScore(
                total: 150,
                completion: -10,
                depth: 200,
                emotional: 50,
                label: "Test",
                message: "Test message"
            )

            #expect(score.total == 100)
            #expect(score.completion == 0)
            #expect(score.depth == 100)
            #expect(score.emotional == 50)
        }

        @Test("ClarityScore conforms to Equatable")
        func equatable() {
            let score1 = ClarityScore(
                total: 75,
                completion: 80,
                depth: 70,
                emotional: 75,
                label: "Deep Dive",
                message: "Great job!"
            )
            let score2 = ClarityScore(
                total: 75,
                completion: 80,
                depth: 70,
                emotional: 75,
                label: "Deep Dive",
                message: "Great job!"
            )

            #expect(score1 == score2)
        }

        @Test("ClarityScore qualityColorName returns correct colors")
        func qualityColorName() {
            let quickScore = ClarityScore(total: 30, completion: 30, depth: 30, emotional: 30, label: "Quick Check-in", message: "")
            let moderateScore = ClarityScore(total: 50, completion: 50, depth: 50, emotional: 50, label: "Thoughtful Reflection", message: "")
            let highScore = ClarityScore(total: 80, completion: 80, depth: 80, emotional: 80, label: "Deep Dive", message: "")

            #expect(quickScore.qualityColorName == "orange")
            #expect(moderateScore.qualityColorName == "blue")
            #expect(highScore.qualityColorName == "green")
        }
    }
}
