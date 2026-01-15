// SessionScoreSummary.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays clarity score summary with breakdown for session detail view
struct SessionScoreSummary: View {
    let score: ClarityScore

    var body: some View {
        VStack(spacing: 16) {
            // Main score display
            HStack(spacing: 20) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: CGFloat(score.total) / 100)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(score.total)")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.primary)

                        Text("/ 100")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(score.label)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(score.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Score breakdown
            ScoreBreakdownView(
                completion: score.completion,
                depth: score.depth,
                emotional: score.emotional,
                animate: false
            )
        }
        .padding(.horizontal)
    }

    private var scoreColor: Color {
        switch score.quality {
        case .quick: return .orange
        case .moderate: return .blue
        case .high: return .green
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            SessionScoreSummary(
                score: ClarityScore(
                    total: 85,
                    completion: 100,
                    depth: 80,
                    emotional: 75,
                    label: "Deep Dive",
                    message: "An exceptionally thoughtful session of self-discovery."
                )
            )

            SessionScoreSummary(
                score: ClarityScore(
                    total: 52,
                    completion: 66,
                    depth: 45,
                    emotional: 50,
                    label: "Thoughtful Reflection",
                    message: "A good moment of introspection."
                )
            )

            SessionScoreSummary(
                score: ClarityScore(
                    total: 28,
                    completion: 33,
                    depth: 25,
                    emotional: 28,
                    label: "Quick Check-in",
                    message: "A brief moment to pause and reflect."
                )
            )
        }
        .padding(.vertical)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
