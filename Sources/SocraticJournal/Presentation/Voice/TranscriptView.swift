// TranscriptView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the transcript of a voice note
/// Shows a snippet (~20 words) with "Read more" to expand
/// Gracefully absent when no transcript is available
public struct TranscriptView: View {

    // MARK: - Config

    let voiceNote: VoiceNote
    let isTranscribing: Bool
    let permissionDenied: Bool

    // MARK: - State

    @State private var isExpanded = false

    // MARK: - Init

    public init(
        voiceNote: VoiceNote,
        isTranscribing: Bool = false,
        permissionDenied: Bool = false
    ) {
        self.voiceNote = voiceNote
        self.isTranscribing = isTranscribing
        self.permissionDenied = permissionDenied
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if isTranscribing {
                transcribingIndicator
            } else if let transcript = voiceNote.transcript, !transcript.isEmpty {
                transcriptContent(transcript: transcript)
            } else if permissionDenied {
                permissionHint
            }
            // If no transcript and not transcribing: show nothing (graceful absence)
        }
    }

    // MARK: - Transcribing Indicator

    private var transcribingIndicator: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)

            Text("Transcribing...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Transcript Content

    private func transcriptContent(transcript: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "text.quote")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text("Transcript")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }

            if isExpanded {
                Text(transcript)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded = false
                    }
                } label: {
                    Text("Show less")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
            } else {
                let snippet = voiceNote.transcriptSnippet ?? transcript
                let needsExpansion = snippet != transcript

                Text(snippet)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                if needsExpansion {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = true
                        }
                    } label: {
                        Text("Read more")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Permission Hint

    private var permissionHint: some View {
        Button {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "waveform.slash")
                    .font(.caption2)

                Text("Enable speech recognition in Settings")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}
#endif
