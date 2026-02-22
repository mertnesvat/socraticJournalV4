// FriendRequestRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A row displaying a pending friend request with accept and decline buttons
public struct FriendRequestRow: View {
    let user: User
    let onAccept: () -> Void
    let onDecline: () -> Void

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
            // Avatar
            Circle()
                .fill(avatarColor.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(initial)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(avatarColor)
                )

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

            // Action buttons
            HStack(spacing: 8) {
                Button {
                    onAccept()
                } label: {
                    Text("Accept")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    onDecline()
                } label: {
                    Text("Decline")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        FriendRequestRow(
            user: MockDataProvider.friends[0],
            onAccept: {},
            onDecline: {}
        )
        FriendRequestRow(
            user: MockDataProvider.friends[1],
            onAccept: {},
            onDecline: {}
        )
    }
}
#endif
