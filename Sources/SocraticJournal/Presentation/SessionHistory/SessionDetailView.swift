// SessionDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Bottom sheet view displaying full session details
public struct SessionDetailView: View {
    @State private var viewModel: SessionDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: SessionDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Session metadata
                    SessionMetadataView(
                        date: viewModel.shortFormattedDate,
                        time: viewModel.sessionTime,
                        duration: viewModel.session.estimatedDuration,
                        exchangeCount: viewModel.totalExchanges,
                        answeredCount: viewModel.answeredCount,
                        skippedCount: viewModel.skippedCount
                    )

                    // Clarity Score Summary
                    if let score = viewModel.session.clarityScore {
                        SessionScoreSummary(score: score)
                    }

                    // Wisdom Quote
                    if let quote = viewModel.session.wisdomQuote {
                        WisdomQuoteView(quote: quote)
                            .padding(.horizontal)
                    }

                    // Insights section
                    if !viewModel.insightExchanges.isEmpty {
                        insightsSection
                    }

                    // Conversation history
                    conversationSection
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.insightExchanges) { exchange in
                        if let insight = exchange.insightCard {
                            InsightPillView(insight: insight)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Conversation Section

    private var conversationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conversation")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ForEach(Array(viewModel.sortedExchanges.enumerated()), id: \.element.id) { index, exchange in
                ExchangeDetailCard(
                    exchange: exchange,
                    exchangeNumber: index + 1
                )
                .padding(.horizontal)
            }
        }
    }
}

/// Small pill view for displaying insights horizontally
private struct InsightPillView: View {
    let insight: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundStyle(.yellow)

            Text(insight)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    let session = JournalSession(
        createdAt: Date(),
        exchanges: [
            Exchange(
                question: "What's on your mind today?",
                answer: "I've been thinking about my career direction and whether I'm making the right choices for my future. There's a lot of uncertainty.",
                socratesReaction: "Socrates nods thoughtfully, stroking his beard.",
                clarityMirror: "Your words reveal a search for meaning beyond the surface. The examined life requires such questioning.",
                insightCard: "Growth through uncertainty"
            ),
            Exchange(
                question: "What would success look like for you?",
                answer: "Success for me would mean feeling fulfilled and making a positive impact, not just financial gain.",
                socratesReaction: "Socrates smiles with recognition.",
                clarityMirror: "You seek virtue over mere fortune - a sign of wisdom.",
                insightCard: "Purpose over profit"
            ),
            Exchange(
                question: "What's holding you back?",
                answer: "Fear of failure, I suppose. And worrying what others might think.",
                socratesReaction: "Socrates leans forward with interest.",
                clarityMirror: "You recognize the chains of others' opinions. Awareness is the first step to freedom.",
                insightCard: "Breaking free from fear"
            )
        ],
        clarityScore: ClarityScore(
            total: 78,
            completion: 100,
            depth: 72,
            emotional: 65,
            label: "Deep Dive",
            message: "A thoughtful session of self-discovery."
        ),
        wisdomQuote: WisdomQuote(
            text: "The unexamined life is not worth living.",
            author: "Socrates"
        ),
        isComplete: true
    )

    let repository = InMemoryJournalRepository()

    return SessionDetailView(
        viewModel: SessionDetailViewModel(session: session, repository: repository)
    )
}
#endif
