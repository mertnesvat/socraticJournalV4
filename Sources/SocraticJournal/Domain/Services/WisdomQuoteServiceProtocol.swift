// WisdomQuoteServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Errors that can occur when working with wisdom quotes
public enum WisdomQuoteServiceError: Error, LocalizedError {
    case quotesNotLoaded
    case noQuotesAvailable
    case failedToLoadQuotes(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .quotesNotLoaded:
            return "Quotes have not been loaded yet."
        case .noQuotesAvailable:
            return "No quotes are available."
        case .failedToLoadQuotes(let error):
            return "Failed to load quotes: \(error.localizedDescription)"
        }
    }
}

/// Protocol for services that provide wisdom quotes
public protocol WisdomQuoteServiceProtocol: Sendable {
    /// Load all quotes from the data source
    /// - Returns: Array of all wisdom quotes
    func loadQuotes() async throws -> [WisdomQuote]

    /// Get a quote for a specific theme
    /// - Parameter theme: The quote theme to filter by
    /// - Returns: A random quote from the specified theme, or nil if none available
    func getQuoteForTheme(_ theme: QuoteTheme) -> WisdomQuote?

    /// Get a random quote from any theme
    /// - Returns: A random quote, or nil if none available
    func getRandomQuote() -> WisdomQuote?

    /// Match a quote to content based on keyword analysis
    /// - Parameter content: The content to analyze for theme matching
    /// - Returns: A quote matching the content's theme, or a random quote if no match
    func matchQuoteToContent(_ content: String) -> WisdomQuote?

    /// Get all quotes for a specific theme
    /// - Parameter theme: The theme to filter by
    /// - Returns: Array of quotes matching the theme
    func getQuotesForTheme(_ theme: QuoteTheme) -> [WisdomQuote]

    /// Get all available quotes
    /// - Returns: Array of all loaded quotes
    func getAllQuotes() -> [WisdomQuote]

    /// Get the quote of the day based on the current date
    /// - Returns: A consistent quote for the current day
    func getDailyQuote() -> WisdomQuote?
}
