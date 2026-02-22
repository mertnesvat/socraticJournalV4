// SpicyTakesSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Section displaying the user's most reacted-to voice answers
struct SpicyTakesSection: View {
    let takes: [(question: String, reactionCount: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spiciest Takes")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(takes.enumerated()), id: \.offset) { _, take in
                        spicyTakeCard(question: take.question, reactions: take.reactionCount)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    private func spicyTakeCard(question: String, reactions: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            HStack(spacing: 4) {
                Text("🔥")
                    .font(.caption)
                Text("\(reactions)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .frame(width: 200, height: 100, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
        )
    }
}

#Preview {
    SpicyTakesSection(takes: [
        (question: "Is it ever okay to go through your partner's phone?", reactionCount: 847),
        (question: "What's something you've never said out loud?", reactionCount: 632),
        (question: "If you could delete one app from everyone's phone?", reactionCount: 519)
    ])
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
