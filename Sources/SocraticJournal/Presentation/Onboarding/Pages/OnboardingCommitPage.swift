// OnboardingCommitPage.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 3 — The Commitment: a simple CTA to begin
struct OnboardingCommitPage: View {
    let isCompleting: Bool
    let onGetStarted: () -> Void

    var body: some View {
        ZStack {
            AppColors.accent.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: AppSpacing.md) {
                    Text("five minutes a day")
                        .font(AppTypography.displayLarge)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("that's all it takes to build the habit")
                        .font(AppTypography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                Spacer()

                // INVERTED button: white capsule with accent text
                Button {
                    onGetStarted()
                } label: {
                    Group {
                        if isCompleting {
                            ProgressView()
                                .tint(AppColors.accent)
                        } else {
                            Text("get started")
                                .font(AppTypography.bodyBold)
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isCompleting)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
    }
}

#Preview {
    OnboardingCommitPage(isCompleting: false, onGetStarted: {})
}
#endif
