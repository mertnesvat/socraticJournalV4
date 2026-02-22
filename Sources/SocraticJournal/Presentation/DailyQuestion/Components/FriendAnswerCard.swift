// FriendAnswerCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card displaying a single friend's answer with avatar, name, and audio player
/// Shows either a locked state or the MiniAudioPlayerView when unlocked
public struct FriendAnswerCard: View {
    public let friendAnswer: FriendAnswer
    public let playbackService: AudioPlaybackServiceProtocol

    public init(friendAnswer: FriendAnswer, playbackService: AudioPlaybackServiceProtocol) {
        self.friendAnswer = friendAnswer
        self.playbackService = playbackService
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Image(systemName: friendAnswer.friend.avatarImageName ?? "person.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color(.systemGray5))
                )
                .clipShape(Circle())

            // Name and description
            VStack(alignment: .leading, spacing: 2) {
                Text(friendAnswer.friend.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if friendAnswer.isUnlocked {
                    Text("Hear \(friendAnswer.friend.displayName.components(separatedBy: " ").first ?? friendAnswer.friend.displayName)'s take")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Answer to unlock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Audio player or lock
            if friendAnswer.isUnlocked {
                if let audioURL = friendAnswer.answer.audioFileURL {
                    MiniAudioPlayerView(
                        playbackService: playbackService,
                        url: audioURL,
                        duration: friendAnswer.answer.duration
                    )
                    .frame(width: 140)
                } else {
                    // No audio file available; show duration label with disabled state
                    durationOnlyView
                }
            } else {
                lockedView
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Subviews

    private var lockedView: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.caption)
            Text(formatDuration(friendAnswer.answer.duration))
                .font(.caption2)
                .fontDesign(.monospaced)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }

    private var durationOnlyView: some View {
        HStack(spacing: 6) {
            Image(systemName: "waveform")
                .font(.caption)
            Text(formatDuration(friendAnswer.answer.duration))
                .font(.caption2)
                .fontDesign(.monospaced)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        FriendAnswerCard(
            friendAnswer: FriendAnswer(
                answer: VoiceAnswer(questionId: "q1", userId: "u1", duration: 22),
                friend: UserProfile(displayName: "Alice Smith", username: "alice"),
                isUnlocked: true
            ),
            playbackService: MockAudioPlaybackService(duration: 22)
        )

        FriendAnswerCard(
            friendAnswer: FriendAnswer(
                answer: VoiceAnswer(questionId: "q1", userId: "u2", duration: 18),
                friend: UserProfile(displayName: "Bob Jones", username: "bob"),
                isUnlocked: false
            ),
            playbackService: MockAudioPlaybackService(duration: 18)
        )
    }
    .padding()
}
#endif
