// TranscriptSnippetView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a snippet of a voice note's transcript.
/// Shows the first ~15 words by default; tap to expand and show the full transcript.
/// Falls back to "Voice note . [duration]" when no transcript is available.
public struct TranscriptSnippetView: View {
    let transcript: String?
    let duration: TimeInterval

    @State private var isExpanded: Bool = false

    public init(transcript: String?, duration: TimeInterval) {
        self.transcript = transcript
        self.duration = duration
    }

    public var body: some View {
        Group {
            if let transcript, !transcript.isEmpty {
                transcriptContent(transcript)
            } else {
                fallbackContent
            }
        }
    }

    // MARK: - Transcript Content

    private func transcriptContent(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isExpanded ? text : snippetText(from: text))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(isExpanded ? nil : 2)
                .animation(.easeInOut(duration: 0.2), value: isExpanded)

            if wordCount(text) > 15 {
                Button {
                    isExpanded.toggle()
                } label: {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if wordCount(text) > 15 {
                isExpanded.toggle()
            }
        }
    }

    // MARK: - Fallback Content

    private var fallbackContent: some View {
        Text("Voice note \u{00B7} \(formattedDuration)")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    // MARK: - Helpers

    /// Returns the first ~15 words of the text followed by ellipsis if truncated.
    private func snippetText(from text: String) -> String {
        let words = text.split(separator: " ", maxSplits: 16, omittingEmptySubsequences: true)
        if words.count > 15 {
            return words.prefix(15).joined(separator: " ") + "..."
        }
        return text
    }

    /// Returns the number of words in the text.
    private func wordCount(_ text: String) -> Int {
        text.split(separator: " ", omittingEmptySubsequences: true).count
    }

    /// Formats the duration as "Xm Ys" or "Xs" for display.
    private var formattedDuration: String {
        let total = Int(duration)
        let minutes = total / 60
        let seconds = total % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

// MARK: - Previews

#Preview("With Transcript") {
    VStack(alignment: .leading, spacing: 16) {
        TranscriptSnippetView(
            transcript: "This is a sample transcription of a voice note for testing purposes. It contains more than fifteen words so the user can tap to expand and see the full content of the transcription.",
            duration: 42.0
        )

        TranscriptSnippetView(
            transcript: "Short note.",
            duration: 5.0
        )
    }
    .padding()
}

#Preview("Without Transcript") {
    TranscriptSnippetView(
        transcript: nil,
        duration: 15.0
    )
    .padding()
}
#endif
