// WaveformView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Reusable waveform visualization component.
/// Displays animated bars representing audio amplitude data.
///
/// Supports two modes:
/// - **Live mode**: Animates with real-time amplitude updates during recording.
/// - **Static mode**: Displays a fixed waveform from recorded data.
public struct WaveformView: View {
    // MARK: - Configuration

    /// The amplitude data points (0.0 ... 1.0).
    let amplitudes: [Float]
    /// Whether this waveform is in live recording mode.
    let isLive: Bool
    /// The current live amplitude (used in live mode for the leading-edge bar).
    let liveAmplitude: Float
    /// Color for active (filled) bars.
    let activeColor: Color
    /// Color for inactive bars.
    let inactiveColor: Color
    /// Number of bars to display.
    let barCount: Int
    /// Spacing between bars.
    let barSpacing: CGFloat
    /// Optional playback progress (0.0 ... 1.0). When set, bars before the progress
    /// point use `activeColor` and bars after use `inactiveColor`. `nil` means no
    /// progress overlay (all bars use `activeColor` in static mode).
    let progress: CGFloat?

    // MARK: - Init

    public init(
        amplitudes: [Float],
        isLive: Bool = false,
        liveAmplitude: Float = 0.0,
        activeColor: Color = CircleTheme.waveformActive,
        inactiveColor: Color = CircleTheme.waveformInactive,
        barCount: Int = 40,
        barSpacing: CGFloat = 2.0,
        progress: CGFloat? = nil
    ) {
        self.amplitudes = amplitudes
        self.isLive = isLive
        self.liveAmplitude = liveAmplitude
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.barCount = barCount
        self.barSpacing = barSpacing
        self.progress = progress
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    barView(at: index, totalHeight: geometry.size.height)
                }
            }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private func barView(at index: Int, totalHeight: CGFloat) -> some View {
        let amplitude = amplitudeForBar(at: index)
        let minHeight: CGFloat = 3.0
        let barHeight = max(minHeight, CGFloat(amplitude) * totalHeight)

        RoundedRectangle(cornerRadius: 1.5)
            .fill(barColor(at: index))
            .frame(width: nil, height: barHeight)
            .frame(maxWidth: .infinity)
            .animation(
                isLive ? .easeOut(duration: 0.08) : .easeInOut(duration: 0.3),
                value: amplitude
            )
    }

    private func amplitudeForBar(at index: Int) -> Float {
        if isLive {
            return liveAmplitudeForBar(at: index)
        } else {
            return staticAmplitudeForBar(at: index)
        }
    }

    /// In live mode, show collected samples filling from left to right,
    /// with the rightmost bar reflecting the current live amplitude.
    private func liveAmplitudeForBar(at index: Int) -> Float {
        guard !amplitudes.isEmpty else {
            // No samples yet -- show the live amplitude on the first bar
            return index == 0 ? liveAmplitude : 0.05
        }

        let sampleCount = amplitudes.count
        let filledBars = min(sampleCount, barCount)

        if index < filledBars {
            // Map index to a sample in the amplitudes array
            let sampleIndex = (sampleCount * index) / filledBars
            return amplitudes[min(sampleIndex, sampleCount - 1)]
        } else if index == filledBars {
            // The leading edge shows current live amplitude
            return liveAmplitude
        } else {
            return 0.05
        }
    }

    /// In static mode, evenly distribute the amplitude array across all bars.
    private func staticAmplitudeForBar(at index: Int) -> Float {
        guard !amplitudes.isEmpty else { return 0.1 }
        let sampleIndex = (amplitudes.count * index) / barCount
        return amplitudes[min(sampleIndex, amplitudes.count - 1)]
    }

    private func barColor(at index: Int) -> Color {
        if isLive {
            let filledBars = min(amplitudes.count, barCount)
            return index <= filledBars ? activeColor : inactiveColor
        } else if let progress {
            // Progress overlay mode: bars before the progress point are active,
            // bars after are inactive.
            let progressBarIndex = Int(progress * CGFloat(barCount))
            return index < progressBarIndex ? activeColor : inactiveColor
        } else {
            return activeColor
        }
    }
}

// MARK: - Previews

#Preview("Static Waveform") {
    WaveformView(
        amplitudes: MockVoiceRecordingService.sampleWaveformData,
        isLive: false
    )
    .frame(height: 60)
    .padding()
}

#Preview("Live Waveform") {
    WaveformView(
        amplitudes: Array(MockVoiceRecordingService.sampleWaveformData.prefix(20)),
        isLive: true,
        liveAmplitude: 0.6
    )
    .frame(height: 60)
    .padding()
}

#Preview("Playback Progress") {
    WaveformView(
        amplitudes: MockVoiceRecordingService.sampleWaveformData,
        isLive: false,
        progress: 0.4
    )
    .frame(height: 60)
    .padding()
}
#endif
