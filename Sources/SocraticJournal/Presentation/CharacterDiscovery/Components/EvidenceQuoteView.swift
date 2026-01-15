// EvidenceQuoteView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a quote from the user's journal as evidence for a personality trait
struct EvidenceQuoteView: View {
    let quote: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Quote decoration
            Rectangle()
                .fill(Color.accentColor.opacity(0.5))
                .frame(width: 3)

            // Quote text
            Text(cleanQuote)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .italic()
                .lineSpacing(4)
        }
        .padding(.vertical, 8)
    }

    /// Removes extra quote marks if present
    private var cleanQuote: String {
        var result = quote
        if result.hasPrefix("\"") {
            result.removeFirst()
        }
        if result.hasSuffix("\"") {
            result.removeLast()
        }
        return result
    }
}

#Preview {
    VStack(spacing: 16) {
        EvidenceQuoteView(quote: "\"I've been thinking about trying something completely different...\"")
        EvidenceQuoteView(quote: "What if I looked at this from another perspective?")
        EvidenceQuoteView(quote: "\"Sometimes I wonder if there's a better way to approach these challenges. It helps to step back and see the bigger picture.\"")
    }
    .padding()
}
#endif
