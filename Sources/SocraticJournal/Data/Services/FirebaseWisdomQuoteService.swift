// FirebaseWisdomQuoteService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service that generates contextual wisdom quotes using Firebase with fallback to local quotes
public final class FirebaseWisdomQuoteService: WisdomQuoteServiceProtocol, @unchecked Sendable {
    private let firebaseFunctionsService: FirebaseFunctionsServiceProtocol
    private let localWisdomQuoteService: LocalWisdomQuoteService
    private let lock = NSLock()

    /// Cache for quotes loaded from local service
    private var localQuotesLoaded = false

    public init(
        firebaseFunctionsService: FirebaseFunctionsServiceProtocol,
        localWisdomQuoteService: LocalWisdomQuoteService = LocalWisdomQuoteService()
    ) {
        self.firebaseFunctionsService = firebaseFunctionsService
        self.localWisdomQuoteService = localWisdomQuoteService
    }

    // MARK: - WisdomQuoteServiceProtocol

    public func loadQuotes() async throws -> [WisdomQuote] {
        let quotes = try await localWisdomQuoteService.loadQuotes()
        lock.lock()
        localQuotesLoaded = true
        lock.unlock()
        return quotes
    }

    public func getQuoteForTheme(_ theme: QuoteTheme) -> WisdomQuote? {
        return localWisdomQuoteService.getQuoteForTheme(theme)
    }

    public func getRandomQuote() -> WisdomQuote? {
        return localWisdomQuoteService.getRandomQuote()
    }

    public func matchQuoteToContent(_ content: String) -> WisdomQuote? {
        return localWisdomQuoteService.matchQuoteToContent(content)
    }

    public func getQuotesForTheme(_ theme: QuoteTheme) -> [WisdomQuote] {
        return localWisdomQuoteService.getQuotesForTheme(theme)
    }

    public func getAllQuotes() -> [WisdomQuote] {
        return localWisdomQuoteService.getAllQuotes()
    }

    public func getDailyQuote() -> WisdomQuote? {
        return localWisdomQuoteService.getDailyQuote()
    }

    // MARK: - AI-Powered Contextual Quote Generation

    /// Generate a contextual wisdom quote based on recent journal themes
    /// Falls back to local quote matching if Firebase call fails
    /// - Parameters:
    ///   - themes: Array of theme strings extracted from recent journal entries
    ///   - mood: Optional current mood to influence quote selection
    /// - Returns: An AI-generated quote if successful, or a matched local quote as fallback
    public func generateContextualQuote(themes: [String], mood: String? = nil) async -> WisdomQuote {
        // Ensure local quotes are loaded for fallback
        if !localQuotesLoaded {
            do {
                _ = try await loadQuotes()
            } catch {
                #if DEBUG
                print("[FirebaseWisdomQuoteService] Failed to load local quotes: \(error)")
                #endif
            }
        }

        // Try Firebase AI generation first
        do {
            let request = WisdomQuoteRequest(recentThemes: themes, mood: mood)
            let aiQuote = try await firebaseFunctionsService.generateWisdomQuote(request: request)

            #if DEBUG
            print("[FirebaseWisdomQuoteService] AI quote generated successfully")
            print("[FirebaseWisdomQuoteService] Relevance: \(aiQuote.relevance)")
            #endif

            // Determine the best matching theme for the AI quote
            let matchedTheme = matchTheme(from: themes)

            return aiQuote.toWisdomQuote(theme: matchedTheme)
        } catch {
            #if DEBUG
            print("[FirebaseWisdomQuoteService] AI generation failed, falling back to local: \(error)")
            #endif

            // Fallback to local quote matching
            return fallbackToLocalQuote(themes: themes)
        }
    }

    /// Generate a contextual wisdom quote with full AI response details
    /// - Parameters:
    ///   - themes: Array of theme strings extracted from recent journal entries
    ///   - mood: Optional current mood to influence quote selection
    /// - Returns: Full AI wisdom quote response if successful, nil if fallback was used
    public func generateContextualQuoteWithDetails(themes: [String], mood: String? = nil) async -> (quote: WisdomQuote, aiDetails: AIWisdomQuote?)  {
        // Ensure local quotes are loaded for fallback
        if !localQuotesLoaded {
            do {
                _ = try await loadQuotes()
            } catch {
                #if DEBUG
                print("[FirebaseWisdomQuoteService] Failed to load local quotes: \(error)")
                #endif
            }
        }

        // Try Firebase AI generation first
        do {
            let request = WisdomQuoteRequest(recentThemes: themes, mood: mood)
            let aiQuote = try await firebaseFunctionsService.generateWisdomQuote(request: request)

            let matchedTheme = matchTheme(from: themes)
            let wisdomQuote = aiQuote.toWisdomQuote(theme: matchedTheme)

            return (quote: wisdomQuote, aiDetails: aiQuote)
        } catch {
            #if DEBUG
            print("[FirebaseWisdomQuoteService] AI generation failed: \(error)")
            #endif

            let fallbackQuote = fallbackToLocalQuote(themes: themes)
            return (quote: fallbackQuote, aiDetails: nil)
        }
    }

    // MARK: - Private Helpers

    /// Match theme strings to QuoteTheme enum
    private func matchTheme(from themes: [String]) -> QuoteTheme {
        let themesLowercased = themes.map { $0.lowercased() }

        // Score each QuoteTheme by keyword matches
        var bestMatch: QuoteTheme = .universal
        var bestScore = 0

        for quoteTheme in QuoteTheme.allCases {
            let score = quoteTheme.keywords.reduce(0) { count, keyword in
                themesLowercased.contains { $0.contains(keyword) } ? count + 1 : count
            }
            if score > bestScore {
                bestScore = score
                bestMatch = quoteTheme
            }
        }

        return bestMatch
    }

    /// Fallback to local quote when Firebase fails
    private func fallbackToLocalQuote(themes: [String]) -> WisdomQuote {
        // Try to match based on theme content
        let combinedContent = themes.joined(separator: " ")

        if let matched = localWisdomQuoteService.matchQuoteToContent(combinedContent) {
            return matched
        }

        // Final fallback to random quote
        if let random = localWisdomQuoteService.getRandomQuote() {
            return random
        }

        // Absolute fallback if no quotes loaded
        return WisdomQuote(
            text: "The unexamined life is not worth living.",
            author: "Socrates",
            theme: .selfKnowledge
        )
    }
}

// MARK: - Convenience Extension for Theme Extraction

public extension FirebaseWisdomQuoteService {
    /// Extract themes from journal session exchanges for quote generation
    /// - Parameter exchanges: Array of question-answer exchanges from a session
    /// - Returns: Array of extracted theme strings
    static func extractThemes(from exchanges: [Exchange]) -> [String] {
        var themes: [String] = []

        for exchange in exchanges {
            // Extract key phrases from answers
            let answer = exchange.answer.lowercased()

            // Check for emotional keywords
            let emotionalKeywords = ["happy", "sad", "anxious", "worried", "excited", "scared", "grateful", "frustrated", "hopeful", "overwhelmed"]
            for keyword in emotionalKeywords {
                if answer.contains(keyword) {
                    themes.append(keyword)
                }
            }

            // Check for topic keywords
            let topicKeywords = ["work", "family", "relationship", "health", "career", "money", "friendship", "love", "future", "past", "change", "decision", "growth"]
            for keyword in topicKeywords {
                if answer.contains(keyword) {
                    themes.append(keyword)
                }
            }
        }

        // Remove duplicates and limit to most relevant
        let uniqueThemes = Array(Set(themes))
        return Array(uniqueThemes.prefix(5))
    }

    /// Extract mood from the most recent exchange
    /// - Parameter exchange: The most recent exchange
    /// - Returns: Detected mood string or nil
    static func extractMood(from exchange: Exchange) -> String? {
        let answer = exchange.answer.lowercased()

        let moodMap: [(keywords: [String], mood: String)] = [
            (["happy", "joy", "excited", "great", "wonderful", "amazing"], "positive"),
            (["sad", "down", "depressed", "unhappy", "miserable"], "sad"),
            (["anxious", "worried", "nervous", "stressed", "overwhelmed"], "anxious"),
            (["angry", "frustrated", "annoyed", "irritated"], "frustrated"),
            (["peaceful", "calm", "relaxed", "content"], "calm"),
            (["confused", "uncertain", "lost", "unsure"], "uncertain"),
            (["hopeful", "optimistic", "looking forward"], "hopeful")
        ]

        for (keywords, mood) in moodMap {
            for keyword in keywords {
                if answer.contains(keyword) {
                    return mood
                }
            }
        }

        return nil
    }
}
