// OnboardingBreathePage.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 1: "You breathe 25,000 times a day."
/// Animated mountain wave preview at resonant pace
struct OnboardingBreathePage: View {
    @State private var demoProgress: Double = 0
    @State private var demoTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mountain wave demo
            MountainWaveView(
                cycleProgress: demoProgress,
                currentPhase: demoProgress <= 0.5 ? .inhale : .exhale,
                phaseProgress: demoProgress <= 0.5 ? demoProgress / 0.5 : (demoProgress - 0.5) / 0.5,
                color: AppColors.cardTeal,
                isDemo: true
            )
            .frame(height: 120)
            .padding(.horizontal, AppSpacing.xl)

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Text("You breathe 25,000\ntimes a day.")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Most of them wrong.")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .onAppear { startDemoAnimation() }
        .onDisappear { demoTimer?.invalidate() }
    }

    private func startDemoAnimation() {
        let cycleDuration: Double = 11.0 // 5.5s in + 5.5s out
        let updateInterval: Double = 1.0 / 30.0

        demoTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            Task { @MainActor in
                demoProgress += updateInterval / cycleDuration
                if demoProgress >= 1.0 {
                    demoProgress = 0
                }
            }
        }
    }
}
#endif
