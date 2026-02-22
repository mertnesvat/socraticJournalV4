// MiniAudioPlayerView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import Observation

/// Compact audio player variant designed for list items and inline display
/// Features a small play/pause button, compact waveform, and duration label
/// Fits within standard list row height (~44pt)
public struct MiniAudioPlayerView: View {
    // MARK: - Properties

    @State private var viewModel: MiniAudioPlayerViewModel

    // MARK: - Initialization

    public init(playbackService: AudioPlaybackServiceProtocol, url: URL, duration: TimeInterval) {
        _viewModel = State(initialValue: MiniAudioPlayerViewModel(
            playbackService: playbackService,
            url: url,
            displayDuration: duration
        ))
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 10) {
            playPauseButton
            compactWaveform
            durationLabel
        }
        .frame(height: 44)
        .task {
            await viewModel.observeAudioLevels()
        }
        .task {
            await viewModel.observePlaybackFinished()
        }
    }

    // MARK: - Play/Pause Button

    private var playPauseButton: some View {
        Button {
            viewModel.togglePlayback()
        } label: {
            Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.tint)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Compact Waveform

    private var compactWaveform: some View {
        AudioWaveformView(
            audioLevel: viewModel.currentAudioLevel,
            mode: viewModel.isPlaying ? .playback : .idle,
            barCount: 20,
            barColor: .secondary.opacity(0.3),
            activeColor: .accentColor,
            barSpacing: 2,
            cornerRadius: 1,
            progress: viewModel.progress
        )
        .frame(height: 24)
    }

    // MARK: - Duration Label

    private var durationLabel: some View {
        Text(formatDuration(viewModel.displayDuration))
            .font(.caption2)
            .fontDesign(.monospaced)
            .foregroundStyle(.secondary)
            .fixedSize()
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - MiniAudioPlayerViewModel

@Observable
@MainActor
final class MiniAudioPlayerViewModel {
    // MARK: - State

    private(set) var isPlaying: Bool = false
    private(set) var currentAudioLevel: Float = 0
    private(set) var currentTime: TimeInterval = 0
    let displayDuration: TimeInterval

    var progress: Double {
        guard displayDuration > 0 else { return 0 }
        return currentTime / displayDuration
    }

    // MARK: - Dependencies

    private let playbackService: AudioPlaybackServiceProtocol
    private let url: URL

    // MARK: - Initialization

    init(playbackService: AudioPlaybackServiceProtocol, url: URL, displayDuration: TimeInterval) {
        self.playbackService = playbackService
        self.url = url
        self.displayDuration = displayDuration
    }

    // MARK: - Actions

    func togglePlayback() {
        if isPlaying {
            playbackService.pause()
            isPlaying = false
        } else {
            do {
                try playbackService.play(url: url)
                isPlaying = true
                startProgressTracking()
            } catch {
                // Silently fail for mini player
                isPlaying = false
            }
        }
    }

    func observeAudioLevels() async {
        for await level in playbackService.audioLevels {
            self.currentAudioLevel = level
        }
    }

    func observePlaybackFinished() async {
        for await _ in playbackService.playbackFinished {
            self.isPlaying = false
            self.currentTime = 0
        }
    }

    // MARK: - Private Helpers

    private func startProgressTracking() {
        Task { @MainActor [weak self] in
            while let self, self.isPlaying {
                self.currentTime = self.playbackService.currentTime
                self.isPlaying = self.playbackService.isPlaying
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        MiniAudioPlayerView(
            playbackService: MockAudioPlaybackService(duration: 15),
            url: URL(fileURLWithPath: "/tmp/mock-audio.m4a"),
            duration: 15
        )

        MiniAudioPlayerView(
            playbackService: MockAudioPlaybackService(duration: 45),
            url: URL(fileURLWithPath: "/tmp/mock-audio-2.m4a"),
            duration: 45
        )
    }
    .padding()
}
#endif
