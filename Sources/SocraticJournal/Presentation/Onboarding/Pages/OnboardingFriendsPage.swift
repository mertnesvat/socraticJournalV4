// OnboardingFriendsPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 4: "Better with friends" — yellow background with bold left-aligned typography.
/// The "Get Started" / "Find Friends" buttons are in NewOnboardingView's bottom controls.
public struct OnboardingFriendsPage: View {
    // MARK: - Callbacks

    let onFindFriends: () -> Void
    let onSkipForNow: () -> Void

    // MARK: - Init

    public init(
        onFindFriends: @escaping () -> Void,
        onSkipForNow: @escaping () -> Void
    ) {
        self.onFindFriends = onFindFriends
        self.onSkipForNow = onSkipForNow
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Yellow background
            AppColors.cardYellow
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                    .frame(height: AppSpacing.heroTopPadding)

                // Massive headline
                Text("Better with\nfriends")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)

                // Body copy
                Text("The real fun starts when you hear how differently your friends think.")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    OnboardingFriendsPage(
        onFindFriends: { print("Find friends") },
        onSkipForNow: { print("Skip") }
    )
}
#endif
