// FriendsGateView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Progress indicator for the "3 Friends Gate" — structured minimalism style
public struct FriendsGateView: View {
    let currentFriendCount: Int
    let requiredCount: Int

    private var remaining: Int {
        max(0, requiredCount - currentFriendCount)
    }

    private var gateText: String {
        switch remaining {
        case 0:
            return "All reveals unlocked"
        case 1:
            return "Add 1 more friend to unlock reveals"
        default:
            return "Add \(remaining) more friends to unlock reveals"
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            HairlineDivider()

            VStack(spacing: AppSpacing.md) {
                // Gate text
                Text(gateText)
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Friend slot circles
                HStack(spacing: AppSpacing.sm) {
                    ForEach(0..<requiredCount, id: \.self) { index in
                        Circle()
                            .fill(index < currentFriendCount ? AppColors.accent : Color.clear)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Group {
                                    if index < currentFriendCount {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.textOnAccent)
                                    } else {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(AppColors.textTertiary)
                                    }
                                }
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        index < currentFriendCount ? AppColors.accent : AppColors.borderStrong,
                                        lineWidth: 1.5
                                    )
                            )
                    }

                    Spacer()
                }

                // Invite link
                if remaining > 0 {
                    Text("Invite Friends")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.lg)

            HairlineDivider()
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        FriendsGateView(currentFriendCount: 0, requiredCount: 3)
        FriendsGateView(currentFriendCount: 1, requiredCount: 3)
        FriendsGateView(currentFriendCount: 2, requiredCount: 3)
    }
    .background(AppColors.background)
}
#endif
