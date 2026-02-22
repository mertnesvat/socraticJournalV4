// FriendRequestRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A row displaying a pending friend request with accept and decline buttons — structured minimalism style
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
        VStack(spacing: 0) {
            HStack(spacing: AppSpacing.sm) {
                // Small circular avatar (32pt)
                Circle()
                    .fill(avatarColor.opacity(0.15))
                    .frame(width: AppSpacing.avatarSmall, height: AppSpacing.avatarSmall)
                    .overlay(
                        Text(initial)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(avatarColor)
                    )

                // Name and username
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.displayName)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    Text("@\(user.username)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Action buttons — compact
                HStack(spacing: AppSpacing.xs) {
                    Button {
                        onAccept()
                    } label: {
                        Text("Accept")
                            .font(AppTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textOnAccent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(AppColors.accent)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDecline()
                    } label: {
                        Text("Decline")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.md)

            // Hairline bottom border
            HairlineDivider()
                .padding(.leading, AppSpacing.screenPadding + AppSpacing.avatarSmall + AppSpacing.sm)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
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
    .background(AppColors.background)
}
#endif
