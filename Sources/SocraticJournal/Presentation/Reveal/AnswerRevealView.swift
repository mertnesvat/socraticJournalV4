// AnswerRevealView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen answer reveal experience presented after submitting a voice answer
/// Walks through celebration, friend answer reveal with playback, and summary phases
public struct AnswerRevealView: View {
    @State private var viewModel: AnswerRevealViewModel
    @Environment(\.dismiss) private var dismiss

    /// Playback service for inline audio players
    private let playbackService: AudioPlaybackServiceProtocol

    public init(
        viewModel: AnswerRevealViewModel,
        playbackService: AudioPlaybackServiceProtocol
    ) {
        _viewModel = State(initialValue: viewModel)
        self.playbackService = playbackService
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                switch viewModel.revealPhase {
                case .celebration:
                    celebrationPhase
                case .reveal:
                    revealPhase
                case .summary:
                    revealPhase
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.dismiss()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task {
            await viewModel.startReveal()
        }
        .alert("Coming Soon", isPresented: $viewModel.showShareAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Shareable opinion cards are coming in a future update!")
        }
    }

    // MARK: - Phase 1: Celebration

    private var celebrationPhase: some View {
        CelebrationOverlay()
    }

    // MARK: - Phase 2 & 3: Reveal + Summary

    private var revealPhase: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Header
                revealHeader
                    .padding(.top, 8)

                if viewModel.friendAnswers.isEmpty {
                    waitingForFriendsView
                } else {
                    // Friend answer cards
                    ForEach(Array(viewModel.friendAnswers.enumerated()), id: \.element.id) { index, friendAnswer in
                        RevealFriendAnswerCard(
                            friendAnswer: friendAnswer,
                            index: index,
                            isPlaying: viewModel.currentlyPlayingIndex == index,
                            isAnyPlaying: viewModel.currentlyPlayingIndex != nil,
                            hasBeenPlayed: viewModel.playedAnswerIds.contains(friendAnswer.id),
                            currentReaction: viewModel.reactions[friendAnswer.id],
                            playbackService: playbackService,
                            onTapPlay: {
                                Task {
                                    await viewModel.playFriendAnswer(at: index)
                                }
                            },
                            onReaction: { reactionType in
                                Task {
                                    await viewModel.addReaction(type: reactionType, toAnswerId: friendAnswer.id)
                                }
                            }
                        )
                    }
                }

                // Summary section (always visible at bottom of scroll)
                summarySection
                    .padding(.top, 8)

                // Bottom spacing
                Spacer()
                    .frame(height: 24)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Reveal Header

    private var revealHeader: some View {
        VStack(spacing: 8) {
            Text("Friends' Answers")
                .font(.title2)
                .fontWeight(.bold)

            Text("Listen to what your friends think")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Waiting for Friends

    private var waitingForFriendsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: -12) {
                ForEach(0..<3, id: \.self) { index in
                    PulsingAvatarCircle(delay: Double(index) * 0.3)
                }
            }

            Text("Waiting for friends...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Your friends haven't answered yet. Check back later!")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 48)
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(spacing: 16) {
            // Stats card
            VStack(spacing: 12) {
                let answeredCount = viewModel.friendAnswers.count
                let totalCount = max(answeredCount, 1)

                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.blue)
                    Text("\(answeredCount) of \(totalCount) friends answered today")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                if let randomFriend = viewModel.friendAnswers.first?.friend {
                    let firstName = randomFriend.displayName.components(separatedBy: " ").first ?? randomFriend.displayName
                    Text("You and \(firstName) might agree on this one")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            // Share button (placeholder)
            Button {
                viewModel.showShareAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Your Take")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.accentColor, lineWidth: 1.5)
                )
            }

            // Done button
            Button {
                viewModel.dismiss()
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor)
                    )
            }
        }
    }
}

// MARK: - Celebration Overlay

/// Animated celebration view shown briefly after answer submission
private struct CelebrationOverlay: View {
    @State private var checkmarkScale: CGFloat = 0.3
    @State private var checkmarkOpacity: Double = 0
    @State private var confettiVisible: Bool = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // Confetti-like emoji particles
            if confettiVisible {
                ForEach(0..<12, id: \.self) { index in
                    ConfettiParticle(
                        emoji: confettiEmojis[index % confettiEmojis.count],
                        index: index
                    )
                }
            }

            // Center content
            VStack(spacing: 24) {
                // Green checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)

                Text("Your answer is in!")
                    .font(.title)
                    .fontWeight(.bold)
                    .opacity(checkmarkOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                confettiVisible = true
            }
        }
    }

    private var confettiEmojis: [String] {
        ["...", "...", "..."]
    }
}

// MARK: - Confetti Particle

/// A single confetti particle emoji that scales up and fades out
private struct ConfettiParticle: View {
    let emoji: String
    let index: Int

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 1.0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0

    // Deterministic positions based on index
    private var targetX: CGFloat {
        let positions: [CGFloat] = [-120, -80, -40, 0, 40, 80, 120, -100, -60, 60, 100, -20]
        return positions[index % positions.count]
    }

    private var targetY: CGFloat {
        let positions: [CGFloat] = [-180, -140, -200, -160, -190, -130, -170, -150, -210, -120, -185, -145]
        return positions[index % positions.count]
    }

    private var particleEmoji: String {
        let emojis = ["*", "*", "*", "*", "*", "*"]
        return emojis[index % emojis.count]
    }

    var body: some View {
        Text(particleEmoji)
            .font(.system(size: 28))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: offsetX, y: offsetY)
            .onAppear {
                let delay = Double(index) * 0.05
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    scale = 1.2
                    offsetX = targetX
                    offsetY = targetY
                }
                withAnimation(.easeIn(duration: 0.4).delay(delay + 0.5)) {
                    opacity = 0
                    scale = 0.5
                }
            }
    }
}

// MARK: - Pulsing Avatar Circle

/// Pulsing placeholder avatar circle for "waiting for friends" state
private struct PulsingAvatarCircle: View {
    let delay: Double
    @State private var isPulsing: Bool = false

    var body: some View {
        Circle()
            .fill(Color(.systemGray4))
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(.systemGray2))
            )
            .scaleEffect(isPulsing ? 1.1 : 0.95)
            .opacity(isPulsing ? 0.8 : 0.5)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Reveal Friend Answer Card

/// Card for a single friend answer in the reveal view
/// Expands to show audio player and reaction buttons after playing
private struct RevealFriendAnswerCard: View {
    let friendAnswer: FriendAnswer
    let index: Int
    let isPlaying: Bool
    let isAnyPlaying: Bool
    let hasBeenPlayed: Bool
    let currentReaction: ReactionType?
    let playbackService: AudioPlaybackServiceProtocol
    let onTapPlay: () -> Void
    let onReaction: (ReactionType) -> Void

    @State private var reactionAnimatingType: ReactionType?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content
            Button {
                onTapPlay()
            } label: {
                mainCardContent
            }
            .buttonStyle(.plain)

            // Expanded audio player area (when playing)
            if isPlaying, let audioURL = friendAnswer.answer.audioFileURL {
                AudioPlayerView(
                    playbackService: playbackService,
                    url: audioURL
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Reaction buttons (visible after playing)
            if hasBeenPlayed {
                reactionButtonRow
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isPlaying ? Color(.secondarySystemGroupedBackground) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isPlaying ? Color.accentColor.opacity(0.4) : Color(.systemGray5),
                    lineWidth: isPlaying ? 1.5 : 1
                )
        )
        .opacity(isAnyPlaying && !isPlaying ? 0.6 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPlaying)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: hasBeenPlayed)
    }

    // MARK: - Main Card Content

    private var mainCardContent: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Image(systemName: friendAnswer.friend.avatarImageName ?? "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
                    .clipShape(Circle())

                // "New" badge for unplayed answers
                if !hasBeenPlayed {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .offset(x: 18, y: -18)
                }
            }

            // Name and status
            VStack(alignment: .leading, spacing: 3) {
                Text(friendAnswer.friend.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    if isPlaying {
                        Image(systemName: "waveform")
                            .font(.caption2)
                            .foregroundStyle(Color.accentColor)
                        Text("Now playing")
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Image(systemName: "play.circle")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("Tap to play")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Duration
            Text(formatDuration(friendAnswer.answer.duration))
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }

    // MARK: - Reaction Buttons

    private var reactionButtonRow: some View {
        HStack(spacing: 8) {
            ForEach(ReactionType.allCases, id: \.self) { type in
                reactionButton(for: type)
            }
        }
    }

    private func reactionButton(for type: ReactionType) -> some View {
        let isSelected = currentReaction == type
        let isAnimating = reactionAnimatingType == type

        return Button {
            reactionAnimatingType = type
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {}
            onReaction(type)

            // Reset animation after brief delay
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                reactionAnimatingType = nil
            }
        } label: {
            VStack(spacing: 2) {
                Text(type.emoji)
                    .font(.title3)
                    .scaleEffect(isAnimating ? 1.4 : 1.0)
                Text(type.displayName)
                    .font(.system(size: 9))
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Reveal - With Friends") {
    AnswerRevealView(
        viewModel: AnswerRevealViewModel(
            questionId: "q-mock-today",
            voiceAnswerRepository: MockVoiceAnswerRepository(),
            reactionRepository: MockReactionRepository(),
            playbackService: MockAudioPlaybackService()
        ),
        playbackService: MockAudioPlaybackService()
    )
}

#Preview("Reveal - Celebration") {
    CelebrationOverlay()
}
#endif
