// FriendRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A row displaying a friend with avatar, name, username — structured minimalism style
public struct FriendRow: View {
    let user: User

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

                // Subtle chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
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
        FriendRow(user: MockDataProvider.friends[0])
        FriendRow(user: MockDataProvider.friends[1])
        FriendRow(user: MockDataProvider.friends[2])
    }
    .background(AppColors.background)
}
#endif
