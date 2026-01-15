// WisdomQuoteView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Styled display for wisdom quotes
public struct WisdomQuoteView: View {
    let quote: WisdomQuote?

    public init(quote: WisdomQuote?) {
        self.quote = quote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("Words of Wisdom")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }

            if let quote = quote {
                // Quote text
                Text(quote.text)
                    .font(.body.italic())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)

                // Attribution
                Text(quote.attribution)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                // Loading placeholder
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 16)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
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
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        WisdomQuoteView(
            quote: WisdomQuote(
                text: "The unexamined life is not worth living.",
                author: "Socrates"
            )
        )

        WisdomQuoteView(
            quote: WisdomQuote(
                text: "He who knows others is wise; he who knows himself is enlightened.",
                author: "Lao Tzu",
                source: "Tao Te Ching"
            )
        )

        WisdomQuoteView(quote: nil)
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
