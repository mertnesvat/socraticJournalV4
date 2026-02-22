// FriendAvatarRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal scroll row of friend avatar circles with locked/unlocked overlay
/// Shows which friends have answered the daily question
public struct FriendAvatarRow: View {
    public let friendAnswers: [FriendAnswer]
    public let isUnlocked: Bool

    public init(friendAnswers: [FriendAnswer], isUnlocked: Bool) {
        self.friendAnswers = friendAnswers
        self.isUnlocked = isUnlocked
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Friends who answered")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(friendAnswers.count) friends answered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Horizontal avatar scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(friendAnswers) { friendAnswer in
                        avatarItem(for: friendAnswer)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Subviews

    private func avatarItem(for friendAnswer: FriendAnswer) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Image(systemName: friendAnswer.friend.avatarImageName ?? "person.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
                    .clipShape(Circle())

                // Lock overlay when not unlocked
                if !isUnlocked {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }

            Text(friendAnswer.friend.displayName.components(separatedBy: " ").first ?? friendAnswer.friend.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 60)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        FriendAvatarRow(
            friendAnswers: [
                FriendAnswer(
                    answer: VoiceAnswer(questionId: "q1", userId: "u1", duration: 15),
                    friend: UserProfile(displayName: "Alice Smith", username: "alice"),
                    isUnlocked: false
                ),
                FriendAnswer(
                    answer: VoiceAnswer(questionId: "q1", userId: "u2", duration: 22),
                    friend: UserProfile(displayName: "Bob Jones", username: "bob"),
                    isUnlocked: false
                ),
            ],
            isUnlocked: false
        )

        FriendAvatarRow(
            friendAnswers: [
                FriendAnswer(
                    answer: VoiceAnswer(questionId: "q1", userId: "u1", duration: 15),
                    friend: UserProfile(displayName: "Alice Smith", username: "alice"),
                    isUnlocked: true
                ),
            ],
            isUnlocked: true
        )
    }
    .padding()
}
#endif
