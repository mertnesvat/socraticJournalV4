// BreathCircleView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Animated breathing circle — the core visual element
struct BreathCircleView: View {
    let scale: Double
    let phaseLabel: String
    let timeRemaining: TimeInterval
    var showLabels: Bool = true
    var color: Color = AppColors.accent

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 60 * scale,
                        endRadius: 160 * scale
                    )
                )
                .frame(width: 320 * scale, height: 320 * scale)

            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 240 * scale, height: 240 * scale)
                .shadow(color: color.opacity(0.4), radius: 20, x: 0, y: 8)

            // Labels
            if showLabels {
                VStack(spacing: 4) {
                    Text(phaseLabel)
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)

                    Text(String(format: "%.1fs", timeRemaining))
                        .font(AppTypography.timer)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .animation(.linear(duration: 0.016), value: scale)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(phaseLabel), \(String(format: "%.0f", timeRemaining)) seconds remaining")
    }
}

/// Demo mode breath circle for onboarding — no labels, gentle animation
struct DemoBreathCircle: View {
    @State private var scale: Double = 0.4
    let color: Color
    private let animationDuration: Double = 5.5

    var body: some View {
        Circle()
            .fill(color.opacity(0.5))
            .frame(width: 200 * scale, height: 200 * scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.0
                }
            }
    }
}
#endif
