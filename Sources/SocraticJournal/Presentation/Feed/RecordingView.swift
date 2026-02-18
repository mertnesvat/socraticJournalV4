// RecordingView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Recording flow: record → preview → send
struct RecordingView: View {
    let prompt: DailyPrompt
    let circle: Circle
    let currentUserId: String
    let audioService: AudioServiceProtocol
    let audioStorageService: AudioStorageServiceProtocol
    let voiceNoteRepository: VoiceNoteRepositoryProtocol
    let promptRepository: PromptRepositoryProtocol
    let onRecorded: () -> Void

    @State private var isRecording = false
    @State private var recordedURL: URL?
    @State private var duration: TimeInterval = 0
    @State private var isSending = false
    @State private var error: String?
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text(prompt.question)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Recording visualization
                ZStack {
                    SwiftUI.Circle()
                        .fill(isRecording ? Color.red.opacity(0.15) : Color(.secondarySystemBackground))
                        .frame(width: 180, height: 180)

                    if isRecording {
                        SwiftUI.Circle()
                            .fill(Color.red.opacity(0.08))
                            .frame(width: 220, height: 220)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)
                    }

                    VStack(spacing: 8) {
                        Image(systemName: isRecording ? "stop.fill" : (recordedURL != nil ? "checkmark.circle.fill" : "mic.fill"))
                            .font(.system(size: 44))
                            .foregroundStyle(isRecording ? .red : .blue)

                        Text(formatDuration(duration))
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundStyle(isRecording ? .red : .primary)
                    }
                }
                .onTapGesture {
                    Task { await toggleRecording() }
                }

                // Status text
                if isRecording {
                    Text(duration < VoiceNote.recommendedMinDuration
                         ? "Keep going..."
                         : "Tap to stop")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if recordedURL == nil {
                    Text("Tap to start recording")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let error {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                Spacer()

                // Action buttons after recording
                if recordedURL != nil && !isRecording {
                    VStack(spacing: 12) {
                        Button {
                            Task { await sendRecording() }
                        } label: {
                            Group {
                                if isSending {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Send", systemImage: "arrow.up.circle.fill")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isSending)

                        Button {
                            recordedURL = nil
                            duration = 0
                        } label: {
                            Text("Re-record")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.secondarySystemBackground))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isSending)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding()
            .navigationTitle("Record Response")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Actions

    private func toggleRecording() async {
        if isRecording {
            isRecording = false
            timer?.invalidate()
            timer = nil
            if let url = try? await audioService.stopRecording() {
                recordedURL = url
            }
        } else if recordedURL == nil {
            guard await audioService.requestMicrophonePermission() else {
                error = "Microphone access is required to record voice notes"
                return
            }
            error = nil
            do {
                _ = try await audioService.startRecording()
                isRecording = true
                duration = 0
                startDurationTimer()
            } catch {
                self.error = "Failed to start recording"
            }
        }
    }

    private func startDurationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                duration += 0.1
                if duration >= VoiceNote.maxDuration {
                    await toggleRecording()
                }
            }
        }
    }

    private func sendRecording() async {
        guard let url = recordedURL else { return }
        guard duration >= VoiceNote.minDuration else {
            error = "Recording must be at least \(Int(VoiceNote.minDuration)) seconds"
            return
        }

        isSending = true
        do {
            let remotePath = try await audioStorageService.uploadAudio(
                from: url, circleId: circle.id, promptId: prompt.id, userId: currentUserId
            )
            let waveform = try await audioService.extractWaveform(from: url, samples: 30)
            let voiceNote = VoiceNote(
                circleId: circle.id, promptId: prompt.id, authorId: currentUserId,
                audioURL: remotePath, duration: duration, waveformData: waveform
            )
            try await voiceNoteRepository.saveVoiceNote(voiceNote)
            try await promptRepository.incrementResponseCount(promptId: prompt.id)
            onRecorded()
        } catch {
            self.error = "Failed to send recording"
        }
        isSending = false
    }

    private func formatDuration(_ d: TimeInterval) -> String {
        let minutes = Int(d) / 60
        let seconds = Int(d) % 60
        let tenths = Int((d.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }
}
#endif
