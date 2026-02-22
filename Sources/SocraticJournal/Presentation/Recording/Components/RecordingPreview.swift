// RecordingPreview.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Post-recording preview with bold geometric styling.
/// Massive stat duration number, coral-red waveform, and simplified actions.
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

    /// Playback progress from 0 to 1
    private var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Massive duration stat
            Text(formattedDuration)
                .font(AppTypography.stat)
                .foregroundStyle(AppColors.textOnDark)

            // Waveform with play/pause overlay
            waveformSection

            // Action buttons
            actionButtons
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Waveform Section

    private var waveformSection: some View {
        HStack(spacing: 16) {
            // Play/Pause button
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
            .opacity(isSubmitting ? 0.4 : 1.0)

            // Coral-red waveform
            AudioWaveformView(
                amplitudes: amplitudes,
                progress: progress,
                accentColor: AppColors.accent,
                barCount: 20
            )
            .frame(height: 40)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Re-record: text button, subdued
            Button(action: onReRecord) {
                Text("Re-record")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textOnDark.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
            .opacity(isSubmitting ? 0.3 : 1.0)

            // Submit: AccentPillButton style
            Button {
                onSubmit()
            } label: {
                HStack(spacing: 10) {
                    if isSubmitting {
                        ProgressView()
                            .tint(AppColors.textOnAccent)
                            .scaleEffect(0.8)
                    }

                    Text(isSubmitting ? "Sending..." : "Submit")
                        .font(AppTypography.bodyBold)
                }
                .foregroundStyle(AppColors.textOnAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(AppColors.accent)
                )
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
        }
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let totalSeconds = Int(max(0, duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Preview State") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingPreview(
            amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3],
            duration: 47,
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
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingPreview(
            amplitudes: [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7, 0.5, 0.3],
            duration: 47,
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
