// OnboardingWelcomePage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 1: Welcome page — warm cream background with massive left-aligned typography.
/// No icons, no images. Typography IS the visual.
public struct OnboardingWelcomePage: View {
    // MARK: - Body

    public var body: some View {
        ZStack {
            // Cream background
            AppColors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                    .frame(height: AppSpacing.heroTopPadding)

                // Massive headline
                Text("Welcome to\nSocratic")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)

                // Body copy
                Text("Your voice matters. Answer bold questions. Hear what your friends think.")
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
    OnboardingWelcomePage()
}
#endif
