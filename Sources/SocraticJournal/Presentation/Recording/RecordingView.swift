// RecordingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen modal recording experience -- Bold Geometric Studio aesthetic.
/// Solid near-black background, massive coral-red record button as hero,
/// oversized typography, minimal chrome.
public struct RecordingView: View {
    @State private var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: RecordingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Solid near-black background
            AppColors.backgroundDark
                .ignoresSafeArea()

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

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Spacer()

            // Close button: plain X, no background circle
            Button {
                Task {
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.textOnDark)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 8)
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
            // Question at top, left-aligned
            questionSection
                .padding(.top, AppSpacing.lg)

            Spacer()

            // Waveform placeholder (subtle baseline)
            AudioWaveformView(
                amplitudes: [],
                accentColor: AppColors.textOnDark.opacity(0.15),
                barCount: 20
            )
            .frame(height: 40)
            .padding(.horizontal, AppSpacing.sectionGap)
            .padding(.bottom, AppSpacing.xl)

            // Record button -- the visual hero
            RecordButton(isRecording: false) {
                Task { await viewModel.startRecording() }
            }
            .padding(.bottom, AppSpacing.md)

            // State label
            RecordingStateLabel(state: .idle)
                .padding(.bottom, AppSpacing.sm)

            // Timer (zeroed out)
            RecordingTimer(elapsedTime: 0, isActive: false)

            Spacer()
        }
    }

    // MARK: - Recording State

    private var recordingContent: some View {
        VStack(spacing: 0) {
            // Question at top, slightly dimmed
            questionSection
                .opacity(0.6)
                .padding(.top, AppSpacing.lg)

            Spacer()

            // Live waveform in coral-red
            AudioWaveformView(
                amplitudes: [viewModel.currentAmplitude],
                isAnimating: true,
                accentColor: AppColors.accent,
                barCount: 20
            )
            .frame(height: 40)
            .padding(.horizontal, AppSpacing.sectionGap)
            .padding(.bottom, AppSpacing.xl)

            // Record button (recording state with pulse)
            RecordButton(isRecording: true) {
                Task { await viewModel.stopRecording() }
            }
            .padding(.bottom, AppSpacing.md)

            // State label
            RecordingStateLabel(state: .recording)
                .padding(.bottom, AppSpacing.sm)

            // Timer (counting up, coral-red)
            RecordingTimer(elapsedTime: viewModel.elapsedTime, isActive: true)

            Spacer()
        }
    }

    // MARK: - Recorded (Preview) State

    private var recordedContent: some View {
        VStack(spacing: 0) {
            // Question at top
            questionSection
                .padding(.top, AppSpacing.lg)

            Spacer()

            // State label
            RecordingStateLabel(state: viewModel.state)
                .padding(.bottom, AppSpacing.sm)

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
            // Question at top
            questionSection
                .padding(.top, AppSpacing.lg)

            Spacer()

            // State label
            RecordingStateLabel(state: .submitting)
                .padding(.bottom, AppSpacing.sm)

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

    // MARK: - Question Section

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Question text: 34pt bold, left-aligned, white on black
            Text(viewModel.question.text)
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textOnDark)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)

            // Category in ALL-CAPS tracking, coral-red
            Text(viewModel.question.category.displayName.uppercased())
                .font(AppTypography.sectionHeader)
                .tracking(AppTypography.sectionHeaderTracking)
                .foregroundStyle(AppColors.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Error Toast

    private func errorToast(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.warning)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textOnDark)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
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
