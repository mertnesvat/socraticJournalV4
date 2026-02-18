// CircleFeedView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main feed view — today's prompt and voice note responses
struct CircleFeedView: View {
    @State var viewModel: CircleFeedViewModel
    @State private var showRecording = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading && viewModel.todaysPrompt == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    promptCard
                    responseSection
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.circle?.name ?? "Circle")
        .refreshable {
            await viewModel.loadFeed()
        }
        .sheet(isPresented: $showRecording) {
            if let prompt = viewModel.todaysPrompt, let circle = viewModel.circle {
                RecordingView(
                    prompt: prompt,
                    circle: circle,
                    currentUserId: viewModel.currentUserId,
                    audioService: viewModel.audioService,
                    audioStorageService: viewModel.audioStorageService,
                    voiceNoteRepository: viewModel.voiceNoteRepository,
                    promptRepository: viewModel.promptRepository,
                    onRecorded: {
                        showRecording = false
                        Task { await viewModel.loadFeed() }
                    }
                )
            }
        }
        .task {
            await viewModel.loadFeed()
        }
    }

    // MARK: - Prompt Card

    private var promptCard: some View {
        VStack(spacing: 16) {
            if let prompt = viewModel.todaysPrompt {
                HStack {
                    Text(prompt.category.emoji)
                    Text(prompt.category.displayName.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(prompt.question)
                    .font(.title2.bold())
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !viewModel.hasResponded {
                    Button {
                        showRecording = true
                    } label: {
                        Label("Record Your Answer", systemImage: "mic.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Response Section

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Responses")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.responses.count) of \(viewModel.members.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.responses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("Waiting for responses...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.responses) { note in
                    VoiceNoteCard(
                        note: note,
                        displayName: viewModel.displayName(for: note.authorId),
                        initial: viewModel.initial(for: note.authorId),
                        isPlaying: viewModel.playingNoteId == note.id,
                        onTap: {
                            Task {
                                if viewModel.playingNoteId == note.id {
                                    await viewModel.stopPlayback()
                                } else {
                                    await viewModel.playVoiceNote(note)
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Voice Note Card

struct VoiceNoteCard: View {
    let note: VoiceNote
    let displayName: String
    let initial: String
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    SwiftUI.Circle()
                        .fill(note.isListened ? Color(.tertiarySystemBackground) : Color.blue.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(initial)
                        .font(.headline)
                        .foregroundStyle(note.isListened ? Color.secondary : Color.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayName)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)

                        if !note.isListened {
                            SwiftUI.Circle()
                                .fill(.blue)
                                .frame(width: 6, height: 6)
                        }

                        Spacer()

                        Text(note.formattedDuration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    WaveformView(
                        data: note.waveformData.isEmpty
                            ? WaveformView.generatePlaceholder()
                            : note.waveformData,
                        isPlaying: isPlaying
                    )
                    .frame(height: 30)

                    if let snippet = note.transcriptSnippet {
                        Text(snippet)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    let data: [Float]
    let isPlaying: Bool

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, value in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isPlaying ? Color.blue : Color(.tertiaryLabel))
                        .frame(
                            width: max(2, (geometry.size.width - CGFloat(data.count - 1) * 2) / CGFloat(data.count)),
                            height: max(3, CGFloat(value) * geometry.size.height)
                        )
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    static func generatePlaceholder(count: Int = 30) -> [Float] {
        (0..<count).map { i in
            let base = Float(sin(Double(i) * 0.3) * 0.3 + 0.4)
            return max(0.1, min(1.0, base + Float.random(in: -0.15...0.15)))
        }
    }
}
#endif
