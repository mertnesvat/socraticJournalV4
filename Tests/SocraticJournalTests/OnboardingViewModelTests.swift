// OnboardingViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("OnboardingViewModel Tests")
struct OnboardingViewModelTests {

    // MARK: - Initial State

    @Suite("Initial State")
    struct InitialStateTests {

        @Test("starts on page 0")
        @MainActor
        func startsOnPageZero() {
            let viewModel = makeViewModel()
            #expect(viewModel.currentPage == 0)
        }

        @Test("isCompleting starts as false")
        @MainActor
        func isCompletingStartsFalse() {
            let viewModel = makeViewModel()
            #expect(viewModel.isCompleting == false)
        }

        @Test("error starts as nil")
        @MainActor
        func errorStartsNil() {
            let viewModel = makeViewModel()
            #expect(viewModel.error == nil)
        }

        @Test("totalPages is 3")
        @MainActor
        func totalPagesIsThree() {
            let viewModel = makeViewModel()
            #expect(viewModel.totalPages == 3)
        }
    }

    // MARK: - Page Navigation

    @Suite("Page Navigation")
    struct PageNavigationTests {

        @Test("nextPage advances from 0 to 1")
        @MainActor
        func nextPageAdvancesFromZeroToOne() {
            let viewModel = makeViewModel()
            viewModel.nextPage()
            #expect(viewModel.currentPage == 1)
        }

        @Test("nextPage advances from 1 to 2")
        @MainActor
        func nextPageAdvancesFromOneToTwo() {
            let viewModel = makeViewModel()
            viewModel.nextPage()
            viewModel.nextPage()
            #expect(viewModel.currentPage == 2)
        }

        @Test("nextPage does not advance past last page")
        @MainActor
        func nextPageDoesNotAdvancePastLastPage() {
            let viewModel = makeViewModel()
            viewModel.nextPage()
            viewModel.nextPage()
            viewModel.nextPage() // should be a no-op
            #expect(viewModel.currentPage == 2)
        }

        @Test("setPage navigates to specific page")
        @MainActor
        func setPageNavigatesToSpecificPage() {
            let viewModel = makeViewModel()
            viewModel.setPage(2)
            #expect(viewModel.currentPage == 2)
        }

        @Test("setPage ignores negative values")
        @MainActor
        func setPageIgnoresNegative() {
            let viewModel = makeViewModel()
            viewModel.setPage(-1)
            #expect(viewModel.currentPage == 0)
        }

        @Test("setPage ignores out of range values")
        @MainActor
        func setPageIgnoresOutOfRange() {
            let viewModel = makeViewModel()
            viewModel.setPage(5)
            #expect(viewModel.currentPage == 0)
        }
    }

    // MARK: - Analytics

    @Suite("Analytics")
    struct AnalyticsTests {

        @Test("logOnboardingStarted fires analytics event")
        @MainActor
        func logOnboardingStartedFiresEvent() {
            let analytics = MockAnalyticsService()
            let viewModel = makeViewModel(analyticsService: analytics)

            viewModel.logOnboardingStarted()

            #expect(analytics.hasLoggedEvent(.onboardingStarted))
            #expect(analytics.eventCount(for: .onboardingStarted) == 1)
        }

        @Test("completeOnboarding fires onboardingCompleted event")
        @MainActor
        func completeOnboardingFiresCompletedEvent() async {
            let analytics = MockAnalyticsService()
            let viewModel = makeViewModel(analyticsService: analytics)

            await viewModel.completeOnboarding()

            #expect(analytics.hasLoggedEvent(.onboardingCompleted))
        }

        @Test("completeOnboarding does not fire completed event on error")
        @MainActor
        func completeOnboardingDoesNotFireOnError() async {
            let analytics = MockAnalyticsService()
            let settingsRepo = MockSettingsRepository()
            settingsRepo.shouldFail = true
            let viewModel = makeViewModel(
                settingsRepository: settingsRepo,
                analyticsService: analytics
            )

            await viewModel.completeOnboarding()

            #expect(!analytics.hasLoggedEvent(.onboardingCompleted))
        }
    }

    // MARK: - Completion

    @Suite("Complete Onboarding")
    struct CompleteOnboardingTests {

        @Test("completeOnboarding saves hasCompletedOnboarding true")
        @MainActor
        func completeOnboardingSavesFlag() async {
            let settingsRepo = MockSettingsRepository()
            let viewModel = makeViewModel(settingsRepository: settingsRepo)

            await viewModel.completeOnboarding()

            #expect(settingsRepo.lastSavedSettings?.hasCompletedOnboarding == true)
        }

        @Test("completeOnboarding calls onDismiss")
        @MainActor
        func completeOnboardingCallsOnDismiss() async {
            var dismissed = false
            let viewModel = makeViewModel(onDismiss: { dismissed = true })

            await viewModel.completeOnboarding()

            #expect(dismissed)
        }

        @Test("completeOnboarding resets isCompleting to false")
        @MainActor
        func completeOnboardingResetsIsCompleting() async {
            let viewModel = makeViewModel()

            await viewModel.completeOnboarding()

            #expect(viewModel.isCompleting == false)
        }

        @Test("completeOnboarding sets error on failure")
        @MainActor
        func completeOnboardingSetsErrorOnFailure() async {
            let settingsRepo = MockSettingsRepository()
            settingsRepo.shouldFail = true
            let viewModel = makeViewModel(settingsRepository: settingsRepo)

            await viewModel.completeOnboarding()

            #expect(viewModel.error != nil)
        }

        @Test("completeOnboarding still calls onDismiss on failure")
        @MainActor
        func completeOnboardingCallsOnDismissOnFailure() async {
            var dismissed = false
            let settingsRepo = MockSettingsRepository()
            settingsRepo.shouldFail = true
            let viewModel = makeViewModel(
                settingsRepository: settingsRepo,
                onDismiss: { dismissed = true }
            )

            await viewModel.completeOnboarding()

            #expect(dismissed)
        }
    }

    // MARK: - Test Helper

    @MainActor
    private static func makeViewModel(
        settingsRepository: SettingsRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        onDismiss: @escaping () -> Void = {}
    ) -> OnboardingViewModel {
        OnboardingViewModel(
            settingsRepository: settingsRepository ?? MockSettingsRepository(),
            analyticsService: analyticsService ?? MockAnalyticsService(),
            onDismiss: onDismiss
        )
    }
}
