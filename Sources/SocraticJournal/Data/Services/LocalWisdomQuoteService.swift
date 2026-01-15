// LocalWisdomQuoteService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service that loads and provides wisdom quotes from a local JSON file
public final class LocalWisdomQuoteService: WisdomQuoteServiceProtocol, @unchecked Sendable {
    private var quotes: [WisdomQuote] = []
    private var quotesByTheme: [QuoteTheme: [WisdomQuote]] = [:]
    private let lock = NSLock()

    public init() {}

    // MARK: - WisdomQuoteServiceProtocol

    public func loadQuotes() async throws -> [WisdomQuote] {
        // Try to load from bundle first
        guard let url = Bundle.module.url(forResource: "wisdom_quotes", withExtension: "json") else {
            // Fallback: return hardcoded quotes if bundle resource not found
            let fallbackQuotes = getFallbackQuotes()
            lock.lock()
            self.quotes = fallbackQuotes
            self.buildThemeIndex()
            lock.unlock()
            return fallbackQuotes
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedQuotes = try decoder.decode([WisdomQuote].self, from: data)

            lock.lock()
            self.quotes = loadedQuotes
            self.buildThemeIndex()
            lock.unlock()

            return loadedQuotes
        } catch {
            throw WisdomQuoteServiceError.failedToLoadQuotes(underlying: error)
        }
    }

    public func getQuoteForTheme(_ theme: QuoteTheme) -> WisdomQuote? {
        lock.lock()
        defer { lock.unlock() }

        guard let themQuotes = quotesByTheme[theme], !themQuotes.isEmpty else {
            return nil
        }
        return themQuotes.randomElement()
    }

    public func getRandomQuote() -> WisdomQuote? {
        lock.lock()
        defer { lock.unlock() }

        return quotes.randomElement()
    }

    public func matchQuoteToContent(_ content: String) -> WisdomQuote? {
        let lowercasedContent = content.lowercased()

        // Score each theme based on keyword matches
        var themeScores: [QuoteTheme: Int] = [:]

        for theme in QuoteTheme.allCases {
            let score = theme.keywords.reduce(0) { count, keyword in
                count + (lowercasedContent.contains(keyword) ? 1 : 0)
            }
            if score > 0 {
                themeScores[theme] = score
            }
        }

        // Get the theme with highest score
        if let bestMatch = themeScores.max(by: { $0.value < $1.value }) {
            if let quote = getQuoteForTheme(bestMatch.key) {
                return quote
            }
        }

        // Fallback to random quote
        return getRandomQuote()
    }

    public func getQuotesForTheme(_ theme: QuoteTheme) -> [WisdomQuote] {
        lock.lock()
        defer { lock.unlock() }

        return quotesByTheme[theme] ?? []
    }

    public func getAllQuotes() -> [WisdomQuote] {
        lock.lock()
        defer { lock.unlock() }

        return quotes
    }

    public func getDailyQuote() -> WisdomQuote? {
        lock.lock()
        defer { lock.unlock() }

        guard !quotes.isEmpty else { return nil }

        // Use the current date to deterministically select a quote
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysSinceReferenceDate = Int(today.timeIntervalSinceReferenceDate / 86400)
        let index = abs(daysSinceReferenceDate) % quotes.count

        return quotes[index]
    }

    // MARK: - Private Helpers

    private func buildThemeIndex() {
        quotesByTheme = Dictionary(grouping: quotes, by: { $0.theme })
    }

    /// Fallback quotes in case JSON loading fails
    private func getFallbackQuotes() -> [WisdomQuote] {
        return [
            WisdomQuote(
                text: "The unexamined life is not worth living.",
                author: "Socrates",
                theme: .selfKnowledge
            ),
            WisdomQuote(
                text: "Know thyself.",
                author: "Delphic Maxim",
                theme: .selfKnowledge
            ),
            WisdomQuote(
                text: "He who knows others is wise; he who knows himself is enlightened.",
                author: "Lao Tzu",
                source: "Tao Te Ching",
                theme: .selfKnowledge
            ),
            WisdomQuote(
                text: "The impediment to action advances action. What stands in the way becomes the way.",
                author: "Marcus Aurelius",
                source: "Meditations",
                theme: .struggle
            ),
            WisdomQuote(
                text: "The journey of a thousand miles begins with a single step.",
                author: "Lao Tzu",
                source: "Tao Te Ching",
                theme: .universal
            ),
            WisdomQuote(
                text: "Courage is not the absence of fear, but rather the judgment that something else is more important than fear.",
                author: "Ambrose Redmoon",
                theme: .fear
            ),
            WisdomQuote(
                text: "The only constant in life is change.",
                author: "Heraclitus",
                theme: .change
            ),
            WisdomQuote(
                text: "Gratitude turns what we have into enough.",
                author: "Anonymous",
                theme: .gratitude
            ),
            WisdomQuote(
                text: "The wound is the place where the Light enters you.",
                author: "Rumi",
                theme: .loss
            ),
            WisdomQuote(
                text: "Creativity takes courage.",
                author: "Henri Matisse",
                theme: .creativity
            ),
            WisdomQuote(
                text: "A friend is one soul abiding in two bodies.",
                author: "Aristotle",
                theme: .relationships
            ),
            WisdomQuote(
                text: "Happiness can exist only in acceptance.",
                author: "George Orwell",
                theme: .acceptance
            )
        ]
    }
}
