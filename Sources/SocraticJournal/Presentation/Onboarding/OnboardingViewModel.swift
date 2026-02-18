// OnboardingViewModel.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel managing onboarding flow state and analytics.
/// Tracks page navigation and persists completion via SettingsRepository.
@Observable
@MainActor
public final class OnboardingViewModel {
    // MARK: - State

    /// Current page index in the onboarding flow (0-based).
    var currentPage: Int = 0

    /// Whether the onboarding flow has been completed or skipped.
    private(set) var isCompleted: Bool = false

    /// Total number of onboarding screens (excluding profile setup).
    let pageCount = 3

    /// Whether the skip button should be visible on the current page.
    var showsSkipButton: Bool {
        currentPage >= 2
    }

    /// Whether the current page is the last onboarding screen.
    var isLastPage: Bool {
        currentPage == pageCount - 1
    }

    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    /// Called when a screen becomes visible. Logs the view event.
    func screenViewed(index: Int) {
        analyticsService.logEvent(.onboardingScreenViewed, parameters: [
            AnalyticsParameter.screenName.rawValue: "onboarding_\(index)"
        ])

        if index == 0 {
            analyticsService.logEvent(.onboardingStarted, parameters: nil)
        }
    }

    /// Advances to the next page, or completes onboarding on the last page.
    func advanceOrComplete() {
        if isLastPage {
            completeOnboarding()
        } else {
            currentPage += 1
        }
    }

    /// Completes the onboarding flow and persists the flag.
    func completeOnboarding() {
        analyticsService.logEvent(.onboardingCompleted, parameters: [
            AnalyticsParameter.screenName.rawValue: "onboarding_\(currentPage)"
        ])
        persistCompletion()
    }

    /// Skips the onboarding flow from the current screen.
    func skipOnboarding() {
        analyticsService.logEvent(.onboardingSkipped, parameters: [
            AnalyticsParameter.screenName.rawValue: "onboarding_\(currentPage)"
        ])
        persistCompletion()
    }

    // MARK: - Private

    private func persistCompletion() {
        isCompleted = true
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
            } catch {
                // Completion flag is set in memory; persistence failure is non-critical.
                #if DEBUG
                print("[Onboarding] Failed to persist completion: \(error)")
                #endif
            }
        }
    }
}
#endif
