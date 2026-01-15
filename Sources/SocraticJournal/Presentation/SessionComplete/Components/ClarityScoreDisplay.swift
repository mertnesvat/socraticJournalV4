// ClarityScoreDisplay.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Large circular display for the clarity score
public struct ClarityScoreDisplay: View {
    let score: Int
    let label: String
    let quality: ScoreQuality
    let animate: Bool

    @State private var animatedScore: Int = 0
    @State private var showLabel: Bool = false

    public init(
        score: Int,
        label: String,
        quality: ScoreQuality,
        animate: Bool = true
    ) {
        self.score = score
        self.label = label
        self.quality = quality
        self.animate = animate
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Circular score display
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        Color.gray.opacity(0.2),
                        lineWidth: 12
                    )
                    .frame(width: 180, height: 180)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        qualityColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                // Score number
                VStack(spacing: 4) {
                    Text("\(animatedScore)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(qualityColor)

                    Text("out of 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Score label
            if showLabel {
                Text(label)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .onAppear {
            if animate {
                startAnimation()
            } else {
                animatedScore = score
                showLabel = true
            }
        }
        .onChange(of: animate) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }

    private var progressValue: CGFloat {
        CGFloat(animatedScore) / 100.0
    }

    private var qualityColor: Color {
        switch quality {
        case .quick:
            return .orange
        case .moderate:
            return .blue
        case .high:
            return .green
        }
    }

    private func startAnimation() {
        // Animate score counting up
        animatedScore = 0
        showLabel = false

        let duration: Double = 1.5
        let steps = min(score, 60)
        let interval = duration / Double(steps)

        for i in 0...steps {
            let targetScore = (score * i) / steps
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                withAnimation(.easeOut(duration: 0.1)) {
                    animatedScore = targetScore
                }
            }
        }

        // Show label after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
            withAnimation(.easeIn(duration: 0.3)) {
                showLabel = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ClarityScoreDisplay(
            score: 85,
            label: "Deep Dive",
            quality: .high,
            animate: false
        )

        ClarityScoreDisplay(
            score: 55,
            label: "Thoughtful Reflection",
            quality: .moderate,
            animate: false
        )

        ClarityScoreDisplay(
            score: 25,
            label: "Quick Check-in",
            quality: .quick,
            animate: false
        )
    }
    .padding()
}
#endif
