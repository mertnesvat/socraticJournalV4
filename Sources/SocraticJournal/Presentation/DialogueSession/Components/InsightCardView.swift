// InsightCardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the 3-4 word insight summary card
struct InsightCardView: View {
    let insight: String

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundStyle(.yellow)

            // Insight text
            Text(insight)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            // Label
            Text("Today's Insight")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.15),
                            Color.orange.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        InsightCardView(insight: "Growth through challenge")

        InsightCardView(insight: "Seeking deeper truth")

        InsightCardView(insight: "Courage in uncertainty")
    }
    .padding()
}
#endif
