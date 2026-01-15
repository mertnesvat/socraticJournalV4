// DailyWisdomView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Featured display for the daily wisdom quote
public struct DailyWisdomView: View {
    let quote: WisdomQuote?
    var onTap: (() -> Void)? = nil

    public init(quote: WisdomQuote?, onTap: (() -> Void)? = nil) {
        self.quote = quote
        self.onTap = onTap
    }

    public var body: some View {
        Group {
            if let quote = quote {
                Button {
                    onTap?()
                } label: {
                    quoteContent(quote)
                }
                .buttonStyle(.plain)
            } else {
                loadingPlaceholder
            }
        }
    }

    private func quoteContent(_ quote: WisdomQuote) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.yellow)

                Text("Today's Wisdom")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                // Date
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Quote
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundStyle(.secondary.opacity(0.5))

                VStack(alignment: .leading, spacing: 12) {
                    Text(quote.text)
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
            }

            // Theme badge
            HStack {
                themeBadge(for: quote.theme)
                Spacer()
                Text("Tap to explore more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: .secondarySystemBackground),
                    Color(uiColor: .tertiarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var loadingPlaceholder: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.yellow)

                Text("Today's Wisdom")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }

            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func themeBadge(for theme: QuoteTheme) -> some View {
        HStack(spacing: 4) {
            Image(systemName: theme.iconName)
                .font(.caption)
            Text(theme.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(themeColor(for: theme))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(themeColor(for: theme).opacity(0.15))
        .clipShape(Capsule())
    }

    private func themeColor(for theme: QuoteTheme) -> Color {
        switch theme {
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

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

#Preview {
    VStack(spacing: 20) {
        DailyWisdomView(
            quote: WisdomQuote(
                text: "The unexamined life is not worth living.",
                author: "Socrates",
                theme: .selfKnowledge
            )
        )

        DailyWisdomView(
            quote: WisdomQuote(
                text: "He who knows others is wise; he who knows himself is enlightened.",
                author: "Lao Tzu",
                source: "Tao Te Ching",
                theme: .selfKnowledge
            )
        )

        DailyWisdomView(quote: nil)
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
