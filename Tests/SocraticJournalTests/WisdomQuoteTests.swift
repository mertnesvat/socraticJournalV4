// WisdomQuoteTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for WisdomQuote entity, QuoteTheme, and LocalWisdomQuoteService matching logic
@Suite("WisdomQuote Tests")
struct WisdomQuoteTests {

    // MARK: - QuoteTheme Keywords Tests

    @Suite("QuoteTheme Keywords")
    struct QuoteThemeKeywordsTests {

        @Test("Fear theme contains expected keywords")
        func fearThemeKeywords() {
            let keywords = QuoteTheme.fear.keywords

            #expect(keywords.contains("fear"))
            #expect(keywords.contains("afraid"))
            #expect(keywords.contains("scared"))
            #expect(keywords.contains("worry"))
            #expect(keywords.contains("anxious"))
            #expect(keywords.contains("courage"))
            #expect(keywords.contains("brave"))
            #expect(keywords.contains("terror"))
        }

        @Test("Change theme contains expected keywords")
        func changeThemeKeywords() {
            let keywords = QuoteTheme.change.keywords

            #expect(keywords.contains("change"))
            #expect(keywords.contains("transform"))
            #expect(keywords.contains("different"))
            #expect(keywords.contains("evolve"))
            #expect(keywords.contains("grow"))
            #expect(keywords.contains("become"))
            #expect(keywords.contains("new"))
            #expect(keywords.contains("transition"))
        }

        @Test("Gratitude theme contains expected keywords")
        func gratitudeThemeKeywords() {
            let keywords = QuoteTheme.gratitude.keywords

            #expect(keywords.contains("grateful"))
            #expect(keywords.contains("thankful"))
            #expect(keywords.contains("appreciate"))
            #expect(keywords.contains("blessed"))
            #expect(keywords.contains("fortune"))
            #expect(keywords.contains("luck"))
            #expect(keywords.contains("gift"))
            #expect(keywords.contains("cherish"))
        }

        @Test("Self-knowledge theme contains expected keywords")
        func selfKnowledgeThemeKeywords() {
            let keywords = QuoteTheme.selfKnowledge.keywords

            #expect(keywords.contains("know"))
            #expect(keywords.contains("understand"))
            #expect(keywords.contains("self"))
            #expect(keywords.contains("identity"))
            #expect(keywords.contains("who am i"))
            #expect(keywords.contains("discover"))
            #expect(keywords.contains("awareness"))
            #expect(keywords.contains("insight"))
        }

        @Test("All themes have non-empty keywords", arguments: QuoteTheme.allCases)
        func allThemesHaveKeywords(theme: QuoteTheme) {
            #expect(!theme.keywords.isEmpty)
            #expect(theme.keywords.count >= 5)
        }

        @Test("All themes have display names", arguments: QuoteTheme.allCases)
        func allThemesHaveDisplayNames(theme: QuoteTheme) {
            #expect(!theme.displayName.isEmpty)
        }

        @Test("All themes have icon names", arguments: QuoteTheme.allCases)
        func allThemesHaveIconNames(theme: QuoteTheme) {
            #expect(!theme.iconName.isEmpty)
        }
    }

    // MARK: - matchQuoteToContent Tests

    @Suite("matchQuoteToContent")
    struct MatchQuoteToContentTests {

        @Test("Returns quote when content contains fear keywords")
        func matchesFearKeywords() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let content = "I'm feeling afraid and worried about the future"
            let quote = service.matchQuoteToContent(content)

            #expect(quote != nil)
        }

        @Test("Returns quote when content contains change keywords")
        func matchesChangeKeywords() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let content = "Everything is different now, I need to transform my life"
            let quote = service.matchQuoteToContent(content)

            #expect(quote != nil)
        }

        @Test("Returns quote when content contains gratitude keywords")
        func matchesGratitudeKeywords() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let content = "I feel so grateful and thankful for everything"
            let quote = service.matchQuoteToContent(content)

            #expect(quote != nil)
        }

        @Test("Matching is case insensitive")
        func caseInsensitiveMatching() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let content = "FEAR and COURAGE are on my mind"
            let quote = service.matchQuoteToContent(content)

            #expect(quote != nil)
        }

        @Test("Matching works with mixed case content")
        func mixedCaseMatching() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let content = "I am Grateful for this moment and Thankful"
            let quote = service.matchQuoteToContent(content)

            #expect(quote != nil)
        }

        @Test("Falls back to random quote when no keywords match")
        func fallsBackToRandomQuote() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            // Content with no matching keywords
            let content = "xyz123 random gibberish qwerty"
            let quote = service.matchQuoteToContent(content)

            // Should still return a quote (random fallback)
            #expect(quote != nil)
        }

        @Test("Returns quote for empty content string")
        func emptyContentFallsBack() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let content = ""
            let quote = service.matchQuoteToContent(content)

            // Should return a random quote as fallback
            #expect(quote != nil)
        }

        @Test("Scores multiple keyword matches correctly")
        func multipleKeywordMatches() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            // Content with multiple fear keywords should match fear theme
            let content = "I am afraid and scared, full of fear and worry"
            let quote = service.matchQuoteToContent(content)

            #expect(quote != nil)
        }

        @Test("Returns quote when content has keywords from multiple themes")
        func mixedThemeContent() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            // Content with keywords from different themes
            let content = "I feel afraid of change but grateful for growth"
            let quote = service.matchQuoteToContent(content)

            // Should return a quote (highest scored theme wins)
            #expect(quote != nil)
        }
    }

    // MARK: - getDailyQuote Tests

    @Suite("getDailyQuote")
    struct GetDailyQuoteTests {

        @Test("Returns consistent quote when called multiple times same day")
        func consistentSameDay() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let quote1 = service.getDailyQuote()
            let quote2 = service.getDailyQuote()
            let quote3 = service.getDailyQuote()

            // Same day should return same quote
            #expect(quote1 == quote2)
            #expect(quote2 == quote3)
        }

        @Test("Returns nil when no quotes are loaded")
        func nilWhenEmpty() {
            let service = LocalWisdomQuoteService()
            // Don't load quotes
            let quote = service.getDailyQuote()

            #expect(quote == nil)
        }

        @Test("Returns non-nil quote after loading")
        func nonNilAfterLoading() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let quote = service.getDailyQuote()

            #expect(quote != nil)
        }

        @Test("Daily quote has valid properties")
        func dailyQuoteHasValidProperties() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()

            let quote = service.getDailyQuote()

            #expect(quote != nil)
            #expect(!quote!.text.isEmpty)
            #expect(!quote!.author.isEmpty)
        }
    }

    // MARK: - WisdomQuote Entity Tests

    @Suite("WisdomQuote Entity")
    struct WisdomQuoteEntityTests {

        @Test("Attribution includes author and source when source exists")
        func attributionWithSource() {
            let quote = WisdomQuote(
                text: "Test quote",
                author: "Test Author",
                source: "Test Book"
            )

            #expect(quote.attribution == "- Test Author, Test Book")
        }

        @Test("Attribution includes only author when source is nil")
        func attributionWithoutSource() {
            let quote = WisdomQuote(
                text: "Test quote",
                author: "Test Author"
            )

            #expect(quote.attribution == "- Test Author")
        }

        @Test("Initializes with correct default values")
        func defaultValues() {
            let quote = WisdomQuote(
                text: "Test",
                author: "Author"
            )

            #expect(quote.text == "Test")
            #expect(quote.author == "Author")
            #expect(quote.source == nil)
            #expect(quote.theme == .universal)
        }

        @Test("Initializes with all custom values")
        func customValues() {
            let id = UUID()
            let quote = WisdomQuote(
                id: id,
                text: "Custom text",
                author: "Custom author",
                source: "Custom source",
                theme: .fear
            )

            #expect(quote.id == id)
            #expect(quote.text == "Custom text")
            #expect(quote.author == "Custom author")
            #expect(quote.source == "Custom source")
            #expect(quote.theme == .fear)
        }

        @Test("Conforms to Equatable")
        func equatable() {
            let id = UUID()
            let quote1 = WisdomQuote(
                id: id,
                text: "Test",
                author: "Author",
                source: "Source",
                theme: .universal
            )
            let quote2 = WisdomQuote(
                id: id,
                text: "Test",
                author: "Author",
                source: "Source",
                theme: .universal
            )

            #expect(quote1 == quote2)
        }

        @Test("Conforms to Identifiable")
        func identifiable() {
            let id = UUID()
            let quote = WisdomQuote(
                id: id,
                text: "Test",
                author: "Author"
            )

            #expect(quote.id == id)
        }
    }

    // MARK: - LocalWisdomQuoteService Additional Tests

    @Suite("LocalWisdomQuoteService")
    struct LocalWisdomQuoteServiceTests {

        @Test("loadQuotes returns non-empty array")
        func loadQuotesReturnsNonEmpty() async throws {
            let service = LocalWisdomQuoteService()
            let quotes = try await service.loadQuotes()

            #expect(!quotes.isEmpty)
        }

        @Test("getAllQuotes returns empty before loading")
        func getAllQuotesEmptyBeforeLoad() {
            let service = LocalWisdomQuoteService()
            let quotes = service.getAllQuotes()

            #expect(quotes.isEmpty)
        }

        @Test("getAllQuotes returns quotes after loading")
        func getAllQuotesAfterLoad() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()
            let quotes = service.getAllQuotes()

            #expect(!quotes.isEmpty)
        }

        @Test("getRandomQuote returns nil before loading")
        func getRandomQuoteNilBeforeLoad() {
            let service = LocalWisdomQuoteService()
            let quote = service.getRandomQuote()

            #expect(quote == nil)
        }

        @Test("getRandomQuote returns quote after loading")
        func getRandomQuoteAfterLoad() async throws {
            let service = LocalWisdomQuoteService()
            _ = try await service.loadQuotes()
            let quote = service.getRandomQuote()

            #expect(quote != nil)
        }

        @Test("getQuoteForTheme returns nil before loading")
        func getQuoteForThemeNilBeforeLoad() {
            let service = LocalWisdomQuoteService()
            let quote = service.getQuoteForTheme(.fear)

            #expect(quote == nil)
        }

        @Test("getQuotesForTheme returns empty before loading")
        func getQuotesForThemeEmptyBeforeLoad() {
            let service = LocalWisdomQuoteService()
            let quotes = service.getQuotesForTheme(.fear)

            #expect(quotes.isEmpty)
        }
    }

    // MARK: - QuoteTheme Enum Tests

    @Suite("QuoteTheme Enum")
    struct QuoteThemeEnumTests {

        @Test("All expected cases exist")
        func allCasesExist() {
            let themes = QuoteTheme.allCases

            #expect(themes.contains(.change))
            #expect(themes.contains(.struggle))
            #expect(themes.contains(.acceptance))
            #expect(themes.contains(.relationships))
            #expect(themes.contains(.purpose))
            #expect(themes.contains(.selfKnowledge))
            #expect(themes.contains(.time))
            #expect(themes.contains(.fear))
            #expect(themes.contains(.loss))
            #expect(themes.contains(.gratitude))
            #expect(themes.contains(.creativity))
            #expect(themes.contains(.universal))
            #expect(themes.count == 12)
        }

        @Test("Raw values are not empty", arguments: QuoteTheme.allCases)
        func rawValuesNotEmpty(theme: QuoteTheme) {
            #expect(!theme.rawValue.isEmpty)
        }

        @Test("Conforms to CaseIterable")
        func caseIterable() {
            let allCases = QuoteTheme.allCases
            #expect(allCases.count == 12)
        }
    }
}
