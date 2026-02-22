// AudioWaveformView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Bold geometric waveform with thick coral-red bars.
/// Fewer bars (20) for a bolder look, 4pt width for visual weight.
public struct AudioWaveformView: View {
    /// Array of amplitude values in the range 0...1
    let amplitudes: [Float]

    /// Playback progress from 0 to 1 (used in static/playback mode)
    var progress: Double = 0

    /// Whether the waveform should animate (live recording mode)
    var isAnimating: Bool = false

    /// Accent color for the waveform bars
    var accentColor: Color = AppColors.accent

    /// Number of bars to display
    var barCount: Int = 20

    /// Minimum bar height in points
    private let minBarHeight: CGFloat = 4

    /// Maximum bar height in points
    private let maxBarHeight: CGFloat = 40

    /// Width of each bar in points
    private let barWidth: CGFloat = 4

    /// Spacing between bars in points
    private let barSpacing: CGFloat = 3

    public init(
        amplitudes: [Float],
        progress: Double = 0,
        isAnimating: Bool = false,
        accentColor: Color = AppColors.accent,
        barCount: Int = 20
    ) {
        self.amplitudes = amplitudes
        self.progress = progress
        self.isAnimating = isAnimating
        self.accentColor = accentColor
        self.barCount = barCount
    }

    public var body: some View {
        HStack(alignment: .center, spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                barView(at: index)
            }
        }
        .frame(height: maxBarHeight)
    }

    // MARK: - Bar View

    @ViewBuilder
    private func barView(at index: Int) -> some View {
        let amplitude = amplitudeForBar(at: index)
        let height = minBarHeight + CGFloat(amplitude) * (maxBarHeight - minBarHeight)
        let barProgress = Double(index) / Double(max(barCount - 1, 1))
        let isPlayed = barProgress <= progress

        RoundedRectangle(cornerRadius: 2)
            .fill(barColor(isPlayed: isPlayed))
            .frame(width: barWidth, height: height)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: amplitude
            )
    }

    // MARK: - Amplitude Calculation

    /// Maps the amplitude array to the bar at the given index.
    /// When the array has fewer elements than barCount, interpolates between available samples.
    /// When the array is empty, returns a small random baseline for visual interest.
    private func amplitudeForBar(at index: Int) -> Float {
        guard !amplitudes.isEmpty else {
            // Show a subtle baseline pattern when no data is available
            return Float(index % 3 == 0 ? 0.08 : 0.04)
        }

        if amplitudes.count == 1 {
            // Single amplitude value (live mode): distribute with variation
            let base = amplitudes[0]
            let variation = sin(Float(index) * 0.5) * 0.3
            return max(0, min(1, base + variation * base))
        }

        // Map bar index to amplitude array index via interpolation
        let floatIndex = Float(index) / Float(max(barCount - 1, 1)) * Float(amplitudes.count - 1)
        let lowerIndex = Int(floatIndex)
        let upperIndex = min(lowerIndex + 1, amplitudes.count - 1)
        let fraction = floatIndex - Float(lowerIndex)

        return amplitudes[lowerIndex] * (1 - fraction) + amplitudes[upperIndex] * fraction
    }

    // MARK: - Bar Color

    /// Returns the bar color based on whether it represents played or unplayed audio.
    private func barColor(isPlayed: Bool) -> Color {
        if progress > 0 {
            // Playback mode: highlight played portion
            return isPlayed ? accentColor : accentColor.opacity(0.3)
        }
        // Recording/idle mode: uniform color
        return accentColor
    }
}

// MARK: - Preview

#Preview("Live Recording") {
    AudioWaveformView(
        amplitudes: [0.6],
        isAnimating: true,
        accentColor: AppColors.accent,
        barCount: 20
    )
    .padding()
    .background(AppColors.backgroundDark)
}

#Preview("Playback Progress") {
    AudioWaveformView(
        amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3],
        progress: 0.4,
        accentColor: AppColors.accent,
        barCount: 20
    )
    .padding()
    .background(AppColors.backgroundDark)
}

#Preview("Empty State") {
    AudioWaveformView(
        amplitudes: [],
        accentColor: AppColors.textOnDark.opacity(0.15),
        barCount: 20
    )
    .padding()
    .background(AppColors.backgroundDark)
}

#endif
