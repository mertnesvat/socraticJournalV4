// OnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Parent container view that manages all onboarding screens with paging navigation
/// Provides horizontal swipe navigation and custom page indicator dots
public struct OnboardingView: View {
    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let onDismiss: () -> Void

    // MARK: - State

    @State private var currentPage: Int = 0

    // MARK: - Constants

    private let totalPages = 5

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Page content with swipe navigation
            TabView(selection: $currentPage) {
                OnboardingWelcomeView(
                    onContinue: { advanceToNextPage() },
                    onSkip: { completeOnboarding() }
                )
                .tag(0)

                OnboardingGuidedReflectionView(
                    onContinue: { advanceToNextPage() },
                    onSkip: { completeOnboarding() }
                )
                .tag(1)

                OnboardingCharacterView(
                    onContinue: { advanceToNextPage() },
                    onSkip: { completeOnboarding() }
                )
                .tag(2)

                OnboardingSelfDiscoveryView(
                    onContinue: { advanceToNextPage() },
                    onSkip: { completeOnboarding() }
                )
                .tag(3)

                OnboardingLettersView(
                    onComplete: { completeOnboarding() },
                    onSkip: { completeOnboarding() }
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Custom page indicator
            pageIndicator
                .padding(.bottom, 100)
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.4))
                    .frame(
                        width: index == currentPage ? 10 : 8,
                        height: index == currentPage ? 10 : 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    // MARK: - Actions

    private func advanceToNextPage() {
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
                // Log onboarding completion analytics
                analyticsService.logEvent(.onboardingCompleted, parameters: nil)
            } catch {
                // Log error but still dismiss - user should not be stuck on onboarding
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
    OnboardingView(
        settingsRepository: PreviewSettingsRepository(),
        onDismiss: { print("Onboarding dismissed") }
    )
}

// MARK: - Preview Helper

private final class PreviewSettingsRepository: SettingsRepositoryProtocol {
    func getSettings() async throws -> UserSettings {
        UserSettings.default
    }

    func saveSettings(_ settings: UserSettings) async throws {
        // No-op for preview
    }

    func resetSettings() async throws {
        // No-op for preview
    }

    func clearAllData() async throws {
        // No-op for preview
    }
}
#endif
