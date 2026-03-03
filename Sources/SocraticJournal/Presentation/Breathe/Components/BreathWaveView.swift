// BreathWaveView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Mountain wave breath animation using Canvas
/// Draws a rising/falling mountain shape that traces the breath cycle
public struct BreathWaveView: View {
    let phase: BreathPhaseType
    let progress: Double
    let phaseColorHex: String

    private let waveHeight: CGFloat = 120

    public var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let pad: CGFloat = 24
            let peakX = w / 2
            let peakY: CGFloat = 16
            let baseY = h - 16

            // Ghost mountain (dashed outline)
            var ghostPath = Path()
            ghostPath.move(to: CGPoint(x: pad, y: baseY))
            ghostPath.addQuadCurve(
                to: CGPoint(x: peakX, y: peakY),
                control: CGPoint(x: (pad + peakX) / 2, y: baseY - 20)
            )
            ghostPath.addQuadCurve(
                to: CGPoint(x: w - pad, y: baseY),
                control: CGPoint(x: (peakX + w - pad) / 2, y: baseY - 20)
            )
            context.stroke(
                ghostPath,
                with: .color(AppColors.border),
                style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
            )

            // Baseline
            var baseLine = Path()
            baseLine.move(to: CGPoint(x: pad, y: baseY))
            baseLine.addLine(to: CGPoint(x: w - pad, y: baseY))
            context.stroke(baseLine, with: .color(AppColors.border), lineWidth: 1)

            // Live path based on phase
            let strokeColor = Color(hex: phaseColorHex)
            var livePath = Path()

            switch phase {
            case .inhale, .inhaleTopUp:
                // Rising left slope
                let midX = pad + (peakX - pad) * progress
                let midY = baseY - (baseY - peakY) * progress
                livePath.move(to: CGPoint(x: pad, y: baseY))
                livePath.addQuadCurve(
                    to: CGPoint(x: midX, y: midY),
                    control: CGPoint(x: (pad + midX) / 2, y: baseY - (baseY - midY) * 0.3)
                )

            case .hold:
                // Full left slope + flat at peak
                livePath.move(to: CGPoint(x: pad, y: baseY))
                livePath.addQuadCurve(
                    to: CGPoint(x: peakX, y: peakY),
                    control: CGPoint(x: (pad + peakX) / 2, y: baseY - 20)
                )
                // Small extension at peak
                let holdExtent = min(progress * 0.15, 0.15)
                let holdX = peakX + (w - pad - peakX) * holdExtent
                livePath.addLine(to: CGPoint(x: holdX, y: peakY))

                // Peak dot
                let dotRect = CGRect(x: peakX - 5, y: peakY - 5, width: 10, height: 10)
                context.fill(Path(ellipseIn: dotRect), with: .color(strokeColor.opacity(0.8)))

            case .exhale:
                // Full left slope + descending right slope
                livePath.move(to: CGPoint(x: pad, y: baseY))
                livePath.addQuadCurve(
                    to: CGPoint(x: peakX, y: peakY),
                    control: CGPoint(x: (pad + peakX) / 2, y: baseY - 20)
                )
                let endX = peakX + (w - pad - peakX) * progress
                let endY = peakY + (baseY - peakY) * progress
                livePath.addQuadCurve(
                    to: CGPoint(x: endX, y: endY),
                    control: CGPoint(x: (peakX + endX) / 2, y: (peakY + endY) / 2)
                )
            }

            context.stroke(
                livePath,
                with: .color(strokeColor),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
        }
        .frame(height: waveHeight)
    }
}

#Preview {
    VStack(spacing: 30) {
        BreathWaveView(phase: .inhale, progress: 0.6, phaseColorHex: "2D5F5D")
        BreathWaveView(phase: .hold, progress: 0.5, phaseColorHex: "5A8A6A")
        BreathWaveView(phase: .exhale, progress: 0.7, phaseColorHex: "C4502A")
    }
    .padding()
    .background(AppColors.background)
}
#endif
