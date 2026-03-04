// MountainWaveView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct MountainWaveView: View {
    let phase: BreathPhaseType
    let progress: Double
    let isDemo: Bool

    init(phase: BreathPhaseType, progress: Double, isDemo: Bool = false) {
        self.phase = phase
        self.progress = progress
        self.isDemo = isDemo
    }

    private let width: CGFloat = 280
    private let height: CGFloat = 120
    private let pad: CGFloat = 30

    private var peakX: CGFloat { width / 2 }
    private var peakY: CGFloat { 18 }
    private var baseY: CGFloat { height - 16 }

    private var strokeColor: Color {
        switch phase {
        case .inhale: return isDemo ? AppColors.accent.opacity(0.5) : AppColors.phaseInhale
        case .hold: return isDemo ? AppColors.phaseHold.opacity(0.5) : AppColors.phaseHold
        case .exhale: return isDemo ? AppColors.accent2.opacity(0.5) : AppColors.phaseExhale
        }
    }

    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / width
            let scaleY = size.height / height

            // Baseline
            var baseline = Path()
            baseline.move(to: CGPoint(x: pad * scaleX, y: baseY * scaleY))
            baseline.addLine(to: CGPoint(x: (width - pad) * scaleX, y: baseY * scaleY))
            context.stroke(baseline, with: .color(AppColors.border), lineWidth: 1)

            // Ghost mountain
            var ghost = Path()
            ghost.move(to: CGPoint(x: pad * scaleX, y: baseY * scaleY))
            ghost.addQuadCurve(
                to: CGPoint(x: peakX * scaleX, y: peakY * scaleY),
                control: CGPoint(x: ((pad + peakX) / 2) * scaleX, y: (baseY - 20) * scaleY)
            )
            ghost.addQuadCurve(
                to: CGPoint(x: (width - pad) * scaleX, y: baseY * scaleY),
                control: CGPoint(x: ((peakX + width - pad) / 2) * scaleX, y: (baseY - 20) * scaleY)
            )
            context.stroke(ghost, with: .color(AppColors.border), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

            // Live path
            let livePath = buildLivePath(scaleX: scaleX, scaleY: scaleY)
            context.stroke(livePath, with: .color(strokeColor), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

            // Peak dot for hold
            if phase == .hold {
                let dotRect = CGRect(
                    x: peakX * scaleX - 5,
                    y: peakY * scaleY - 5,
                    width: 10, height: 10
                )
                context.fill(Circle().path(in: dotRect), with: .color(strokeColor.opacity(0.8)))
            }
        }
        .frame(width: width, height: height)
        .animation(.easeInOut(duration: 0.4), value: phase)
    }

    private func buildLivePath(scaleX: CGFloat, scaleY: CGFloat) -> Path {
        var path = Path()

        switch phase {
        case .inhale:
            let midX = pad + (peakX - pad) * progress
            let midY = baseY - (baseY - peakY) * progress
            path.move(to: CGPoint(x: pad * scaleX, y: baseY * scaleY))
            path.addQuadCurve(
                to: CGPoint(x: midX * scaleX, y: midY * scaleY),
                control: CGPoint(x: ((pad + midX) / 2) * scaleX, y: baseY * scaleY)
            )

        case .hold:
            path.move(to: CGPoint(x: pad * scaleX, y: baseY * scaleY))
            path.addQuadCurve(
                to: CGPoint(x: peakX * scaleX, y: peakY * scaleY),
                control: CGPoint(x: ((pad + peakX) / 2) * scaleX, y: baseY * scaleY)
            )
            let extendX = peakX + (width - pad - peakX) * min(progress * 0.15, 0.15)
            path.addLine(to: CGPoint(x: extendX * scaleX, y: peakY * scaleY))

        case .exhale:
            path.move(to: CGPoint(x: pad * scaleX, y: baseY * scaleY))
            path.addQuadCurve(
                to: CGPoint(x: peakX * scaleX, y: peakY * scaleY),
                control: CGPoint(x: ((pad + peakX) / 2) * scaleX, y: baseY * scaleY)
            )
            let endX = peakX + (width - pad - peakX) * progress
            let endY = peakY + (baseY - peakY) * progress
            path.addQuadCurve(
                to: CGPoint(x: endX * scaleX, y: endY * scaleY),
                control: CGPoint(x: ((peakX + endX) / 2) * scaleX, y: ((peakY + endY) / 2) * scaleY)
            )
        }

        return path
    }
}
#endif
