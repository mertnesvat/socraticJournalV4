// FriendProfileSheet.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Bottom sheet displaying a friend's mini profile with stats and remove option
public struct FriendProfileSheet: View {
    let friend: User
    let onRemoveFriend: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingRemoveConfirmation: Bool = false

    /// Color for the avatar background based on the user's initial
    private var avatarColor: Color {
        let colors: [Color] = [
            .blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
        ]
        let index = abs(friend.displayName.hashValue) % colors.count
        return colors[index]
    }

    /// First letter of the display name
    private var initial: String {
        String(friend.displayName.prefix(1)).uppercased()
    }

    // Mock shared stats
    private var sharedQuestionsCount: Int {
        abs(friend.id.hashValue) % 20 + 3
    }

    private var agreementPercentage: Int {
        abs(friend.id.hashValue) % 40 + 45
    }

    private var sharedStreakDays: Int {
        min(friend.streakCount, abs(friend.id.hashValue) % 10 + 1)
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Drag indicator handled by presentationDragIndicator

            // Avatar
            Circle()
                .fill(avatarColor.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(initial)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(avatarColor)
                )
                .padding(.top, 8)

            // Name and username
            VStack(spacing: 4) {
                Text(friend.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("@\(friend.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Stats row
            HStack(spacing: 0) {
                statItem(
                    value: "\(sharedQuestionsCount)",
                    label: "Shared Questions"
                )

                Divider()
                    .frame(height: 36)

                statItem(
                    value: "\(agreementPercentage)%",
                    label: "Agree"
                )

                Divider()
                    .frame(height: 36)

                statItem(
                    value: "\(sharedStreakDays) day",
                    label: "Streak Together"
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            // Friend info
            HStack(spacing: 16) {
                Label("\(friend.streakCount) day streak", systemImage: "flame.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)

                Label("\(friend.friendCount) friends", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Remove Friend button
            Button(role: .destructive) {
                showingRemoveConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.minus")
                    Text("Remove Friend")
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .confirmationDialog(
                "Remove \(friend.displayName)?",
                isPresented: $showingRemoveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove Friend", role: .destructive) {
                    onRemoveFriend()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will no longer see each other's answers. You can send a new friend request later.")
            }
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FriendProfileSheet(
        friend: MockDataProvider.friends[0],
        onRemoveFriend: {}
    )
}
#endif
