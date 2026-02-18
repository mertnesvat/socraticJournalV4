// VoiceNotePlayerView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import AVFoundation

/// Reusable voice note playback UI component
/// Shows waveform visualization, play/pause, duration, and speed toggle
public struct VoiceNotePlayerView: View {

    // MARK: - Config

    let voiceNote: VoiceNote

    // MARK: - Dependencies

    private let playbackService: AudioPlaybackServiceProtocol

    // MARK: - State

    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var playbackSpeed: Float = 1.0
    @State private var progressTimer: Timer?
    @State private var hasError = false

    private let availableSpeeds: [Float] = [1.0, 1.5, 2.0]

    // MARK: - Init

    public init(voiceNote: VoiceNote, playbackService: AudioPlaybackServiceProtocol) {
        self.voiceNote = voiceNote
        self.playbackService = playbackService
    }

    // MARK: - Computed

    private var duration: TimeInterval { voiceNote.duration }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1.0, currentTime / duration)
    }

    private var waveformSamples: [Float] {
        voiceNote.waveformSamples ?? Array(repeating: 0.5, count: 40)
    }

    private var audioFileURL: URL? {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDir.appendingPathComponent(voiceNote.localAudioPath)
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 12) {
            // Waveform visualization
            waveformView

            // Controls row
            HStack(spacing: 16) {
                // Play/Pause button
                playPauseButton

                // Time scrubber
                timeScrubber

                // Speed toggle
                speedToggleButton
            }
        }
        .padding(.vertical, 8)
        .onDisappear {
            stopPlayback()
        }
    }

    // MARK: - Waveform View

    private var waveformView: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(waveformSamples.indices, id: \.self) { index in
                let sample = waveformSamples[index]
                let barProgress = Double(index) / Double(max(waveformSamples.count - 1, 1))
                let isHighlighted = barProgress <= progress

                RoundedRectangle(cornerRadius: 2)
                    .fill(isHighlighted ? Color.accentColor : Color.accentColor.opacity(0.25))
                    .frame(width: 3, height: max(4, CGFloat(sample) * 44))
            }
        }
        .frame(height: 52)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Scrub by drag position
                    let totalWidth = UIScreen.main.bounds.width - 32
                    let ratio = max(0, min(1, value.location.x / totalWidth))
                    let seekTime = ratio * duration
                    currentTime = seekTime
                    playbackService.seek(to: seekTime)
                }
        )
    }

    // MARK: - Play/Pause Button

    private var playPauseButton: some View {
        Button {
            togglePlayback()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 44, height: 44)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .offset(x: isPlaying ? 0 : 2)
            }
        }
        .buttonStyle(.plain)
        .disabled(hasError)
    }

    // MARK: - Time Scrubber

    private var timeScrubber: some View {
        HStack {
            Text(formattedTime(currentTime))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)

            Spacer()

            Text(voiceNote.formattedDuration)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    // MARK: - Speed Toggle

    private var speedToggleButton: some View {
        Button {
            cyclePlaybackSpeed()
        } label: {
            Text(speedLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 28)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var speedLabel: String {
        switch playbackSpeed {
        case 1.0: return "1x"
        case 1.5: return "1.5x"
        case 2.0: return "2x"
        default: return "1x"
        }
    }

    // MARK: - Actions

    private func togglePlayback() {
        if isPlaying {
            playbackService.pause()
            isPlaying = false
            stopProgressTimer()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let url = audioFileURL else {
            hasError = true
            return
        }

        do {
            if currentTime > 0 {
                // Resume from current position
                try playbackService.play(url: url)
                playbackService.seek(to: currentTime)
            } else {
                try playbackService.play(url: url)
            }
            playbackService.setPlaybackSpeed(playbackSpeed)
            isPlaying = true
            hasError = false
            startProgressTimer()
        } catch {
            hasError = true
        }
    }

    private func stopPlayback() {
        playbackService.stop()
        isPlaying = false
        stopProgressTimer()
    }

    private func cyclePlaybackSpeed() {
        let currentIndex = availableSpeeds.firstIndex(of: playbackSpeed) ?? 0
        let nextIndex = (currentIndex + 1) % availableSpeeds.count
        playbackSpeed = availableSpeeds[nextIndex]
        playbackService.setPlaybackSpeed(playbackSpeed)
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let time = playbackService.currentTime
            currentTime = time

            // Auto-stop at end
            if time >= duration && duration > 0 {
                isPlaying = false
                currentTime = 0
                stopProgressTimer()
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Helpers

    private func formattedTime(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
#endif
