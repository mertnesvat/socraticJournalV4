// ScoreBreakdownView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the three score components with progress bars
public struct ScoreBreakdownView: View {
    let completion: Int
    let depth: Int
    let emotional: Int
    let animate: Bool

    @State private var animatedCompletion: Int = 0
    @State private var animatedDepth: Int = 0
    @State private var animatedEmotional: Int = 0

    public init(
        completion: Int,
        depth: Int,
        emotional: Int,
        animate: Bool = true
    ) {
        self.completion = completion
        self.depth = depth
        self.emotional = emotional
        self.animate = animate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Breakdown")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                ScoreBarRow(
                    title: "Completion",
                    subtitle: "Questions answered",
                    weight: "30%",
                    score: animatedCompletion,
                    color: .blue
                )

                ScoreBarRow(
                    title: "Depth",
                    subtitle: "Response thoughtfulness",
                    weight: "40%",
                    score: animatedDepth,
                    color: .purple
                )

                ScoreBarRow(
                    title: "Emotional",
                    subtitle: "Self-reflection",
                    weight: "30%",
                    score: animatedEmotional,
                    color: .pink
                )
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            if animate {
                startAnimation()
            } else {
                animatedCompletion = completion
                animatedDepth = depth
                animatedEmotional = emotional
            }
        }
        .onChange(of: animate) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }

    private func startAnimation() {
        animatedCompletion = 0
        animatedDepth = 0
        animatedEmotional = 0

        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            animatedCompletion = completion
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            animatedDepth = depth
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            animatedEmotional = emotional
        }
    }
}

/// Individual row for a score component
struct ScoreBarRow: View {
    let title: String
    let subtitle: String
    let weight: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(score)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(weight)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    VStack {
        ScoreBreakdownView(
            completion: 100,
            depth: 75,
            emotional: 60,
            animate: false
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
