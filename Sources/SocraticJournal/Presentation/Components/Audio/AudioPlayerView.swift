// AudioPlayerView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import Observation

/// Full audio player component with play/pause button, waveform visualization,
/// time labels, and seek-by-tap functionality
/// Designed for use in detail views where full playback controls are needed
public struct AudioPlayerView: View {
    // MARK: - Properties

    @State private var viewModel: AudioPlayerViewModel

    // MARK: - Initialization

    public init(playbackService: AudioPlaybackServiceProtocol, url: URL) {
        _viewModel = State(initialValue: AudioPlayerViewModel(
            playbackService: playbackService,
            url: url
        ))
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 16) {
            playPauseButton
            waveformWithSeek
            timeLabel
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(width: 44, height: 44)
                } else {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }

    // MARK: - Waveform with Seek

    private var waveformWithSeek: some View {
        GeometryReader { geometry in
            AudioWaveformView(
                audioLevel: viewModel.currentAudioLevel,
                mode: viewModel.isPlaying ? .playback : .idle,
                barCount: 40,
                barColor: .secondary.opacity(0.3),
                activeColor: .accentColor,
                progress: viewModel.progress
            )
            .contentShape(Rectangle())
            .onTapGesture { location in
                let fraction = location.x / geometry.size.width
                let seekTime = viewModel.duration * Double(fraction)
                viewModel.seek(to: seekTime)
            }
        }
        .frame(height: 40)
    }

    // MARK: - Time Label

    private var timeLabel: some View {
        Text("\(formatTime(viewModel.currentTime)) / \(formatTime(viewModel.duration))")
            .font(.caption)
            .fontDesign(.monospaced)
            .foregroundStyle(.secondary)
            .fixedSize()
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - AudioPlayerViewModel

@Observable
@MainActor
final class AudioPlayerViewModel {
    // MARK: - State

    private(set) var isPlaying: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var currentAudioLevel: Float = 0
    private(set) var error: Error?

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    // MARK: - Dependencies

    private let playbackService: AudioPlaybackServiceProtocol
    private let url: URL
    private var hasStartedOnce: Bool = false

    // MARK: - Initialization

    init(playbackService: AudioPlaybackServiceProtocol, url: URL) {
        self.playbackService = playbackService
        self.url = url
    }

    // MARK: - Actions

    func togglePlayback() {
        if isPlaying {
            playbackService.pause()
            isPlaying = false
        } else {
            startPlayback()
        }
    }

    func seek(to time: TimeInterval) {
        playbackService.seek(to: time)
        currentTime = time

        // If not playing, start playback after seeking
        if !isPlaying && hasStartedOnce {
            startPlayback()
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
            self.currentTime = self.duration
        }
    }

    // MARK: - Private Helpers

    private func startPlayback() {
        isLoading = true
        error = nil

        do {
            try playbackService.play(url: url)
            isPlaying = true
            hasStartedOnce = true
            duration = playbackService.duration

            // Start a timer to track progress from the service
            startProgressTracking()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func startProgressTracking() {
        // Use a task to periodically read the service state
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
    VStack(spacing: 20) {
        AudioPlayerView(
            playbackService: MockAudioPlaybackService(duration: 30),
            url: URL(fileURLWithPath: "/tmp/mock-audio.m4a")
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
