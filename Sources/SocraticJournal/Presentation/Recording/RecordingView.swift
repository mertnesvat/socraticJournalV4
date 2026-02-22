// RecordingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen modal recording experience for answering a daily question
/// Transitions through idle, recording, preview, and submit states with
/// haptic feedback, animated waveforms, and a dark studio aesthetic
public struct RecordingView: View {
    @State private var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: RecordingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Dark background with gradient
            backgroundLayer
                .ignoresSafeArea()

            // Recording blur overlay when active
            if case .recording = viewModel.state {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            // Main content
            VStack(spacing: 0) {
                // Top bar with close button
                topBar

                // Main flow content
                mainContent

                Spacer(minLength: 40)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
        .onChange(of: viewModel.didSubmit) { _, submitted in
            if submitted {
                dismiss()
            }
        }
        .overlay(alignment: .top) {
            // Error toast
            if let error = viewModel.errorMessage {
                errorToast(error)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.06, blue: 0.14),
                Color(red: 0.04, green: 0.04, blue: 0.10),
                Color(red: 0.02, green: 0.02, blue: 0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Close button
            Button {
                Task {
                    // Clean up before dismissing
                    if viewModel.isRecording {
                        await viewModel.stopRecording()
                    }
                    if viewModel.isPlaying {
                        await viewModel.stopPlayback()
                    }
                }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.state {
        case .idle:
            idleContent
        case .recording:
            recordingContent
        case .recorded:
            recordedContent
        case .submitting:
            submittingContent
        }
    }

    // MARK: - Idle State

    private var idleContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Question reference
            questionLabel
                .padding(.bottom, 48)

            // Waveform placeholder (subtle baseline)
            AudioWaveformView(
                amplitudes: [],
                accentColor: Color.white.opacity(0.15),
                barCount: 35
            )
            .frame(height: 40)
            .padding(.horizontal, 40)
            .padding(.bottom, 32)

            // Record button
            RecordButton(isRecording: false) {
                Task { await viewModel.startRecording() }
            }
            .padding(.bottom, 16)

            // State label
            RecordingStateLabel(state: .idle)
                .padding(.bottom, 12)

            // Timer (zeroed out)
            RecordingTimer(elapsedTime: 0, isActive: false)

            Spacer()
        }
    }

    // MARK: - Recording State

    private var recordingContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Question reference (smaller during recording)
            questionLabel
                .opacity(0.6)
                .padding(.bottom, 48)

            // Live waveform
            AudioWaveformView(
                amplitudes: [viewModel.currentAmplitude],
                isAnimating: true,
                accentColor: Color(red: 1.0, green: 0.35, blue: 0.35),
                barCount: 35
            )
            .frame(height: 40)
            .padding(.horizontal, 40)
            .padding(.bottom, 32)

            // Record button (recording state)
            RecordButton(isRecording: true) {
                Task { await viewModel.stopRecording() }
            }
            .padding(.bottom, 16)

            // State label
            RecordingStateLabel(state: .recording)
                .padding(.bottom, 12)

            // Timer (counting up)
            RecordingTimer(elapsedTime: viewModel.elapsedTime, isActive: true)

            Spacer()
        }
    }

    // MARK: - Recorded (Preview) State

    private var recordedContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Question reference
            questionLabel
                .padding(.bottom, 32)

            // State label
            RecordingStateLabel(state: viewModel.state)
                .padding(.bottom, 8)

            // Duration
            RecordingTimer(
                elapsedTime: viewModel.recordingDuration,
                isActive: false
            )
            .padding(.bottom, 24)

            // Preview with playback and action buttons
            RecordingPreview(
                amplitudes: viewModel.recordedAmplitudes,
                duration: viewModel.recordingDuration,
                currentTime: viewModel.currentPlaybackTime,
                isPlaying: viewModel.isPlaying,
                onPlayPause: {
                    Task {
                        if viewModel.isPlaying {
                            await viewModel.stopPlayback()
                        } else {
                            await viewModel.playRecording()
                        }
                    }
                },
                onReRecord: {
                    Task { await viewModel.reRecord() }
                },
                onSubmit: {
                    Task { await viewModel.submit() }
                }
            )

            Spacer()
        }
    }

    // MARK: - Submitting State

    private var submittingContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Question reference
            questionLabel
                .padding(.bottom, 32)

            // Loading indicator
            RecordingStateLabel(state: .submitting)
                .padding(.bottom, 8)

            RecordingTimer(
                elapsedTime: viewModel.recordingDuration,
                isActive: false
            )
            .padding(.bottom, 24)

            // Preview in submitting state
            RecordingPreview(
                amplitudes: viewModel.recordedAmplitudes,
                duration: viewModel.recordingDuration,
                currentTime: 0,
                isPlaying: false,
                onPlayPause: {},
                onReRecord: {},
                onSubmit: {},
                isSubmitting: true
            )

            Spacer()
        }
    }

    // MARK: - Question Label

    private var questionLabel: some View {
        Text(viewModel.question.text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 32)
    }

    // MARK: - Error Toast

    private func errorToast(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.yellow)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.2, green: 0.1, blue: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
}

// MARK: - Preview

#Preview("Recording View") {
    RecordingView(
        viewModel: RecordingViewModel(
            question: DailyQuestion(
                id: "preview-1",
                text: "Is it ever okay to lie to protect someone's feelings?",
                category: .gettingSpicy,
                level: 2,
                createdAt: Date(),
                globalResponseCount: 1247,
                disagreementRatio: 0.62
            ),
            voiceRecordingService: VoiceRecordingService()
        )
    )
    .preferredColorScheme(.dark)
}

#endif
