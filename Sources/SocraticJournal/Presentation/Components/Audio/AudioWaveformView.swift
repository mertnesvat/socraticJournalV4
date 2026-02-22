// AudioWaveformView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The mode in which the waveform is displayed
public enum WaveformMode: Sendable {
    /// Bars animate responding to live audio level input during recording
    case recording
    /// Bars animate responding to audio output levels during playback
    case playback
    /// Gentle ambient pulsing animation when no audio activity
    case idle
    /// Fixed waveform rendered from a pre-computed levels array
    case staticWaveform
}

/// A signature waveform visualization component that displays audio levels as animated bars
/// Bars grow from center outward (mirrored top/bottom) and adapt to their container size
/// Supports multiple display modes: recording, playback, idle animation, and static display
public struct AudioWaveformView: View {
    // MARK: - Properties

    /// Current audio level (0.0 to 1.0) used in recording and playback modes
    public let audioLevel: Float

    /// Pre-computed audio levels for static waveform display
    public let levels: [Float]

    /// The display mode controlling animation behavior
    public let mode: WaveformMode

    /// Number of bars in the waveform (default: 40)
    public let barCount: Int

    /// Color for inactive/base bars
    public let barColor: Color

    /// Color for active/highlighted bars
    public let activeColor: Color

    /// Spacing between bars in points (default: 2)
    public let barSpacing: CGFloat

    /// Corner radius of each bar (default: 2)
    public let cornerRadius: CGFloat

    /// Progress through the audio (0.0 to 1.0) used to highlight played portion
    public let progress: Double

    // MARK: - Private State

    @State private var barLevels: [Float] = []
    @State private var idlePhase: CGFloat = 0

    // MARK: - Initialization

    public init(
        audioLevel: Float = 0,
        levels: [Float] = [],
        mode: WaveformMode = .idle,
        barCount: Int = 40,
        barColor: Color = .secondary.opacity(0.3),
        activeColor: Color = .accentColor,
        barSpacing: CGFloat = 2,
        cornerRadius: CGFloat = 2,
        progress: Double = 0
    ) {
        self.audioLevel = audioLevel
        self.levels = levels
        self.mode = mode
        self.barCount = barCount
        self.barColor = barColor
        self.activeColor = activeColor
        self.barSpacing = barSpacing
        self.cornerRadius = cornerRadius
        self.progress = progress
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    barView(
                        index: index,
                        totalWidth: geometry.size.width,
                        totalHeight: geometry.size.height
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            initializeBarLevels()
            if mode == .idle {
                startIdleAnimation()
            }
        }
        .onChange(of: audioLevel) { _, newValue in
            updateBarLevels(with: newValue)
        }
        .onChange(of: mode) { _, newMode in
            if newMode == .idle {
                startIdleAnimation()
            }
        }
    }

    // MARK: - Bar View

    @ViewBuilder
    private func barView(index: Int, totalWidth: CGFloat, totalHeight: CGFloat) -> some View {
        let barWidth = max(1, (totalWidth - barSpacing * CGFloat(barCount - 1)) / CGFloat(barCount))
        let level = barLevelForIndex(index)
        let minHeight: CGFloat = 3
        let barHeight = max(minHeight, totalHeight * CGFloat(level))
        let isActive = Double(index) / Double(barCount) <= progress

        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(isActive && mode == .playback ? activeColor : barColor)
            .frame(width: barWidth, height: barHeight)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: level)
    }

    // MARK: - Level Calculation

    private func barLevelForIndex(_ index: Int) -> Float {
        switch mode {
        case .recording, .playback:
            if index < barLevels.count {
                return barLevels[index]
            }
            return 0.05

        case .idle:
            // Generate a gentle wave pattern based on index and phase
            let normalizedIndex = Float(index) / Float(barCount)
            let wave = sin(Float(idlePhase) + normalizedIndex * .pi * 2)
            let secondWave = sin(Float(idlePhase) * 0.7 + normalizedIndex * .pi * 3)
            let combined = (wave + secondWave) / 4.0 + 0.5
            return max(0.05, min(0.4, combined * 0.35 + 0.05))

        case .staticWaveform:
            if levels.isEmpty { return 0.05 }
            let scaledIndex = Int(Float(index) / Float(barCount) * Float(levels.count))
            let clampedIndex = min(scaledIndex, levels.count - 1)
            return max(0.05, levels[clampedIndex])
        }
    }

    // MARK: - Private Helpers

    private func initializeBarLevels() {
        barLevels = Array(repeating: Float(0.05), count: barCount)
    }

    private func updateBarLevels(with level: Float) {
        guard mode == .recording || mode == .playback else { return }

        // Shift bars to the left and add new level on the right
        var newLevels = barLevels
        if newLevels.count >= barCount {
            newLevels.removeFirst()
        }
        // Add slight randomization around the level for natural appearance
        let jitter = Float.random(in: -0.05...0.05)
        let adjustedLevel = max(0.05, min(1.0, level + jitter))
        newLevels.append(adjustedLevel)

        withAnimation(.spring(response: 0.15, dampingFraction: 0.7)) {
            barLevels = newLevels
        }
    }

    private func startIdleAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            idlePhase = .pi * 2
        }
    }
}

// MARK: - Preview

#Preview("Recording Mode") {
    AudioWaveformView(
        audioLevel: 0.6,
        mode: .recording,
        barCount: 40,
        barColor: .blue.opacity(0.3),
        activeColor: .blue
    )
    .frame(height: 60)
    .padding()
}

#Preview("Idle Mode") {
    AudioWaveformView(
        mode: .idle,
        barCount: 40,
        barColor: .purple.opacity(0.3),
        activeColor: .purple
    )
    .frame(height: 60)
    .padding()
}

#Preview("Static Mode") {
    AudioWaveformView(
        levels: (0..<40).map { _ in Float.random(in: 0.1...0.9) },
        mode: .staticWaveform,
        barCount: 40,
        barColor: .green.opacity(0.3),
        activeColor: .green,
        progress: 0.6
    )
    .frame(height: 60)
    .padding()
}
#endif
