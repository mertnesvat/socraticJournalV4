// WisdomQuotesView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Browsable library of wisdom quotes
public struct WisdomQuotesView: View {
    @State private var viewModel: WisdomQuotesViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WisdomQuotesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Wisdom Library")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .searchable(text: $viewModel.searchText, prompt: "Search quotes or authors")
                .task { await viewModel.loadQuotes() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.quotes.isEmpty {
            loadingView
        } else if let error = viewModel.error, viewModel.quotes.isEmpty {
            errorView(error)
        } else if viewModel.quotes.isEmpty {
            emptyView
        } else {
            mainContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading wisdom...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Unable to Load Quotes",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Quotes Available",
            systemImage: "quote.bubble",
            description: Text("Wisdom quotes will appear here.")
        )
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily wisdom (only show when not searching/filtering)
                if viewModel.selectedTheme == nil && viewModel.searchText.isEmpty {
                    if let dailyQuote = viewModel.dailyQuote {
                        DailyWisdomView(quote: dailyQuote)
                            .padding(.horizontal)
                    }
                }

                // Theme filter
                ThemeFilterView(
                    selectedTheme: $viewModel.selectedTheme,
                    quoteCountByTheme: viewModel.quoteCountByTheme
                )

                // Results header
                resultsHeader

                // Quote list
                if viewModel.filteredQuotes.isEmpty {
                    noResultsView
                } else {
                    quoteList
                }

                // Bottom spacing
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var resultsHeader: some View {
        HStack {
            if let theme = viewModel.selectedTheme {
                HStack(spacing: 4) {
                    Image(systemName: theme.iconName)
                        .font(.subheadline)
                    Text(theme.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            } else if !viewModel.searchText.isEmpty {
                Text("Search Results")
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else {
                Text("All Quotes")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()

            Text("\(viewModel.filteredQuotes.count) quote\(viewModel.filteredQuotes.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No quotes found")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Try adjusting your search or filter")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if viewModel.selectedTheme != nil || !viewModel.searchText.isEmpty {
                Button("Clear Filters") {
                    viewModel.clearFilters()
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var quoteList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredQuotes) { quote in
                QuoteCard(
                    quote: quote,
                    showThemeBadge: viewModel.selectedTheme == nil
                )
                .padding(.horizontal)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Done") {
                dismiss()
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Section("Quick Actions") {
                    Button {
                        if let quote = viewModel.getRandomQuote() {
                            // Show random quote - for now just scroll to it
                            viewModel.clearFilters()
                        }
                    } label: {
                        Label("Random Quote", systemImage: "shuffle")
                    }
                }

                if viewModel.selectedTheme != nil || !viewModel.searchText.isEmpty {
                    Section {
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            Label("Clear Filters", systemImage: "xmark.circle")
                        }
                    }
                }

                Section("Stats") {
                    Text("\(viewModel.totalQuoteCount) total quotes")
                    Text("\(QuoteTheme.allCases.count) themes")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
        }
    }
}

#Preview {
    WisdomQuotesView(
        viewModel: WisdomQuotesViewModel(
            quoteService: LocalWisdomQuoteService()
        )
    )
}
#endif
