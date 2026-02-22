// VoiceRecordingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

/// Full-screen voice recording experience
/// Presented as a .fullScreenCover from the DailyQuestionFeedView
/// Guides the user through idle -> recording -> preview -> submit flow
public struct VoiceRecordingView: View {
    @State private var viewModel: VoiceRecordingViewModel
    @State private var pulseScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss

    /// Playback service reference for the AudioPlayerView in preview state
    private let playbackService: AudioPlaybackServiceProtocol

    public init(
        viewModel: VoiceRecordingViewModel,
        playbackService: AudioPlaybackServiceProtocol
    ) {
        _viewModel = State(initialValue: viewModel)
        self.playbackService = playbackService
    }

    public var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with dismiss button
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Spacer()

                // Main content based on state
                stateContent

                Spacer()
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
        .alert(
            "Recording Error",
            isPresented: $viewModel.showErrorAlert,
            presenting: viewModel.error
        ) { _ in
            Button("OK", role: .cancel) {
                viewModel.error = nil
            }
        } message: { error in
            Text(errorMessage(for: error))
        }
        .alert(
            "Re-record?",
            isPresented: $viewModel.showReRecordConfirmation
        ) {
            Button("Re-record", role: .destructive) {
                viewModel.confirmReRecord()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase your recording.")
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Dismiss / Cancel button
            Button {
                switch viewModel.recordingState {
                case .recording:
                    viewModel.cancelRecording()
                default:
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - State Content Router

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.recordingState {
        case .idle:
            idleContent
        case .recording:
            recordingContent
        case .preview:
            previewContent
        case .submitting:
            submittingContent
        }
    }

    // MARK: - Idle State

    private var idleContent: some View {
        VStack(spacing: 32) {
            // Question card
            questionCard

            Spacer()
                .frame(height: 16)

            // Mic button
            Button {
                Task {
                    await viewModel.startRecording()
                }
            } label: {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.plain)

            // Labels
            VStack(spacing: 8) {
                Text("Tap to Record")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("60 sec max")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Recording State

    private var recordingContent: some View {
        VStack(spacing: 32) {
            // Question text (compact)
            Text(viewModel.question.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 24)

            Spacer()
                .frame(height: 8)

            // Pulsing red dot + timer
            HStack(spacing: 12) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulseScale)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                        ) {
                            pulseScale = 1.4
                        }
                    }
                    .onDisappear {
                        pulseScale = 1.0
                    }

                Text(viewModel.formattedDuration)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }

            // Waveform
            AudioWaveformView(
                audioLevel: viewModel.audioLevel,
                mode: .recording,
                barCount: 50,
                barColor: .red.opacity(0.3),
                activeColor: .red
            )
            .frame(height: 120)
            .padding(.horizontal, 24)

            // Hint text
            if viewModel.currentDuration < 3.0 {
                Text("Keep going...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
                .frame(height: 16)

            // Stop button
            Button {
                viewModel.stopRecording()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)

            Text("Tap to Stop")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Preview State

    private var previewContent: some View {
        VStack(spacing: 24) {
            // Header
            Text("Preview Your Answer")
                .font(.title2)
                .fontWeight(.bold)

            // Question reference
            Text(viewModel.question.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 24)

            // Duration
            Text(viewModel.formattedDuration)
                .font(.system(.title3, design: .monospaced))
                .foregroundStyle(.secondary)
                .monospacedDigit()

            // Audio player
            if let fileURL = viewModel.recordedFileURL {
                AudioPlayerView(
                    playbackService: playbackService,
                    url: fileURL
                )
                .padding(.horizontal, 24)
            }

            Spacer()
                .frame(height: 16)

            // Action buttons
            VStack(spacing: 12) {
                // Submit button
                Button {
                    Task {
                        await viewModel.submitAnswer()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.accentColor)
                        )
                }
                .padding(.horizontal, 24)

                // Re-record button
                Button {
                    viewModel.reRecord()
                } label: {
                    Text("Re-record")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Submitting State

    private var submittingContent: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Submitting...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Question Card

    private var questionCard: some View {
        VStack(spacing: 12) {
            // Category pill
            Text(viewModel.question.category.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(colorForCategory(viewModel.question.category))
                )

            // Question text
            Text(viewModel.question.text)
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    colorForCategory(viewModel.question.category).opacity(0.3),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Helpers

    private func colorForCategory(_ category: QuestionCategory) -> Color {
        switch category.colorHint {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .accentColor
        }
    }

    private func errorMessage(for error: VoiceRecordingError) -> String {
        switch error {
        case .permissionDenied:
            return "Microphone access is required to record your answer. Please enable it in Settings."
        case .recordingFailed:
            return "Unable to start recording. Please try again."
        case .audioSessionFailed:
            return "Audio session could not be configured. Please try again."
        case .tooShort:
            return "Recording must be at least 3 seconds long."
        case .interrupted:
            return "Recording was interrupted. Please try again."
        }
    }
}

// MARK: - Preview

#Preview {
    VoiceRecordingView(
        viewModel: VoiceRecordingViewModel(
            question: DailyQuestion(
                text: "What is something you believed as a child that you no longer believe?",
                category: .deep,
                level: .level2
            ),
            recordingService: MockVoiceRecordingService(),
            voiceAnswerRepository: MockVoiceAnswerRepository(),
            streakRepository: MockStreakRepository(),
            playbackService: MockAudioPlaybackService()
        ),
        playbackService: MockAudioPlaybackService()
    )
}
#endif
