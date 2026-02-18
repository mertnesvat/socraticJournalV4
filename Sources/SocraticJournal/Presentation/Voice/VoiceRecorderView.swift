// VoiceRecorderView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import AVFoundation

/// Reusable voice recording UI component
/// States: idle → recording → done
/// Auto-stops at 30 seconds, shows "Keep going..." nudge under 15s
public struct VoiceRecorderView: View {

    // MARK: - Dependencies

    @State private var viewModel: VoiceRecorderViewModel

    // MARK: - Config

    private let circleId: UUID
    private let promptId: UUID
    private let userId: UUID
    private let onRecordingComplete: (URL, TimeInterval) -> Void

    // MARK: - Local State

    @State private var recordingState: RecordingState = .idle
    @State private var isButtonPulsing = false
    @State private var completedDuration: TimeInterval = 0

    private enum RecordingState {
        case idle, recording, done
    }

    // MARK: - Init

    public init(
        viewModel: VoiceRecorderViewModel,
        circleId: UUID,
        promptId: UUID,
        userId: UUID,
        onRecordingComplete: @escaping (URL, TimeInterval) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.circleId = circleId
        self.promptId = promptId
        self.userId = userId
        self.onRecordingComplete = onRecordingComplete
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 24) {
            // Permission denied state
            if viewModel.permissionDenied {
                permissionDeniedView
            } else {
                switch recordingState {
                case .idle:
                    idleContent
                case .recording:
                    recordingContent
                case .done:
                    doneContent
                }
            }
        }
        .task {
            await viewModel.checkPermission()
        }
    }

    // MARK: - Idle Content

    private var idleContent: some View {
        VStack(spacing: 20) {
            Text("Tap to Record")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            recordButton

            Text("Up to 30 seconds")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Recording Content

    private var recordingContent: some View {
        VStack(spacing: 20) {
            // Time display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formattedTime(viewModel.currentDuration))
                    .font(.system(size: 36, weight: .thin, design: .monospaced))
                    .foregroundStyle(.primary)

                Text("/ 0:30")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            // Live waveform
            liveWaveform

            // "Keep going" nudge
            if viewModel.currentDuration < VoiceRecorderViewModel.minRecommendedDuration {
                Text("Keep going...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            } else {
                Text("Great! Tap to finish")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }

            recordButton
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentDuration < VoiceRecorderViewModel.minRecommendedDuration)
    }

    // MARK: - Done Content

    private var doneContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Recorded \(formattedTime(completedDuration))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    recordingState = .idle
                }
            } label: {
                Text("Record Again")
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .systemFill))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button {
            handleRecordButtonTap()
        } label: {
            ZStack {
                // Pulsing outer ring when recording
                if recordingState == .recording {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 3)
                        .frame(width: isButtonPulsing ? 100 : 88, height: isButtonPulsing ? 100 : 88)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: isButtonPulsing
                        )
                }

                // Main button circle
                Circle()
                    .fill(recordingState == .recording ? Color.red : Color.red.opacity(0.85))
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.red.opacity(recordingState == .recording ? 0.5 : 0.3), radius: 12, x: 0, y: 4)

                // Icon
                if recordingState == .recording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isButtonPulsing && recordingState == .recording ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isButtonPulsing)
    }

    // MARK: - Live Waveform

    private var liveWaveform: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(viewModel.audioLevels.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red.opacity(0.7 + Double(viewModel.audioLevels[index]) * 0.3))
                    .frame(width: 3, height: max(4, CGFloat(viewModel.audioLevels[index]) * 48))
            }
        }
        .frame(height: 56)
        .animation(.easeInOut(duration: 0.1), value: viewModel.audioLevels.last)
    }

    // MARK: - Permission Denied View

    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Microphone Access Required")
                    .font(.headline)

                Text("Please allow microphone access in Settings to record voice notes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            } label: {
                Text("Open Settings")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    // MARK: - Actions

    private func handleRecordButtonTap() {
        switch recordingState {
        case .idle:
            withAnimation(.easeInOut(duration: 0.2)) {
                recordingState = .recording
                isButtonPulsing = true
            }
            Task {
                await viewModel.startRecording(
                    circleId: circleId,
                    promptId: promptId,
                    userId: userId
                )
            }

        case .recording:
            let duration = viewModel.currentDuration
            if let url = viewModel.stopRecording() {
                completedDuration = duration
                withAnimation(.easeInOut(duration: 0.3)) {
                    recordingState = .done
                    isButtonPulsing = false
                }
                onRecordingComplete(url, duration)
            }

        case .done:
            break
        }
    }

    // MARK: - Helpers

    private func formattedTime(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
#endif
