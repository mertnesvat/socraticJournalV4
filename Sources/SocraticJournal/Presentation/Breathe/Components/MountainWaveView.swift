// MountainWaveView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Mountain/triangle wave animation that draws the breathing rhythm as a seismograph line
/// Inhale: line rises from baseline to peak
/// Hold: line stays flat at peak
/// Exhale: line descends from peak to baseline
public struct MountainWaveView: View {
    let engine: BreathSessionEngine
    let reduceMotion: Bool

    @State private var wavePoints: [CGPoint] = []
    @State private var drawingPointGlow: Double = 1.0

    private let baselineY: CGFloat = 0.8  // 80% from top (near bottom)
    private let peakY: CGFloat = 0.2       // 20% from top (near top)
    private let maxPoints: Int = 300

    public init(engine: BreathSessionEngine, reduceMotion: Bool = false) {
        self.engine = engine
        self.reduceMotion = reduceMotion
    }

    public var body: some View {
        if reduceMotion {
            reducedMotionView
        } else {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    drawWave(context: context, size: size)
                }
                .onChange(of: timeline.date) { _, _ in
                    updateWavePoints()
                }
            }
        }
    }

    // MARK: - Reduced Motion

    private var reducedMotionView: some View {
        VStack(spacing: AppSpacing.lg) {
            // Simple phase indicator circle
            Circle()
                .fill(engine.currentPhase.color.opacity(0.3))
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .trim(from: 0, to: engine.phaseProgress)
                        .stroke(engine.currentPhase.color, lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                )
        }
    }

    // MARK: - Wave Drawing

    private func drawWave(context: GraphicsContext, size: CGSize) {
        guard wavePoints.count > 1 else { return }

        // Scale points to actual canvas size
        let scaledPoints = wavePoints.map { point in
            CGPoint(x: point.x * size.width, y: point.y * size.height)
        }

        // Draw the wave path
        var path = Path()
        path.move(to: scaledPoints[0])

        for i in 1..<scaledPoints.count {
            let prev = scaledPoints[i - 1]
            let curr = scaledPoints[i]
            // Use quadratic curves for soft, rounded transitions
            let midX = (prev.x + curr.x) / 2
            let midY = (prev.y + curr.y) / 2
            path.addQuadCurve(to: CGPoint(x: midX, y: midY), control: prev)
            if i == scaledPoints.count - 1 {
                path.addLine(to: curr)
            }
        }

        // Stroke the path with teal accent
        context.stroke(
            path,
            with: .color(AppColors.accent),
            lineWidth: 2.5
        )

        // Glow effect on the drawing point (last point)
        if let lastPoint = scaledPoints.last {
            let glowRadius: CGFloat = 8
            let glowColor = engine.currentPhase.color

            // Outer glow
            context.fill(
                Path(ellipseIn: CGRect(
                    x: lastPoint.x - glowRadius,
                    y: lastPoint.y - glowRadius,
                    width: glowRadius * 2,
                    height: glowRadius * 2
                )),
                with: .color(glowColor.opacity(0.3))
            )

            // Inner bright dot
            context.fill(
                Path(ellipseIn: CGRect(
                    x: lastPoint.x - 3,
                    y: lastPoint.y - 3,
                    width: 6,
                    height: 6
                )),
                with: .color(glowColor)
            )
        }
    }

    // MARK: - Point Generation

    private func updateWavePoints() {
        guard engine.state == .active else { return }

        // Calculate the Y position based on current phase and progress
        let yNormalized = calculateYPosition()

        // X position: advance steadily across the screen
        let xStep: CGFloat = 1.0 / CGFloat(maxPoints)
        let nextX: CGFloat
        if let lastPoint = wavePoints.last {
            nextX = lastPoint.x + xStep
        } else {
            nextX = 0
        }

        let newPoint = CGPoint(x: nextX, y: yNormalized)
        wavePoints.append(newPoint)

        // When we exceed the screen, shift all points left (scrolling wave)
        if nextX > 1.0 {
            let shiftAmount = xStep
            wavePoints = wavePoints.map { CGPoint(x: $0.x - shiftAmount, y: $0.y) }
            // Remove points that scrolled off screen
            wavePoints.removeAll { $0.x < -0.05 }
        }

        // Cap total points for performance
        if wavePoints.count > maxPoints * 2 {
            wavePoints = Array(wavePoints.suffix(maxPoints))
        }
    }

    private func calculateYPosition() -> CGFloat {
        let progress = engine.phaseProgress

        switch engine.currentPhase {
        case .inhale:
            // Rise from baseline to peak
            let eased = easeInOut(progress)
            return baselineY + (peakY - baselineY) * eased
        case .holdIn:
            // Stay at peak
            return peakY
        case .exhale:
            // Descend from peak to baseline
            let eased = easeInOut(progress)
            return peakY + (baselineY - peakY) * eased
        case .holdOut:
            // Stay at baseline
            return baselineY
        }
    }

    private func easeInOut(_ t: Double) -> CGFloat {
        // Smooth ease in-out for natural motion
        CGFloat(t * t * (3 - 2 * t))
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        MountainWaveView(engine: BreathSessionEngine())
            .frame(height: 200)
            .padding()
    }
}
#endif
