// OnboardingViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel managing onboarding flow state and completion logic
@Observable
@MainActor
public final class OnboardingViewModel {
    // MARK: - State

    var currentPage: Int = 0
    private(set) var isCompleting: Bool = false
    private(set) var error: Error?

    /// Total number of onboarding pages
    let totalPages: Int = 3

    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let onDismiss: () -> Void

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
        self.onDismiss = onDismiss
    }

    // MARK: - Actions

    /// Advance to the next page
    func nextPage() {
        guard currentPage < totalPages - 1 else { return }
        currentPage += 1
    }

    /// Navigate to a specific page (used by TabView binding)
    func setPage(_ page: Int) {
        guard page >= 0 && page < totalPages else { return }
        currentPage = page
    }

    /// Log that onboarding has started
    func logOnboardingStarted() {
        analyticsService.logEvent(.onboardingStarted, parameters: nil)
    }

    /// Complete onboarding: save settings, log analytics, dismiss
    func completeOnboarding() async {
        isCompleting = true
        error = nil

        do {
            var settings = try await settingsRepository.getSettings()
            settings.hasCompletedOnboarding = true
            try await settingsRepository.saveSettings(settings)
            analyticsService.logEvent(.onboardingCompleted, parameters: nil)
        } catch {
            self.error = error
            print("Failed to save onboarding completion: \(error)")
        }

        isCompleting = false
        onDismiss()
    }
}
#endif
