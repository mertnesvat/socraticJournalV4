// FeaturesSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Features section with access to secondary features like Wisdom Quotes
struct FeaturesSettingsView: View {
    let onWisdomQuotesTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.headline)

            // Wisdom Quotes Library
            Button(action: onWisdomQuotesTapped) {
                HStack {
                    Image(systemName: "quote.bubble")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wisdom Quotes Library")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("Browse quotes for reflection")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FeaturesSettingsView(
        onWisdomQuotesTapped: {}
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
