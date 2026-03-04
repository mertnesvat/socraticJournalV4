// OnboardingHookPage.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 1 — The Hook: a bold stat that grabs attention
struct OnboardingHookPage: View {
    let onNext: () -> Void

    private let navyBackground = Color(hex: "0B1426")

    var body: some View {
        ZStack {
            navyBackground.ignoresSafeArea()

            AmbientWaveView(
                color: .white,
                opacity: 0.15,
                amplitude: 30,
                frequency: 1.2
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: AppSpacing.md) {
                    Text("you breathe 25,000 times a day.")
                        .font(AppTypography.displayMedium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("most of them wrong.")
                        .font(AppTypography.headline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                Spacer()

                Button {
                    onNext()
                } label: {
                    Text("next")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(.white)
                        .padding(.vertical, AppSpacing.md)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
    }
}

#Preview {
    OnboardingHookPage(onNext: {})
}
#endif
