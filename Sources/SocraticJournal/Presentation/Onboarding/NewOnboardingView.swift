// NewOnboardingView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Onboarding placeholder — will be fully implemented in Feature 9
public struct NewOnboardingView: View {
    @State private var currentPage: Int = 0

    private let settingsRepository: SettingsRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let onDismiss: () -> Void

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "wind")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.accent)

            VStack(spacing: AppSpacing.sm) {
                Text("Breathe")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Science-backed breathing companion")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            AccentPillButton("Get Started") {
                completeOnboarding()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .onAppear {
            analyticsService.logEvent(.onboardingStarted, parameters: nil)
        }
    }

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
                analyticsService.logEvent(.onboardingCompleted, parameters: nil)
            } catch {
                print("Failed to save onboarding completion: \(error)")
            }
            await MainActor.run {
                onDismiss()
            }
        }
    }
}

#Preview {
    NewOnboardingView(
        settingsRepository: UserDefaultsSettingsRepository(),
        onDismiss: {}
    )
}
#endif
