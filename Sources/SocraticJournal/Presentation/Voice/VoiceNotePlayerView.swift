// VoiceNotePlayerView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compact inline voice note player for the feed.
/// Displays speaker info, a waveform with playback progress overlay,
/// play/pause toggle, and duration badge. Supports drag-to-seek on the waveform.
public struct VoiceNotePlayerView: View {
    @State private var viewModel: VoiceNotePlayerViewModel

    /// The display name of the speaker.
    let speakerName: String
    /// The initials for the avatar.
    let speakerInitials: String
    /// Optional avatar image data.
    let avatarImageData: Data?

    // MARK: - Scrubbing State

    @State private var isScrubbing: Bool = false

    // MARK: - Init

    public init(
        viewModel: VoiceNotePlayerViewModel,
        speakerName: String,
        speakerInitials: String,
        avatarImageData: Data? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.speakerName = speakerName
        self.speakerInitials = speakerInitials
        self.avatarImageData = avatarImageData
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: avatar + name + duration badge
            HStack(spacing: 10) {
                InitialsAvatarView(
                    initials: speakerInitials,
                    avatarImageData: avatarImageData,
                    size: 32
                )

                Text(speakerName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CircleTheme.warmBrown)

                Spacer()

                // Duration badge
                Text(viewModel.totalTimeString)
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(Capsule())
            }

            // Bottom row: play/pause button + waveform with progress + time
            HStack(spacing: 12) {
                // Play/pause button
                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            LinearGradient(
                                colors: [CircleTheme.warmAmber, CircleTheme.warmOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(SwiftUI.Circle())
                }
                .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

                // Waveform with scrubbing
                waveformWithScrubbing

                // Elapsed / total time
                if viewModel.isActiveNote {
                    Text(viewModel.elapsedTimeString)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 30, alignment: .trailing)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("Playback Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Waveform with Scrubbing

    private var waveformWithScrubbing: some View {
        GeometryReader { geometry in
            WaveformView(
                amplitudes: viewModel.waveformData,
                isLive: false,
                barCount: 30,
                barSpacing: 1.5,
                progress: viewModel.isActiveNote ? viewModel.progress : 0.0
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isScrubbing = true
                        let normalizedX = value.location.x / geometry.size.width
                        viewModel.seekToProgress(normalizedX)
                    }
                    .onEnded { _ in
                        isScrubbing = false
                    }
            )
        }
        .frame(height: 32)
    }
}

// MARK: - Previews

#Preview("Idle") {
    let mockService = MockVoicePlaybackService()
    let voiceNote = VoiceNote(
        filePath: "VoiceNotes/mock/preview.m4a",
        duration: 14.5,
        waveformData: MockVoiceRecordingService.sampleWaveformData
    )
    VoiceNotePlayerView(
        viewModel: VoiceNotePlayerViewModel(
            playbackService: mockService,
            voiceNote: voiceNote
        ),
        speakerName: "Jordan Davis",
        speakerInitials: "JD"
    )
    .padding()
}

#Preview("Playing") {
    let mockService = MockVoicePlaybackService()
    let voiceNote = VoiceNote(
        filePath: "VoiceNotes/mock/preview.m4a",
        duration: 30.0,
        waveformData: MockVoiceRecordingService.sampleWaveformData
    )
    VoiceNotePlayerView(
        viewModel: VoiceNotePlayerViewModel(
            playbackService: mockService,
            voiceNote: voiceNote
        ),
        speakerName: "Alex Kim",
        speakerInitials: "AK"
    )
    .padding()
}
#endif
