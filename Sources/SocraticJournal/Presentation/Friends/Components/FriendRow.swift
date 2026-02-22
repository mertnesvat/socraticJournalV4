// FriendRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A row displaying a friend with avatar, name, username, streak, and online status
public struct FriendRow: View {
    let user: User

    /// Deterministic "online" status based on user ID hash for mock consistency
    private var isOnline: Bool {
        user.id.hashValue % 3 == 0
    }

    /// Deterministic "last active" text based on user properties
    private var lastActiveText: String {
        let options = ["now", "2m ago", "15m ago", "1h ago", "3h ago"]
        let index = abs(user.id.hashValue) % options.count
        return options[index]
    }

    /// Color for the avatar background based on the user's initial
    private var avatarColor: Color {
        let colors: [Color] = [
            .blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
        ]
        let index = abs(user.displayName.hashValue) % colors.count
        return colors[index]
    }

    /// First letter of the display name
    private var initial: String {
        String(user.displayName.prefix(1)).uppercased()
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Avatar with online indicator
            avatarView

            // Name and username
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Streak and last active
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("\(user.streakCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("🔥")
                        .font(.caption)
                }

                Text(lastActiveText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(avatarColor.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(initial)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(avatarColor)
                )

            // Online status dot
            if isOnline {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
}

#Preview {
    List {
        FriendRow(user: MockDataProvider.friends[0])
        FriendRow(user: MockDataProvider.friends[1])
        FriendRow(user: MockDataProvider.friends[2])
    }
}
#endif
