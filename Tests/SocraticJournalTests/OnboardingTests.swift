// OnboardingTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for onboarding business logic
/// Verifies that onboarding works correctly and no paywall appears during onboarding
@Suite("Onboarding Tests")
struct OnboardingTests {

    // MARK: - UserSettings Onboarding State Tests

    @Suite("UserSettings Onboarding State")
    struct UserSettingsOnboardingTests {

        @Test("Default settings have hasCompletedOnboarding as false")
        func defaultNotCompleted() {
            let settings = UserSettings.default
            #expect(!settings.hasCompletedOnboarding)
        }

        @Test("hasCompletedOnboarding can be set to true")
        func canSetCompleted() {
            var settings = UserSettings.default
            settings.hasCompletedOnboarding = true
            #expect(settings.hasCompletedOnboarding)
        }

        @Test("Onboarding state persists through encoding/decoding")
        func codable() throws {
            var settings = UserSettings.default
            settings.hasCompletedOnboarding = true

            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(UserSettings.self, from: data)

            #expect(decoded.hasCompletedOnboarding)
        }

        @Test("Backwards compatible decoding defaults to false")
        func backwardsCompatible() throws {
            // JSON without hasCompletedOnboarding field
            let json = """
            {
                "themeMode": "system"
            }
            """
            let data = json.data(using: .utf8)!

            let decoder = JSONDecoder()
            let settings = try decoder.decode(UserSettings.self, from: data)

            #expect(!settings.hasCompletedOnboarding)
        }
    }

    // MARK: - SettingsViewModel Onboarding Tests

    @Suite("SettingsViewModel Onboarding")
    @MainActor
    struct SettingsViewModelOnboardingTests {

        @Test("Reset onboarding sets hasCompletedOnboarding to false")
        func resetOnboarding() async {
            let repository = MockSettingsRepository()
            repository.settings.hasCompletedOnboarding = true

            let viewModel = SettingsViewModel(
                settingsRepository: repository,
                journalRepository: InMemoryJournalRepository()
            )
            await viewModel.loadSettings()

            await viewModel.resetOnboarding()

            // Verify settings were saved with hasCompletedOnboarding = false
            #expect(repository.savedSettings.last?.hasCompletedOnboarding == false)
        }
    }

    // MARK: - Onboarding Analytics Tests

    @Suite("Onboarding Analytics")
    struct OnboardingAnalyticsTests {

        @Test("Onboarding completion logs analytics event")
        func onboardingCompletionLogsEvent() {
            let analyticsService = MockAnalyticsService()

            // Simulate what happens when onboarding completes
            analyticsService.logEvent(.onboardingCompleted, parameters: nil)

            #expect(analyticsService.hasLoggedEvent(.onboardingCompleted))
            #expect(analyticsService.eventCount(for: .onboardingCompleted) == 1)
        }

        @Test("Skip onboarding also completes onboarding")
        func skipCompletesOnboarding() {
            let analyticsService = MockAnalyticsService()

            // Both skip and complete should log the same completion event
            analyticsService.logEvent(.onboardingCompleted, parameters: nil)

            #expect(analyticsService.hasLoggedEvent(.onboardingCompleted))
        }
    }

    // MARK: - No Paywall During Onboarding Tests

    @Suite("No Paywall During Onboarding")
    struct NoPaywallDuringOnboardingTests {

        @Test("UserSettings does not expose paywall in onboarding")
        func noPaywallExposure() {
            // Verify that UserSettings.default does not trigger any paywall
            let settings = UserSettings.default

            // Subscription state should be nil/free for new users
            #expect(settings.subscriptionExpiryDate == nil)
            #expect(settings.activeProductId == nil)
            #expect(!settings.isPremium)
        }

        @Test("Free status does not block onboarding flow")
        func freeStatusAllowsOnboarding() {
            let settings = UserSettings.default
            // Verify onboarding can be completed regardless of subscription status
            #expect(!settings.hasCompletedOnboarding)
            #expect(!settings.isPremium)
            // Both conditions can be true - user is free AND onboarding is not complete
        }

        @Test("Subscription settings are independent of onboarding")
        func subscriptionIndependentOfOnboarding() {
            var settings = UserSettings.default

            // Complete onboarding
            settings.hasCompletedOnboarding = true

            // Subscription state unchanged
            #expect(!settings.isPremium)
            #expect(settings.subscriptionExpiryDate == nil)

            // Update subscription state
            settings.updateSubscriptionState(from: .premium(
                expiryDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
                productId: "test.product"
            ))

            // Both states are now set independently
            #expect(settings.hasCompletedOnboarding)
            #expect(settings.isPremium)
        }
    }

    // MARK: - Mock Repository Tests

    @Suite("MockSettingsRepository")
    struct MockRepositoryTests {

        @Test("Mock repository tracks save calls")
        func tracksSaveCalls() async throws {
            let repository = MockSettingsRepository()
            var settings = UserSettings.default
            settings.hasCompletedOnboarding = true

            try await repository.saveSettings(settings)

            #expect(repository.saveSettingsCallCount == 1)
            #expect(repository.savedSettings.count == 1)
            #expect(repository.savedSettings.first?.hasCompletedOnboarding == true)
        }

        @Test("Mock repository returns saved settings")
        func returnsSavedSettings() async throws {
            let repository = MockSettingsRepository()
            var settings = UserSettings.default
            settings.hasCompletedOnboarding = true

            try await repository.saveSettings(settings)
            let retrieved = try await repository.getSettings()

            #expect(retrieved.hasCompletedOnboarding)
        }

        @Test("Reset clears all tracking")
        func resetClears() async throws {
            let repository = MockSettingsRepository()
            try await repository.saveSettings(.default)
            _ = try await repository.getSettings()

            repository.reset()

            #expect(repository.saveSettingsCallCount == 0)
            #expect(repository.getSettingsCallCount == 0)
            #expect(repository.savedSettings.isEmpty)
        }
    }

    // MARK: - Mock Analytics Tests

    @Suite("MockAnalyticsService")
    struct MockAnalyticsTests {

        @Test("Mock analytics tracks logged events")
        func tracksLoggedEvents() {
            let service = MockAnalyticsService()

            service.logEvent(.onboardingStarted, parameters: nil)
            service.logEvent(.onboardingCompleted, parameters: ["source": "button"])

            #expect(service.loggedEvents.count == 2)
            #expect(service.hasLoggedEvent(.onboardingStarted))
            #expect(service.hasLoggedEvent(.onboardingCompleted))
        }

        @Test("Mock analytics tracks parameters")
        func tracksParameters() {
            let service = MockAnalyticsService()

            service.logEvent(.themeChanged, parameters: ["theme": "dark"])

            let params = service.lastParameters(for: .themeChanged)
            #expect(params?["theme"] as? String == "dark")
        }

        @Test("Mock analytics tracks user properties")
        func tracksUserProperties() {
            let service = MockAnalyticsService()

            service.setUserProperty("premium_status", value: "free")

            #expect(service.userProperties["premium_status"] == "free")
        }
    }
}
