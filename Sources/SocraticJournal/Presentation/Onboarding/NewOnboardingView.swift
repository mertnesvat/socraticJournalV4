// NewOnboardingView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 3-page swipeable onboarding for the Breath Pacer app
public struct NewOnboardingView: View {
    let settingsRepository: SettingsRepositoryProtocol
    let onDismiss: () -> Void
    @State private var currentPage: Int = 0

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.onDismiss = onDismiss
    }

    public var body: some View {
        TabView(selection: $currentPage) {
            OnboardingBreathePage()
                .tag(0)

            OnboardingSciencePage()
                .tag(1)

            OnboardingStartPage(onGetStarted: completeOnboarding)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
            } catch {
                // Proceed anyway
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
        onDismiss: {}
    )
}
#endif
