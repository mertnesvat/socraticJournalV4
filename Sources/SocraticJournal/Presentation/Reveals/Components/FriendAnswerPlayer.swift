// FriendAnswerPlayer.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compact inline audio player shown inside an expanded FriendAnswerCard when playing
public struct FriendAnswerPlayer: View {
    let answer: VoiceAnswer?
    let isPlaying: Bool
    let onPlayPause: () -> Void

    /// Mock progress for visual display (in production this would come from the VoiceRecordingService)
    @State private var simulatedProgress: Double = 0
    @State private var progressTimer: Timer?

    /// Duration of the recording
    private var duration: TimeInterval {
        answer?.duration ?? 30
    }

    /// Format time as m:ss
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Estimated current time based on simulated progress
    private var currentTime: TimeInterval {
        simulatedProgress * duration
    }

    /// Generate mock amplitudes for the waveform display
    private var mockAmplitudes: [Float] {
        let count = 20
        return (0..<count).map { i in
            let base = Float(i % 5 + 2) / 8.0
            let variation = sin(Float(i) * 0.8) * 0.2
            return min(1.0, max(0.1, base + variation))
        }
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Waveform with progress
            HStack(spacing: 12) {
                // Play/Pause button
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.callout)
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.blue.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)

                // Compact waveform
                AudioWaveformView(
                    amplitudes: mockAmplitudes,
                    progress: simulatedProgress,
                    accentColor: .blue,
                    barCount: 20
                )
                .frame(height: 28)

                // Duration text
                Text(formatTime(currentTime))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(width: 36, alignment: .trailing)
            }

            // Thin progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 2)

                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * simulatedProgress, height: 2)
                }
            }
            .frame(height: 2)
        }
        .onChange(of: isPlaying) { _, playing in
            if playing {
                startProgressSimulation()
            } else {
                stopProgressSimulation()
            }
        }
        .onAppear {
            if isPlaying {
                startProgressSimulation()
            }
        }
        .onDisappear {
            stopProgressSimulation()
        }
    }

    // MARK: - Progress Simulation

    /// Simulates playback progress for visual feedback in development
    private func startProgressSimulation() {
        simulatedProgress = 0
        let interval = 0.1
        let increment = interval / max(duration, 1)

        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            Task { @MainActor in
                simulatedProgress += increment
                if simulatedProgress >= 1.0 {
                    simulatedProgress = 1.0
                    timer.invalidate()
                }
            }
        }
    }

    private func stopProgressSimulation() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

// MARK: - Preview

#Preview("Playing") {
    FriendAnswerPlayer(
        answer: MockDataProvider.voiceAnswers[3],
        isPlaying: true,
        onPlayPause: {}
    )
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .background(Color.black)
}

#Preview("Paused") {
    FriendAnswerPlayer(
        answer: MockDataProvider.voiceAnswers[3],
        isPlaying: false,
        onPlayPause: {}
    )
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .background(Color.black)
}

#endif
