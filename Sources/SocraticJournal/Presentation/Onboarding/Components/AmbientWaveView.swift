// AmbientWaveView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A simple ambient sine wave animation for onboarding backgrounds.
/// Gently oscillates to create a calming visual mood-setter.
public struct AmbientWaveView: View {
    let color: Color
    let opacity: Double
    let amplitude: CGFloat
    let frequency: CGFloat

    public init(
        color: Color = .white,
        opacity: Double = 0.15,
        amplitude: CGFloat = 20,
        frequency: CGFloat = 1.5
    ) {
        self.color = color
        self.opacity = opacity
        self.amplitude = amplitude
        self.frequency = frequency
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let phaseShift = elapsed * 0.5
                drawWave(
                    context: context,
                    size: size,
                    phase: phaseShift,
                    verticalOffset: size.height * 0.5
                )
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }

    private func drawWave(
        context: GraphicsContext,
        size: CGSize,
        phase: Double,
        verticalOffset: CGFloat
    ) {
        var path = Path()
        let stepCount = Int(size.width)

        path.move(to: CGPoint(x: 0, y: size.height))

        for x in 0...stepCount {
            let xPos = CGFloat(x)
            let normalizedX = xPos / size.width
            let yPos = verticalOffset + amplitude * sin(
                (normalizedX * frequency * .pi * 2) + CGFloat(phase)
            )
            path.addLine(to: CGPoint(x: xPos, y: yPos))
        }

        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()

        context.fill(path, with: .color(color))
    }
}

#Preview {
    ZStack {
        Color(hex: "0B1426")
        AmbientWaveView()
    }
    .ignoresSafeArea()
}
#endif
