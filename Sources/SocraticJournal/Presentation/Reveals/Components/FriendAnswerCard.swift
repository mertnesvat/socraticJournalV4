// FriendAnswerCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A card displaying a friend's answer reveal -- locked, unlocked, or currently playing
public struct FriendAnswerCard: View {
    let reveal: AnswerReveal
    let friend: User?
    let answer: VoiceAnswer?
    let isPlaying: Bool
    let reaction: String?
    let onTap: () -> Void
    let onReaction: (String) -> Void

    /// Color for the avatar background based on the friend's display name
    private var avatarColor: Color {
        let colors: [Color] = [
            .blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
        ]
        let name = friend?.displayName ?? "?"
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }

    /// First letter of the friend's display name
    private var initial: String {
        guard let name = friend?.displayName, !name.isEmpty else { return "?" }
        return String(name.prefix(1)).uppercased()
    }

    /// Whether this answer was posted within the last 24 hours
    private var isNew: Bool {
        guard let answer = answer else {
            // For locked reveals, check mock data for recency
            if let mockAnswer = MockDataProvider.voiceAnswers.first(where: { $0.id == reveal.friendAnswerId }) {
                return mockAnswer.createdAt.timeIntervalSinceNow > -86400
            }
            return false
        }
        return answer.createdAt.timeIntervalSinceNow > -86400
    }

    /// Relative time string for when the answer was created
    private var timeAgoText: String {
        let date: Date
        if let answer = answer {
            date = answer.createdAt
        } else if let mockAnswer = MockDataProvider.voiceAnswers.first(where: { $0.id == reveal.friendAnswerId }) {
            date = mockAnswer.createdAt
        } else {
            return ""
        }

        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }

    /// Duration text from the voice answer
    private var durationText: String {
        let duration: TimeInterval
        if let answer = answer {
            duration = answer.duration
        } else if let mockAnswer = MockDataProvider.voiceAnswers.first(where: { $0.id == reveal.friendAnswerId }) {
            duration = mockAnswer.duration
        } else {
            return "--:--"
        }

        let totalSeconds = Int(max(0, duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Main card content
            mainCardContent
                .contentShape(Rectangle())
                .onTapGesture { onTap() }

            // Expanded player when playing
            if isPlaying && reveal.isUnlocked {
                FriendAnswerPlayer(
                    answer: answer,
                    isPlaying: isPlaying,
                    onPlayPause: onTap
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Emoji reaction bar when playing
            if isPlaying && reveal.isUnlocked {
                EmojiReactionBar(
                    selectedEmoji: reaction,
                    onSelect: onReaction
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity)
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: isPlaying ? 1.5 : 0.5)
        )
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
    }

    // MARK: - Main Card Content

    private var mainCardContent: some View {
        HStack(spacing: 12) {
            // Avatar
            avatarView

            // Friend info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(friend?.displayName ?? "Friend")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(reveal.isUnlocked ? .primary : .secondary)
                        .lineLimit(1)

                    if isNew && reveal.isUnlocked {
                        Text("NEW")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(.blue)
                            )
                    }
                }

                HStack(spacing: 8) {
                    Text(timeAgoText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Text(durationText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }
            }

            Spacer()

            // Right side: lock or play button
            rightAccessory

            // Show selected reaction if any and not currently playing
            if let reaction = reaction, !isPlaying {
                Text(reaction)
                    .font(.title3)
            }
        }
        .padding(12)
        .frame(minHeight: 80)
    }

    // MARK: - Avatar

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(reveal.isUnlocked ? avatarColor.opacity(0.3) : Color(.systemGray4))
                .frame(width: 44, height: 44)
                .overlay(
                    Group {
                        if reveal.isUnlocked {
                            Text(initial)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(avatarColor)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(.systemGray2))
                        }
                    }
                )
        }
    }

    // MARK: - Right Accessory

    @ViewBuilder
    private var rightAccessory: some View {
        if !reveal.isUnlocked {
            // Locked state
            Image(systemName: "lock.fill")
                .font(.body)
                .foregroundStyle(Color(.systemGray3))
                .frame(width: 36, height: 36)
        } else if isPlaying {
            // Playing state
            Image(systemName: "pause.fill")
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(.blue.opacity(0.15))
                )
        } else {
            // Unlocked, not playing
            Image(systemName: "play.fill")
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(.blue.opacity(0.1))
                )
        }
    }

    // MARK: - Card Styling

    private var cardBackground: some View {
        Group {
            if isPlaying {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            } else if reveal.isUnlocked {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.7))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.4))
            }
        }
    }

    private var borderColor: Color {
        if isPlaying {
            return .blue.opacity(0.4)
        } else if reveal.isUnlocked {
            return Color(.systemGray4).opacity(0.3)
        } else {
            return Color(.systemGray5).opacity(0.2)
        }
    }
}

// MARK: - Preview

#Preview("Unlocked") {
    VStack(spacing: 12) {
        FriendAnswerCard(
            reveal: MockDataProvider.answerReveals[0],
            friend: MockDataProvider.friends[0],
            answer: MockDataProvider.voiceAnswers[3],
            isPlaying: false,
            reaction: nil,
            onTap: {},
            onReaction: { _ in }
        )

        FriendAnswerCard(
            reveal: MockDataProvider.answerReveals[0],
            friend: MockDataProvider.friends[0],
            answer: MockDataProvider.voiceAnswers[3],
            isPlaying: true,
            reaction: nil,
            onTap: {},
            onReaction: { _ in }
        )
    }
    .padding()
    .background(Color.black)
}

#Preview("Locked") {
    FriendAnswerCard(
        reveal: MockDataProvider.answerReveals[1],
        friend: MockDataProvider.friends[1],
        answer: nil,
        isPlaying: false,
        reaction: nil,
        onTap: {},
        onReaction: { _ in }
    )
    .padding()
    .background(Color.black)
}

#endif
