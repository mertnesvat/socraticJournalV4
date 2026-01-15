// QuoteCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Styled card for displaying a wisdom quote
public struct QuoteCard: View {
    let quote: WisdomQuote
    var showThemeBadge: Bool = true
    var style: CardStyle = .standard

    public enum CardStyle {
        case standard
        case featured
        case compact
    }

    public init(quote: WisdomQuote, showThemeBadge: Bool = true, style: CardStyle = .standard) {
        self.quote = quote
        self.showThemeBadge = showThemeBadge
        self.style = style
    }

    public var body: some View {
        switch style {
        case .standard:
            standardCard
        case .featured:
            featuredCard
        case .compact:
            compactCard
        }
    }

    // MARK: - Standard Card

    private var standardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Theme badge
            if showThemeBadge {
                themeBadge
            }

            // Quote text
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(quote.text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
            }

            // Attribution
            Text(quote.attribution)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Featured Card

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.yellow)

                Text("Daily Wisdom")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if showThemeBadge {
                    themeBadge
                }
            }

            // Quote text
            Text("\"\(quote.text)\"")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)

            // Attribution
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(quote.author)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    if let source = quote.source {
                        Text(source)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: .secondarySystemBackground),
                    Color(uiColor: .secondarySystemBackground).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Compact Card

    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            HStack {
                if showThemeBadge {
                    themeBadge
                }
                Spacer()
                Text("- \(quote.author)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Theme Badge

    private var themeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: quote.theme.iconName)
                .font(.caption)
            Text(quote.theme.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(themeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(themeColor.opacity(0.15))
        .clipShape(Capsule())
    }

    private var themeColor: Color {
        switch quote.theme {
        case .change:
            return .blue
        case .struggle:
            return .orange
        case .acceptance:
            return .green
        case .relationships:
            return .pink
        case .purpose:
            return .purple
        case .selfKnowledge:
            return .indigo
        case .time:
            return .cyan
        case .fear:
            return .red
        case .loss:
            return .gray
        case .gratitude:
            return .yellow
        case .creativity:
            return .mint
        case .universal:
            return .secondary
        }
    }
}

#Preview("Standard") {
    VStack(spacing: 16) {
        QuoteCard(
            quote: WisdomQuote(
                text: "The unexamined life is not worth living.",
                author: "Socrates",
                theme: .selfKnowledge
            )
        )

        QuoteCard(
            quote: WisdomQuote(
                text: "The only constant in life is change.",
                author: "Heraclitus",
                theme: .change
            )
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Featured") {
    QuoteCard(
        quote: WisdomQuote(
            text: "He who knows others is wise; he who knows himself is enlightened.",
            author: "Lao Tzu",
            source: "Tao Te Ching",
            theme: .selfKnowledge
        ),
        style: .featured
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Compact") {
    VStack(spacing: 8) {
        QuoteCard(
            quote: WisdomQuote(
                text: "Know thyself.",
                author: "Delphic Maxim",
                theme: .selfKnowledge
            ),
            style: .compact
        )

        QuoteCard(
            quote: WisdomQuote(
                text: "The impediment to action advances action. What stands in the way becomes the way.",
                author: "Marcus Aurelius",
                source: "Meditations",
                theme: .struggle
            ),
            style: .compact
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
