// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Placeholder onboarding view -- real onboarding built in Feature 9
public struct NewOnboardingView: View {
    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let onDismiss: () -> Void

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "wind")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.accent)

            Text("Welcome to Breath Pacer")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Find your calm with science-backed breathing techniques.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Spacer()

            AccentPillButton("Get Started") {
                completeOnboarding()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    // MARK: - Actions

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
            } catch {
                print("Failed to save onboarding completion: \(error)")
            }
            await MainActor.run {
                onDismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewOnboardingView(
        settingsRepository: UserDefaultsSettingsRepository(),
        onDismiss: { print("Onboarding dismissed") }
    )
}
#endif
