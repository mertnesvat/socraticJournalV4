// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 3-page swipeable onboarding — Breathe Better, Science, Get Started
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
        TabView(selection: $currentPage) {
            OnboardingBreathePage()
                .tag(0)

            OnboardingSciencePage()
                .tag(1)

            OnboardingStartPage {
                completeOnboarding()
            }
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
                print("Failed to save onboarding completion: \(error)")
            }
            await MainActor.run {
                onDismiss()
            }
        }
    }
}
#endif
