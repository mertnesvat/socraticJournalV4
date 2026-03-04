// OnboardingStartPage.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 3: "Just 5 Minutes a Day" — coral background, Get Started CTA
struct OnboardingStartPage: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: AppSpacing.md) {
                Text("Just 5 Minutes\na Day")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Track your practice.\nLearn the science.\nBreathe with intention.")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()

            // Get Started button — white pill with accent text
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule().fill(.white)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.accent)
    }
}
#endif
