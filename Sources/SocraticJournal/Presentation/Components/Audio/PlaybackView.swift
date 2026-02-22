// PlaybackView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Audio playback view showing a waveform with progress overlay, play/pause button,
/// and current time / total duration display.
public struct PlaybackView: View {
    /// Stored amplitude samples for waveform visualization
    let amplitudes: [Float]

    /// Total duration of the recording in seconds
    let duration: TimeInterval

    /// Current playback time in seconds
    let currentTime: TimeInterval

    /// Whether audio is currently playing
    let isPlaying: Bool

    /// Called when the play/pause button is tapped
    let onPlayPause: () -> Void

    /// Called with a progress value (0...1) when the user seeks
    let onSeek: (Double) -> Void

    /// Accent color for the waveform and controls
    var accentColor: Color = .blue

    /// Playback progress from 0 to 1
    private var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    public init(
        amplitudes: [Float],
        duration: TimeInterval,
        currentTime: TimeInterval,
        isPlaying: Bool,
        onPlayPause: @escaping () -> Void,
        onSeek: @escaping (Double) -> Void,
        accentColor: Color = .blue
    ) {
        self.amplitudes = amplitudes
        self.duration = duration
        self.currentTime = currentTime
        self.isPlaying = isPlaying
        self.onPlayPause = onPlayPause
        self.onSeek = onSeek
        self.accentColor = accentColor
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Waveform with progress
            HStack(spacing: 16) {
                // Play/Pause button
                playPauseButton

                // Waveform
                AudioWaveformView(
                    amplitudes: amplitudes,
                    progress: progress,
                    accentColor: accentColor,
                    barCount: 30
                )
            }

            // Progress bar and time labels
            VStack(spacing: 4) {
                // Seekable progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(accentColor.opacity(0.2))
                            .frame(height: 4)

                        // Filled progress
                        RoundedRectangle(cornerRadius: 2)
                            .fill(accentColor)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let seekProgress = min(max(value.location.x / geometry.size.width, 0), 1)
                                onSeek(seekProgress)
                            }
                    )
                }
                .frame(height: 4)

                // Time labels
                HStack {
                    Text(formatTime(currentTime))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    Spacer()

                    Text(formatTime(duration))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Play/Pause Button

    private var playPauseButton: some View {
        Button(action: onPlayPause) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.title2)
                .foregroundStyle(accentColor)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Time Formatting

    /// Formats a time interval as m:ss
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Playing") {
    PlaybackView(
        amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3, 0.6, 0.8],
        duration: 15.5,
        currentTime: 6.2,
        isPlaying: true,
        onPlayPause: {},
        onSeek: { _ in },
        accentColor: .blue
    )
    .padding()
    .background(Color.black)
}

#Preview("Paused") {
    PlaybackView(
        amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3, 0.6, 0.8],
        duration: 45.0,
        currentTime: 0,
        isPlaying: false,
        onPlayPause: {},
        onSeek: { _ in },
        accentColor: .blue
    )
    .padding()
    .background(Color.black)
}

#endif
