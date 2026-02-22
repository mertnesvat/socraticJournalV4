// RecordingPreview.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Post-recording preview showing playback controls with re-record and submit actions
/// Displays the recorded waveform, duration, and action buttons
public struct RecordingPreview: View {
    /// Stored amplitude samples from the recording
    let amplitudes: [Float]

    /// Duration of the recording in seconds
    let duration: TimeInterval

    /// Current playback time for progress display
    let currentTime: TimeInterval

    /// Whether audio is currently playing
    let isPlaying: Bool

    /// Called when play/pause is tapped
    let onPlayPause: () -> Void

    /// Called when the user wants to re-record
    let onReRecord: () -> Void

    /// Called when the user submits the recording
    let onSubmit: () -> Void

    /// Whether submission is in progress
    var isSubmitting: Bool = false

    /// Controls the submit button scale animation
    @State private var submitScale: CGFloat = 1.0

    public init(
        amplitudes: [Float],
        duration: TimeInterval,
        currentTime: TimeInterval,
        isPlaying: Bool,
        onPlayPause: @escaping () -> Void,
        onReRecord: @escaping () -> Void,
        onSubmit: @escaping () -> Void,
        isSubmitting: Bool = false
    ) {
        self.amplitudes = amplitudes
        self.duration = duration
        self.currentTime = currentTime
        self.isPlaying = isPlaying
        self.onPlayPause = onPlayPause
        self.onReRecord = onReRecord
        self.onSubmit = onSubmit
        self.isSubmitting = isSubmitting
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Playback waveform with play/pause
            playbackSection

            // Duration label
            Text(formattedDuration)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color.white.opacity(0.5))

            // Action buttons
            actionButtons
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Playback Section

    private var playbackSection: some View {
        PlaybackView(
            amplitudes: amplitudes,
            duration: duration,
            currentTime: currentTime,
            isPlaying: isPlaying,
            onPlayPause: onPlayPause,
            onSeek: { _ in },
            accentColor: Color(red: 0.4, green: 0.6, blue: 1.0)
        )
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Re-record button (outline style)
            Button(action: onReRecord) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Re-record")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
            .opacity(isSubmitting ? 0.4 : 1.0)

            // Submit button (filled accent)
            Button {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    submitScale = 0.92
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        submitScale = 1.0
                    }
                }
                onSubmit()
            } label: {
                HStack(spacing: 8) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(isSubmitting ? "Sending..." : "Submit")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(submitGradient)
                )
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .scaleEffect(submitScale)
            .disabled(isSubmitting)
        }
    }

    // MARK: - Helpers

    private var submitGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.5, blue: 1.0),
                Color(red: 0.5, green: 0.3, blue: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var formattedDuration: String {
        let totalSeconds = Int(max(0, duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d recording", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Preview State") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingPreview(
            amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3],
            duration: 12.5,
            currentTime: 0,
            isPlaying: false,
            onPlayPause: {},
            onReRecord: {},
            onSubmit: {}
        )
    }
}

#Preview("Submitting") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingPreview(
            amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3],
            duration: 12.5,
            currentTime: 0,
            isPlaying: false,
            onPlayPause: {},
            onReRecord: {},
            onSubmit: {},
            isSubmitting: true
        )
    }
}

#endif
