// HomeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The main Home Feed screen — the daily circle experience.
/// Shows today's prompt, member response status, and voice notes.
public struct HomeView: View {

    // MARK: - State

    @State private var viewModel: HomeViewModel
    @State private var showingRecorder = false
    @State private var showingSettings = false
    @State private var showingCreateCircle = false
    @State private var isPulseAnimating = false

    // MARK: - Dependencies (passed to recorder)

    private let voiceRecordingService: VoiceRecordingServiceProtocol
    private let playbackService: AudioPlaybackServiceProtocol
    private let voiceNoteRepository: VoiceNoteRepositoryProtocol
    private let circleRepository: CircleRepositoryProtocol

    // MARK: - Init

    public init(
        viewModel: HomeViewModel,
        voiceRecordingService: VoiceRecordingServiceProtocol,
        playbackService: AudioPlaybackServiceProtocol,
        voiceNoteRepository: VoiceNoteRepositoryProtocol,
        circleRepository: CircleRepositoryProtocol
    ) {
        _viewModel = State(initialValue: viewModel)
        self.voiceRecordingService = voiceRecordingService
        self.playbackService = playbackService
        self.voiceNoteRepository = voiceNoteRepository
        self.circleRepository = circleRepository
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task {
                    await viewModel.loadData()
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .sheet(isPresented: $showingRecorder) {
                    recorderSheet
                }
                .sheet(isPresented: $showingCreateCircle) {
                    CreateCircleView(
                        viewModel: CirclesViewModel(
                            repository: circleRepository,
                            currentUserId: viewModel.currentUserId
                        )
                    )
                }
                .alert("Something went wrong", isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("OK") { viewModel.clearError() }
                } message: {
                    Text(viewModel.error ?? "")
                }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.circles.isEmpty {
            loadingState
        } else if viewModel.circles.isEmpty {
            noCirclesState
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    // Circle selector (only if multiple circles)
                    if viewModel.circles.count > 1 {
                        circleSelectorRow
                    }

                    // Today's prompt card
                    promptCard

                    // Response status row
                    if !viewModel.members.isEmpty {
                        responseStatusRow
                    }

                    // Action area: record or view notes
                    if viewModel.todayPrompt != nil {
                        actionArea
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Loading your circles...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - No Circles State

    private var noCirclesState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Welcome to Circle")
                    .font(.title2.weight(.semibold))

                Text("Create your first circle to start sharing\ndaily moments with the people you love.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingCreateCircle = true
            } label: {
                Text("Create Your First Circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    // MARK: - Circle Selector

    private var circleSelectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.circles) { circle in
                    circlePill(for: circle)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func circlePill(for circle: CircleGroup) -> some View {
        let isSelected = viewModel.selectedCircle?.id == circle.id

        return Button {
            Task {
                await viewModel.selectCircle(circle)
            }
        } label: {
            HStack(spacing: 6) {
                Text(circle.emoji)
                    .font(.body)
                Text(circle.name)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Prompt Card

    private var promptCard: some View {
        VStack(spacing: 16) {
            if let prompt = viewModel.todayPrompt {
                VStack(spacing: 12) {
                    Text("Today's Question")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.8)

                    Text(prompt.promptText)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundStyle(.primary)

                    if let circle = viewModel.selectedCircle {
                        Text("Week \(circle.weekNumber) with \(circle.name)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    Text("Today's prompt is on its way...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Response Status Row

    private var responseStatusRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Responses")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.members) { member in
                        memberAvatar(for: member)
                    }
                }
            }
        }
    }

    private func memberAvatar(for member: CircleMember) -> some View {
        let responded = viewModel.hasResponded(userId: member.userId)
        let isCurrentUser = member.userId == viewModel.currentUserId

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(avatarColor(for: member.displayName))
                    .frame(width: 44, height: 44)
                    .opacity(responded ? 1.0 : 0.4)

                Text(viewModel.memberInitials(for: member.userId))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)

                if responded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .background(Circle().fill(Color(.systemBackground)).frame(width: 14, height: 14))
                        .offset(x: 16, y: 16)
                }
            }

            Text(isCurrentUser ? "You" : member.displayName.components(separatedBy: " ").first ?? member.displayName)
                .font(.caption2)
                .foregroundStyle(responded ? .primary : .tertiary)
                .lineLimit(1)
        }
        .frame(width: 56)
    }

    // MARK: - Action Area

    @ViewBuilder
    private var actionArea: some View {
        if !viewModel.hasUserResponded {
            // User hasn't responded yet — show record button
            notRespondedSection
        } else {
            // User has responded — show voice notes and play all
            respondedSection
        }
    }

    // MARK: - Not Responded Section

    private var notRespondedSection: some View {
        VStack(spacing: 20) {
            // Record button
            Button {
                showingRecorder = true
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: isPulseAnimating ? 52 : 44, height: isPulseAnimating ? 52 : 44)

                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Record Your Answer")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Up to 30 seconds")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isPulseAnimating = true
                }
            }

            // Locked voice notes teaser
            if !viewModel.voiceNotes.isEmpty {
                lockedNotesTeaser
            } else {
                beTheFirstMessage
            }
        }
    }

    private var lockedNotesTeaser: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.voiceNotes.prefix(3)) { note in
                lockedNoteCard(for: note)
            }

            if viewModel.voiceNotes.count > 3 {
                Text("+ \(viewModel.voiceNotes.count - 3) more")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func lockedNoteCard(for note: VoiceNote) -> some View {
        HStack(spacing: 12) {
            // Blurred avatar
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                )

            VStack(alignment: .leading, spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 80, height: 10)

                // Blurred mini waveform
                HStack(spacing: 2) {
                    ForEach(0..<20, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 2, height: CGFloat.random(in: 4...16))
                    }
                }
                .frame(height: 20)
            }

            Spacer()

            Text(note.formattedDuration)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.5))
        )
        .overlay(
            Text("Record yours first to unlock")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        )
    }

    private var beTheFirstMessage: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.and.mic")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Be the first to respond!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.5))
                .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Responded Section

    private var respondedSection: some View {
        VStack(spacing: 16) {
            // Play All button
            if viewModel.visibleVoiceNotes.count > 1 {
                playAllButton
            }

            // Voice note cards
            if viewModel.visibleVoiceNotes.isEmpty {
                allCaughtUpView
            } else {
                ForEach(Array(viewModel.visibleVoiceNotes.enumerated()), id: \.element.id) { index, note in
                    voiceNoteCard(for: note, at: index)
                }
            }

            // All caught up (when there are notes but all have been listed)
            if !viewModel.visibleVoiceNotes.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundStyle(.green.opacity(0.7))

                    Text("All caught up!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
    }

    private var playAllButton: some View {
        Button {
            if viewModel.isPlayingAll {
                viewModel.stopPlayAll()
            } else {
                Task {
                    await viewModel.playAll()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isPlayingAll ? "stop.fill" : "play.fill")
                    .font(.caption)
                Text(viewModel.isPlayingAll ? "Stop" : "Play All")
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func voiceNoteCard(for note: VoiceNote, at index: Int) -> some View {
        let isCurrentlyPlaying = viewModel.isPlayingAll && viewModel.currentlyPlayingIndex == index
        let memberName = viewModel.memberName(for: note.userId)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                // Member avatar
                Circle()
                    .fill(avatarColor(for: memberName))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(viewModel.memberInitials(for: note.userId))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(memberName)
                        .font(.subheadline.weight(.medium))

                    Text(note.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Text(note.formattedDuration)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            // Mini waveform
            miniWaveform(for: note, isPlaying: isCurrentlyPlaying)

            // Inline player
            VoiceNotePlayerView(voiceNote: note, playbackService: playbackService)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrentlyPlaying ? Color.accentColor.opacity(0.08) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isCurrentlyPlaying ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }

    private func miniWaveform(for note: VoiceNote, isPlaying: Bool) -> some View {
        let samples = note.waveformSamples ?? Array(repeating: Float(0.5), count: 40)

        return HStack(alignment: .center, spacing: 2) {
            ForEach(samples.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(isPlaying ? Color.accentColor : Color.accentColor.opacity(0.35))
                    .frame(width: 2, height: max(3, CGFloat(samples[index]) * 24))
            }
        }
        .frame(height: 28)
    }

    private var allCaughtUpView: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.pink.opacity(0.6))

            Text("You responded! Waiting for your circle.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.5))
        )
    }

    // MARK: - Recorder Sheet

    private var recorderSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let prompt = viewModel.todayPrompt {
                    // Show the prompt as context
                    Text(prompt.promptText)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                    Divider()
                        .padding(.horizontal)

                    Spacer()

                    VoiceRecorderView(
                        viewModel: VoiceRecorderViewModel(
                            recordingService: voiceRecordingService
                        ),
                        circleId: viewModel.selectedCircle?.id ?? UUID(),
                        promptId: prompt.id,
                        userId: viewModel.currentUserId,
                        onRecordingComplete: { url, duration in
                            Task {
                                await handleRecordingComplete(url: url, duration: duration, prompt: prompt)
                            }
                        }
                    )
                    .padding(.horizontal)

                    Spacer()
                } else {
                    Text("No prompt available")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingRecorder = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Recording Handler

    private func handleRecordingComplete(url: URL, duration: TimeInterval, prompt: DailyPrompt) async {
        guard let circle = viewModel.selectedCircle else { return }

        // Build relative audio path
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let relativePath = url.path.replacingOccurrences(of: documentsDir.path + "/", with: "")

        // Extract waveform samples
        var waveform: [Float]?
        do {
            waveform = try await voiceRecordingService.extractWaveform(from: url, sampleCount: 40)
        } catch {
            // Non-critical — waveform is optional
        }

        // Create and save voice note
        let voiceNote = VoiceNote(
            circleId: circle.id,
            promptId: prompt.id,
            userId: viewModel.currentUserId,
            localAudioPath: relativePath,
            duration: duration,
            waveformSamples: waveform
        )

        do {
            try await voiceNoteRepository.save(voiceNote)
            await viewModel.markUserResponded()
            await viewModel.reloadVoiceNotes()
            showingRecorder = false
        } catch {
            // Error is handled by viewModel
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if let circle = viewModel.selectedCircle {
                HStack(spacing: 6) {
                    Text(circle.emoji)
                    Text(circle.name)
                        .font(.headline)
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    /// Generate a consistent color from a string (for member avatars)
    private func avatarColor(for name: String) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .pink, .purple, .teal, .indigo, .mint, .cyan
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            circleRepository: LocalCircleRepository(),
            promptRepository: LocalPromptRepository(),
            promptGenerationService: LocalPromptGenerationService(),
            voiceNoteRepository: LocalVoiceNoteRepository(),
            voiceRecordingService: LocalVoiceRecordingService(),
            playbackService: LocalAudioPlaybackService(),
            currentUserId: UUID()
        ),
        voiceRecordingService: LocalVoiceRecordingService(),
        playbackService: LocalAudioPlaybackService(),
        voiceNoteRepository: LocalVoiceNoteRepository(),
        circleRepository: LocalCircleRepository()
    )
    .environment(ThemeManager.shared)
}
#endif
