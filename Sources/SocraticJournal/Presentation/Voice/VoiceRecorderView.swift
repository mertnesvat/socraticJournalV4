// VoiceRecorderView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Voice recording interface with tap-to-record, live waveform, timer, and playback preview.
///
/// States:
/// - **Idle**: Large record button. Tap to start.
/// - **Recording**: Live waveform + timer + stop button. Visual nudge at 30s. Auto-stops at 60s.
/// - **Done**: Playback preview with re-record and confirm actions.
public struct VoiceRecorderView: View {
    @State private var viewModel: VoiceRecorderViewModel
    /// Callback when a recording is confirmed.
    var onConfirm: ((VoiceNote) -> Void)?
    /// Callback when the view is dismissed without confirming.
    var onDismiss: (() -> Void)?

    // MARK: - Live waveform samples collected from the service
    @State private var liveSamples: [Float] = []
    @State private var sampleTimer: Timer?

    public init(
        viewModel: VoiceRecorderViewModel,
        onConfirm: ((VoiceNote) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top bar with cancel
            topBar

            Spacer()

            // Main content based on state
            switch viewModel.state {
            case .idle:
                idleContent
            case .recording:
                recordingContent
            case .done(let voiceNote):
                doneContent(voiceNote: voiceNote)
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .alert("Microphone Access Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                viewModel.dismissPermissionAlert()
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissPermissionAlert()
            }
        } message: {
            Text("Circle needs microphone access to record voice notes. Please enable it in Settings.")
        }
        .alert("Recording Error", isPresented: .init(
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

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                viewModel.cancelRecording()
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(SwiftUI.Circle())
            }
            Spacer()
        }
    }

    // MARK: - Idle State

    private var idleContent: some View {
        VStack(spacing: 24) {
            Text("Tap to Record")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)

            // Record button
            Button {
                Task { await viewModel.startRecording() }
            } label: {
                ZStack {
                    // Outer ring
                    SwiftUI.Circle()
                        .stroke(CircleTheme.warmAmber.opacity(0.3), lineWidth: 4)
                        .frame(width: 88, height: 88)

                    // Inner filled circle
                    SwiftUI.Circle()
                        .fill(
                            LinearGradient(
                                colors: [CircleTheme.warmAmber, CircleTheme.warmOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)

                    // Microphone icon
                    Image(systemName: "mic.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }
            .accessibilityLabel("Start recording")

            Text("Up to 60 seconds")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Recording State

    private var recordingContent: some View {
        VStack(spacing: 28) {
            // Timer
            Text(viewModel.formattedDuration)
                .font(.system(.largeTitle, design: .monospaced, weight: .light))
                .foregroundStyle(CircleTheme.warmBrown)

            // Live waveform
            WaveformView(
                amplitudes: liveSamples,
                isLive: true,
                liveAmplitude: viewModel.currentAmplitude
            )
            .frame(height: 60)
            .padding(.horizontal)
            .onAppear {
                startSampling()
            }
            .onDisappear {
                stopSampling()
            }

            // Nudge at 30s
            if viewModel.showNudge {
                Text("That's perfect!")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CircleTheme.warmAmber)
                    .transition(.opacity)
            }

            // Stop button
            Button {
                stopSampling()
                Task { await viewModel.stopRecording() }
            } label: {
                ZStack {
                    // Outer ring
                    SwiftUI.Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 4)
                        .frame(width: 88, height: 88)

                    // Inner stop square
                    SwiftUI.Circle()
                        .fill(Color.red)
                        .frame(width: 72, height: 72)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: 24, height: 24)
                }
            }
            .accessibilityLabel("Stop recording")

            Text("Tap to stop")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showNudge)
    }

    // MARK: - Done State

    private func doneContent(voiceNote: VoiceNote) -> some View {
        VStack(spacing: 28) {
            // Duration label
            Text(formatDuration(voiceNote.duration))
                .font(.system(.title2, design: .monospaced, weight: .light))
                .foregroundStyle(CircleTheme.warmBrown)

            // Static waveform
            WaveformView(
                amplitudes: voiceNote.waveformData,
                isLive: false
            )
            .frame(height: 60)
            .padding(.horizontal)

            // Playback toggle
            Button {
                viewModel.togglePlayback()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    Text(viewModel.isPlaying ? "Pause" : "Preview")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmAmber)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(CircleTheme.warmAmber.opacity(0.12))
                .clipShape(Capsule())
            }
            .accessibilityLabel(viewModel.isPlaying ? "Pause playback" : "Preview recording")

            // Transcription status
            if viewModel.isTranscribing {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Transcribing...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity)
            } else if let transcript = voiceNote.transcript, !transcript.isEmpty {
                TranscriptSnippetView(
                    transcript: transcript,
                    duration: voiceNote.duration
                )
                .padding(.horizontal)
                .transition(.opacity)
            }

            // Action buttons
            HStack(spacing: 20) {
                // Re-record
                Button {
                    liveSamples = []
                    viewModel.reRecord()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Re-record")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Confirm / Send
                Button {
                    if let note = viewModel.confirmRecording() {
                        onConfirm?(note)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                        Text("Send")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [CircleTheme.warmAmber, CircleTheme.warmOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Collect amplitude samples while recording for the live waveform.
    private func startSampling() {
        liveSamples = []
        sampleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                guard viewModel.isRecording else { return }
                liveSamples.append(viewModel.currentAmplitude)
            }
        }
    }

    private func stopSampling() {
        sampleTimer?.invalidate()
        sampleTimer = nil
    }
}

// MARK: - Previews

#Preview("Idle") {
    VoiceRecorderView(
        viewModel: VoiceRecorderViewModel(
            voiceRecordingService: MockVoiceRecordingService()
        )
    )
}

#Preview("Done State") {
    let mockService = MockVoiceRecordingService()
    let viewModel = VoiceRecorderViewModel(voiceRecordingService: mockService)
    VoiceRecorderView(viewModel: viewModel)
}
#endif
