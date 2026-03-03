// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Simple placeholder onboarding — will be fully designed in Feature 5
public struct NewOnboardingView: View {
    @State private var currentPage: Int = 0
    private let settingsRepository: SettingsRepositoryProtocol
    private let onDismiss: () -> Void

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Text("Breathe")
                .font(AppTypography.displayLarge)
                .foregroundStyle(AppColors.textPrimary)

            Text("The most powerful health tool you already have")
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()

            AccentPillButton("Get Started") {
                completeOnboarding()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

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
#endif
