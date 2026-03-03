// OnboardingStartPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 3 — "Just 5 Minutes a Day" with Get Started button
struct OnboardingStartPage: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Text("Just 5 Minutes\na Day")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Track your practice. Learn the science.\nBreathe with intention.")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }

            Spacer()

            Button {
                onGetStarted()
            } label: {
                Text("Get Started")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.accent)
    }
}
#endif
