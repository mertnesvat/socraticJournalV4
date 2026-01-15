// WisdomQuotesViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the Wisdom Quotes browsable library
@Observable
@MainActor
public final class WisdomQuotesViewModel {
    // MARK: - State

    private(set) var quotes: [WisdomQuote] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var dailyQuote: WisdomQuote?

    var selectedTheme: QuoteTheme? = nil
    var searchText: String = ""

    /// Filtered quotes based on selected theme and search text
    var filteredQuotes: [WisdomQuote] {
        var result = quotes

        // Filter by theme
        if let theme = selectedTheme {
            result = result.filter { $0.theme == theme }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            result = result.filter { quote in
                quote.text.lowercased().contains(lowercasedSearch) ||
                quote.author.lowercased().contains(lowercasedSearch) ||
                (quote.source?.lowercased().contains(lowercasedSearch) ?? false)
            }
        }

        return result
    }

    /// Count of quotes by theme
    var quoteCountByTheme: [QuoteTheme: Int] {
        Dictionary(grouping: quotes, by: { $0.theme })
            .mapValues { $0.count }
    }

    /// Total number of quotes
    var totalQuoteCount: Int {
        quotes.count
    }

    // MARK: - Dependencies

    private let quoteService: WisdomQuoteServiceProtocol

    // MARK: - Initialization

    public init(quoteService: WisdomQuoteServiceProtocol) {
        self.quoteService = quoteService
    }

    // MARK: - Actions

    func loadQuotes() async {
        isLoading = true
        error = nil

        do {
            quotes = try await quoteService.loadQuotes()
            dailyQuote = quoteService.getDailyQuote()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func selectTheme(_ theme: QuoteTheme?) {
        selectedTheme = theme
    }

    func getRandomQuote() -> WisdomQuote? {
        if let theme = selectedTheme {
            return quoteService.getQuoteForTheme(theme)
        }
        return quoteService.getRandomQuote()
    }

    func clearFilters() {
        selectedTheme = nil
        searchText = ""
    }

    /// Get a quote matched to session content
    func getQuoteForContent(_ content: String) -> WisdomQuote? {
        return quoteService.matchQuoteToContent(content)
    }
}
#endif
