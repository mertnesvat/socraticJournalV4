// ShareCardWaveform.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A static decorative waveform for share card images.
/// Renders a horizontal row of bars based on amplitude data.
/// This is non-animated and optimized for image rendering via ImageRenderer.
public struct ShareCardWaveform: View {
    /// Amplitude values in the range 0...1
    let amplitudes: [Float]

    /// Number of bars to display
    var barCount: Int = 25

    /// Bar color (typically white for share cards)
    var barColor: Color = .white

    /// Maximum bar height in points
    private let maxBarHeight: CGFloat = 48

    /// Minimum bar height in points
    private let minBarHeight: CGFloat = 6

    /// Width of each bar in points
    private let barWidth: CGFloat = 8

    /// Spacing between bars in points
    private let barSpacing: CGFloat = 4

    public init(
        amplitudes: [Float],
        barCount: Int = 25,
        barColor: Color = .white
    ) {
        self.amplitudes = amplitudes
        self.barCount = barCount
        self.barColor = barColor
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
        let opacity = 0.4 + Double(amplitude) * 0.6

        RoundedRectangle(cornerRadius: barWidth / 2)
            .fill(barColor.opacity(opacity))
            .frame(width: barWidth, height: height)
    }

    // MARK: - Amplitude Calculation

    /// Maps amplitudes to bar indices via interpolation.
    /// Falls back to a decorative pattern if no data is available.
    private func amplitudeForBar(at index: Int) -> Float {
        guard !amplitudes.isEmpty else {
            // Generate a decorative wave pattern when no real data
            let normalized = Float(index) / Float(max(barCount - 1, 1))
            let wave = sin(normalized * .pi * 2.5) * 0.3 + 0.35
            let variation = cos(normalized * .pi * 4.0) * 0.15
            return max(0.1, min(1.0, wave + variation))
        }

        // Interpolate between available amplitude samples
        let floatIndex = Float(index) / Float(max(barCount - 1, 1)) * Float(amplitudes.count - 1)
        let lowerIndex = Int(floatIndex)
        let upperIndex = min(lowerIndex + 1, amplitudes.count - 1)
        let fraction = floatIndex - Float(lowerIndex)

        let value = amplitudes[lowerIndex] * (1 - fraction) + amplitudes[upperIndex] * fraction
        return max(0.05, min(1.0, value))
    }
}

// MARK: - Preview

#Preview("With Data") {
    ZStack {
        Color.black.ignoresSafeArea()

        ShareCardWaveform(
            amplitudes: [0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.8, 0.3, 0.6, 0.4],
            barCount: 25,
            barColor: .white
        )
        .padding()
    }
}

#Preview("Decorative Pattern") {
    ZStack {
        Color.black.ignoresSafeArea()

        ShareCardWaveform(
            amplitudes: [],
            barCount: 25,
            barColor: .white
        )
        .padding()
    }
}
#endif
