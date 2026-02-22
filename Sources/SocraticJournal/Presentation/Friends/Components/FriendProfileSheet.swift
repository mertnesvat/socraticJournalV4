// FriendProfileSheet.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Bottom sheet displaying a friend's mini profile — structured minimalism style
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
        VStack(spacing: 0) {
            // Header — name and username, left-aligned
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(friend.displayName)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text("@\(friend.username)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)

            HairlineDivider()

            // Stats row
            HStack(spacing: 0) {
                statItem(
                    value: "\(sharedQuestionsCount)",
                    label: "Shared"
                )

                HairlineDivider(axis: .vertical)
                    .frame(height: 48)

                statItem(
                    value: "\(agreementPercentage)%",
                    label: "Agree"
                )

                HairlineDivider(axis: .vertical)
                    .frame(height: 48)

                statItem(
                    value: "\(sharedStreakDays)",
                    label: "Streak"
                )
            }
            .padding(.vertical, AppSpacing.lg)

            HairlineDivider()

            // Friend info
            HStack(spacing: AppSpacing.md) {
                Label("\(friend.streakCount) day streak", systemImage: "flame.fill")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.warning)

                Label("\(friend.friendCount) friends", systemImage: "person.2.fill")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.md)

            Spacer()

            // Remove Friend — text link
            Button(role: .destructive) {
                showingRemoveConfirmation = true
            } label: {
                Text("Remove Friend")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.error)
            }
            .buttonStyle(.plain)
            .padding(.bottom, AppSpacing.xl)
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
        .background(AppColors.background)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
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
