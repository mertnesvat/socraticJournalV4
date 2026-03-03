// MountainWaveView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The centrepiece mountain wave animation driven by the breath pacing engine.
///
/// The wave traces a continuous mountain landscape from left to right:
/// - Inhale draws the left slope upward
/// - Hold at peak keeps a flat ridge
/// - Exhale draws the right slope downward
/// - Hold at base keeps a flat valley
///
/// Previous mountains fade to create a sense of journey through the session.
struct MountainWaveView: View {
    let breathPosition: Double
    let phaseType: BreathPhaseType
    let phaseProgress: Double
    let cyclesCompleted: Int

    /// Width allocated per full breath cycle in the coordinate space
    private let cycleWidth: CGFloat = 200
    /// Vertical amplitude from baseline to peak
    private let amplitude: CGFloat = 0.35
    /// Baseline Y position (fraction of height, from top)
    private let baselineY: CGFloat = 0.65

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let baseline = height * baselineY
            let peakY = height * (baselineY - amplitude)

            // Calculate the total horizontal progress through the wave
            let totalProgress = computeTotalProgress()

            // Draw the continuous mountain path
            let path = buildMountainPath(
                totalProgress: totalProgress,
                width: width,
                baseline: baseline,
                peakY: peakY
            )

            // Glow layer
            context.addFilter(.shadow(color: .white.opacity(0.3), radius: 8))

            // Main stroke
            context.stroke(
                path,
                with: .color(.white.opacity(0.8)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
    }

    /// Compute a continuously increasing progress value.
    /// Each cycle contributes 1.0, and within a cycle we compute fractional progress
    /// based on which phase we are in and how far through it.
    private func computeTotalProgress() -> Double {
        // Figure out how far we are in the current cycle as a fraction of 0-1.
        // The phases map to segments of the cycle:
        // For a technique like resonance (inhale + exhale only, no holds):
        //   inhale = first half (0.0 - 0.5)
        //   exhale = second half (0.5 - 1.0)
        // For box breathing (inhale + hold + exhale + hold):
        //   inhale = 0.0 - 0.25
        //   holdAfterInhale = 0.25 - 0.5
        //   exhale = 0.5 - 0.75
        //   holdAfterExhale = 0.75 - 1.0
        //
        // We simplify by mapping phase type to wave segments:
        let cycleProgress: Double
        switch phaseType {
        case .inhale:
            // Rising from baseline to peak
            cycleProgress = phaseProgress * 0.35
        case .holdAfterInhale:
            // Flat at peak
            cycleProgress = 0.35 + phaseProgress * 0.15
        case .exhale:
            // Falling from peak to baseline
            cycleProgress = 0.5 + phaseProgress * 0.35
        case .holdAfterExhale:
            // Flat at baseline
            cycleProgress = 0.85 + phaseProgress * 0.15
        }

        return Double(cyclesCompleted) + cycleProgress
    }

    /// Build a continuous path of mountain peaks representing the breathing journey.
    private func buildMountainPath(
        totalProgress: Double,
        width: CGFloat,
        baseline: CGFloat,
        peakY: CGFloat
    ) -> Path {
        var path = Path()

        // The drawing cursor moves from right to left (most recent on right)
        // We draw from the oldest visible point to the current point
        let pointsPerCycle: Int = 100
        let totalPoints = Int(totalProgress * Double(pointsPerCycle))

        guard totalPoints > 0 else {
            // Just a dot at the start
            path.move(to: CGPoint(x: width * 0.5, y: baseline))
            return path
        }

        // Current drawing position is at the right side of center
        let currentX = width * 0.75

        // How many points to show (limit to visible width)
        let maxVisiblePoints = Int(Double(pointsPerCycle) * 4.0) // Show ~4 cycles max
        let startPoint = max(0, totalPoints - maxVisiblePoints)
        let pixelsPerPoint = cycleWidth / CGFloat(pointsPerCycle)

        var isFirst = true

        for i in startPoint...totalPoints {
            let t = Double(i) / Double(pointsPerCycle)
            let cycleFraction = t.truncatingRemainder(dividingBy: 1.0)

            // Compute Y based on cycle fraction
            let y = mountainY(cycleFraction: cycleFraction, baseline: baseline, peakY: peakY)

            // Compute X: current point is at currentX, older points are to the left
            let pointOffset = CGFloat(totalPoints - i) * pixelsPerPoint
            let x = currentX - pointOffset

            // Skip points that are off-screen to the left
            guard x >= -20 else { continue }

            if isFirst {
                path.move(to: CGPoint(x: x, y: y))
                isFirst = false
            } else {
                // Use line segments for smooth rendering at high density
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    /// Convert a cycle fraction (0-1) to a Y coordinate forming a mountain shape.
    private func mountainY(cycleFraction: Double, baseline: CGFloat, peakY: CGFloat) -> CGFloat {
        // Mountain shape using smooth sine curve:
        // 0.0 - 0.35: rise (inhale)
        // 0.35 - 0.5: peak plateau (hold after inhale)
        // 0.5 - 0.85: descent (exhale)
        // 0.85 - 1.0: baseline plateau (hold after exhale)

        let height: Double
        if cycleFraction < 0.35 {
            // Rising slope: ease-in-out from 0 to 1
            let t = cycleFraction / 0.35
            height = easeInOut(t)
        } else if cycleFraction < 0.5 {
            // Peak plateau
            height = 1.0
        } else if cycleFraction < 0.85 {
            // Falling slope: ease-in-out from 1 to 0
            let t = (cycleFraction - 0.5) / 0.35
            height = 1.0 - easeInOut(t)
        } else {
            // Baseline plateau
            height = 0.0
        }

        // Interpolate between baseline and peak
        return baseline - CGFloat(height) * (baseline - peakY)
    }

    /// Sinusoidal ease-in-out matching the engine's curve
    private func easeInOut(_ t: Double) -> Double {
        (1.0 - cos(t * .pi)) / 2.0
    }
}

#Preview("Mountain Wave - Inhale") {
    ZStack {
        Color(hex: "0B1426").ignoresSafeArea()
        MountainWaveView(
            breathPosition: 0.5,
            phaseType: .inhale,
            phaseProgress: 0.5,
            cyclesCompleted: 2
        )
    }
}

#Preview("Mountain Wave - Peak") {
    ZStack {
        Color(hex: "0B1426").ignoresSafeArea()
        MountainWaveView(
            breathPosition: 1.0,
            phaseType: .holdAfterInhale,
            phaseProgress: 0.5,
            cyclesCompleted: 3
        )
    }
}
#endif
