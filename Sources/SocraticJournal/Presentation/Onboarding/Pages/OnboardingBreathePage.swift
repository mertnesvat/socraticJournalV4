// OnboardingBreathePage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 1 — "Breathe Better" with animated demo circle
struct OnboardingBreathePage: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            DemoBreathCircle(color: AppColors.cardTeal)
                .frame(height: 220)

            VStack(spacing: AppSpacing.sm) {
                Text("Breathe Better")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(AppColors.textPrimary)

                Text("The most powerful health tool you already have")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
#endif
