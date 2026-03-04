// NewOnboardingView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct NewOnboardingView: View {
    @State private var currentPage: Int = 0
    let settingsRepository: SettingsRepositoryProtocol
    let onDismiss: () -> Void

    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage1.tag(0)
            onboardingPage2.tag(1)
            onboardingPage3.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }

    // MARK: - Page 1: Breathe Better

    private var onboardingPage1: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Breathe Better")
                .font(AppTypography.displayLarge)
                .foregroundStyle(AppColors.textPrimary)

            Text("The most powerful health tool you already have")
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            MountainWaveView(
                phase: .inhale,
                progress: 0.5,
                isDemo: true
            )
            .padding(.bottom, 20)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    // MARK: - Page 2: Ancient Wisdom, Modern Science

    private var onboardingPage2: some View {
        VStack(alignment: .leading, spacing: 32) {
            Spacer()

            Text("Ancient Wisdom,\nModern Science")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 20) {
                techniqueRow("Resonance", "The perfect breath")
                techniqueRow("Box Breathing", "Navy SEAL focus")
                techniqueRow("4-7-8", "Natural tranquilizer")
                techniqueRow("Cyclic Sighing", "Stanford\u{2019}s stress reset")
            }
            .padding(.horizontal, 32)

            Text("Each backed by research.\nGuided by a simple visual.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    private func techniqueRow(_ name: String, _ subtitle: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.accent)
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    // MARK: - Page 3: Just 5 Minutes a Day

    private var onboardingPage3: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Just 5 Minutes\na Day")
                .font(AppTypography.displayLarge)
                .foregroundStyle(AppColors.surface)
                .multilineTextAlignment(.center)

            Text("Track your practice. Learn the science.\nBreathe with intention.")
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.surface.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                completeOnboarding()
            } label: {
                Text("GET STARTED")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(AppColors.surface))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.accent)
    }

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
            } catch {}
            await MainActor.run { onDismiss() }
        }
    }
}
#endif
