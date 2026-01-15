// ExchangeDetailCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full Q&A display card with clarity mirror for session detail view
struct ExchangeDetailCard: View {
    let exchange: Exchange
    let exchangeNumber: Int

    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with exchange number
            headerView

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Question
                    questionSection

                    // Answer or skipped indicator
                    if exchange.skipped {
                        skippedIndicator
                    } else {
                        answerSection
                    }

                    // Socrates' Reaction
                    if let reaction = exchange.socratesReaction, !exchange.skipped {
                        reactionSection(reaction)
                    }

                    // Clarity Mirror
                    if let mirror = exchange.clarityMirror, !exchange.skipped {
                        ClarityMirrorCard(reflection: mirror)
                    }

                    // Insight Card
                    if let insight = exchange.insightCard, !exchange.skipped {
                        insightBadge(insight)
                    }
                }
                .padding()
            }
        }
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header

    private var headerView: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Label("Exchange \(exchangeNumber)", systemImage: "bubble.left.and.bubble.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                if exchange.skipped {
                    Text("Skipped")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Question Section

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)

                Text("Question")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
            }

            Text(exchange.question)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Answer Section

    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.green)

                Text("Your Response")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            Text(exchange.answer)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Skipped Indicator

    private var skippedIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "forward.fill")
                .font(.caption)
                .foregroundStyle(.orange)

            Text("You chose to skip this question")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Reaction Section

    private func reactionSection(_ reaction: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "theatermasks.fill")
                .font(.title3)
                .foregroundStyle(.purple)

            Text(reaction)
                .font(.subheadline.italic())
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.purple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Insight Badge

    private func insightBadge(_ insight: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.subheadline)
                .foregroundStyle(.yellow)

            Text(insight)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    Color.yellow.opacity(0.15),
                    Color.orange.opacity(0.1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ExchangeDetailCard(
                exchange: Exchange(
                    question: "What's been occupying your thoughts lately?",
                    answer: "I've been reflecting on my relationships and wondering if I'm truly present with the people I care about, or if I'm often distracted by work and other concerns.",
                    socratesReaction: "Socrates nods slowly, his eyes reflecting deep understanding.",
                    clarityMirror: "Your words reveal a yearning for authentic connection. The awareness of one's own distraction is itself a form of presence.",
                    insightCard: "Presence over perfection"
                ),
                exchangeNumber: 1
            )

            ExchangeDetailCard(
                exchange: Exchange(
                    question: "What would deeper presence look like for you?",
                    answer: "I skipped this one",
                    skipped: true
                ),
                exchangeNumber: 2
            )

            ExchangeDetailCard(
                exchange: Exchange(
                    question: "How do you feel when you're truly connected with someone?",
                    answer: "There's a sense of time slowing down. The rest of the world fades and I feel genuinely at peace.",
                    socratesReaction: "Socrates smiles warmly.",
                    clarityMirror: "You describe kairos - the quality of time, not its quantity. This is wisdom.",
                    insightCard: "Quality over quantity"
                ),
                exchangeNumber: 3
            )
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
