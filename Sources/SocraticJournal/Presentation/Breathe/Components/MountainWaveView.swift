// MountainWaveView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The signature mountain wave animation for breath pacing.
/// A triangle/mountain shape where the line rises during inhale,
/// holds flat at the peak, and descends during exhale.
struct MountainWaveView: View {
    let cycleProgress: Double
    let currentPhase: BreathPhaseType
    let phaseProgress: Double
    var color: Color = AppColors.cardTeal
    var isDemo: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Trail path (faded, shows the full mountain shape)
                MountainWaveShape(progress: 1.0, phases: buildPhaseLayout())
                    .stroke(color.opacity(0.15), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // Active path (draws as breath progresses)
                MountainWaveShape(progress: cycleProgress, phases: buildPhaseLayout())
                    .stroke(
                        color.opacity(isDemo ? 0.5 : 0.9),
                        style: StrokeStyle(lineWidth: isDemo ? 2 : 4, lineCap: .round, lineJoin: .round)
                    )

                // Glow dot at the current position
                if !isDemo {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .shadow(color: color.opacity(0.6), radius: 8)
                        .position(
                            dotPosition(
                                in: CGSize(width: width, height: height),
                                progress: cycleProgress
                            )
                        )
                }
            }
        }
    }

    // MARK: - Phase Layout

    /// Describes the normalized x-positions where each phase starts/ends
    private func buildPhaseLayout() -> [PhaseSegment] {
        // For a 2-phase inhale/exhale: rise from 0→0.5, descend from 0.5→1.0
        // For hold phases: flat segment at the top
        [PhaseSegment(startX: 0, endX: 0.5, type: .inhale),
         PhaseSegment(startX: 0.5, endX: 1.0, type: .exhale)]
    }

    private func dotPosition(in size: CGSize, progress: Double) -> CGPoint {
        let clampedProgress = min(max(progress, 0), 1)
        let x = clampedProgress * size.width
        let peakY = size.height * 0.15
        let baseY = size.height * 0.85

        let y: Double
        if clampedProgress <= 0.5 {
            // Ascending (inhale)
            let t = clampedProgress / 0.5
            let eased = easeInOut(t)
            y = baseY - (baseY - peakY) * eased
        } else {
            // Descending (exhale)
            let t = (clampedProgress - 0.5) / 0.5
            let eased = easeInOut(t)
            y = peakY + (baseY - peakY) * eased
        }

        return CGPoint(x: x, y: y)
    }

    private func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
}

/// Describes a segment of the mountain wave path
struct PhaseSegment {
    let startX: Double
    let endX: Double
    let type: BreathPhaseType
}

/// Custom Shape that draws the mountain wave path
struct MountainWaveShape: Shape {
    var progress: Double
    let phases: [PhaseSegment]

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let peakY = height * 0.15
        let baseY = height * 0.85

        let totalX = progress * width
        guard totalX > 0 else { return path }

        path.move(to: CGPoint(x: 0, y: baseY))

        // Draw with many small segments for smooth curves
        let steps = max(Int(totalX), 2)
        for i in 1...steps {
            let x = Double(i) / Double(steps) * totalX
            let normalizedX = x / width

            let y: Double
            if normalizedX <= 0.5 {
                let t = normalizedX / 0.5
                let eased = easeInOut(t)
                y = baseY - (baseY - peakY) * eased
            } else {
                let t = (normalizedX - 0.5) / 0.5
                let eased = easeInOut(t)
                y = peakY + (baseY - peakY) * eased
            }

            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }

    private func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
}
#endif
