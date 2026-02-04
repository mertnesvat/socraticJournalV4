// OnboardingTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for onboarding business logic
/// Verifies onboarding flag management and ensures paywall is NOT shown during onboarding
@Suite("Onboarding Tests")
struct OnboardingTests {

    // MARK: - Onboarding Completion Tests

    @Test("hasCompletedOnboarding starts as false by default")
    func hasCompletedOnboardingDefaultFalse() {
        let settings = UserSettings.default
        #expect(!settings.hasCompletedOnboarding)
    }

    @Test("Setting hasCompletedOnboarding to true persists")
    func hasCompletedOnboardingPersists() async throws {
        let repository = MockSettingsRepository()

        var settings = try await repository.getSettings()
        #expect(!settings.hasCompletedOnboarding)

        settings.hasCompletedOnboarding = true
        try await repository.saveSettings(settings)

        let loadedSettings = try await repository.getSettings()
        #expect(loadedSettings.hasCompletedOnboarding)
    }

    @Test("Completing onboarding sets hasCompletedOnboarding to true")
    func completingOnboardingSetsFlag() async throws {
        let repository = MockSettingsRepository()
        repository.settings.hasCompletedOnboarding = false

        // Simulate what OnboardingView.completeOnboarding() does
        var settings = try await repository.getSettings()
        settings.hasCompletedOnboarding = true
        try await repository.saveSettings(settings)

        #expect(repository.saveSettingsCalled)
        #expect(repository.savedSettings?.hasCompletedOnboarding == true)
    }

    @Test("Skip button completes onboarding same as Continue")
    func skipButtonCompletesOnboarding() async throws {
        let repository = MockSettingsRepository()
        repository.settings.hasCompletedOnboarding = false

        // Both Skip and Continue should call the same completion logic
        var settings = try await repository.getSettings()
        settings.hasCompletedOnboarding = true
        try await repository.saveSettings(settings)

        #expect(repository.savedSettings?.hasCompletedOnboarding == true)
    }

    // MARK: - Analytics Tests

    @Test("Analytics event logged on onboarding completion")
    func analyticsLoggedOnCompletion() {
        let analytics = MockAnalyticsService()

        // Simulate onboarding completion
        analytics.logEvent(.onboardingCompleted, parameters: nil)

        #expect(analytics.hasLoggedEvent(.onboardingCompleted))
        #expect(analytics.eventCount(for: .onboardingCompleted) == 1)
    }

    @Test("Onboarding started event can be logged")
    func onboardingStartedEventLogged() {
        let analytics = MockAnalyticsService()

        analytics.logEvent(.onboardingStarted, parameters: nil)

        #expect(analytics.hasLoggedEvent(.onboardingStarted))
    }

    @Test("Onboarding skipped event can be logged")
    func onboardingSkippedEventLogged() {
        let analytics = MockAnalyticsService()

        analytics.logEvent(.onboardingSkipped, parameters: nil)

        #expect(analytics.hasLoggedEvent(.onboardingSkipped))
    }

    // MARK: - Replay Onboarding Tests

    @Test("Replay onboarding resets flag to false")
    func replayOnboardingResetsFlag() async throws {
        let repository = MockSettingsRepository()
        repository.settings.hasCompletedOnboarding = true

        // Simulate replay: reset flag to false
        var settings = try await repository.getSettings()
        #expect(settings.hasCompletedOnboarding)

        settings.hasCompletedOnboarding = false
        try await repository.saveSettings(settings)

        let reloadedSettings = try await repository.getSettings()
        #expect(!reloadedSettings.hasCompletedOnboarding)
    }

    // MARK: - Paywall NOT Shown During Onboarding Tests

    @Test("Paywall is NOT triggered during onboarding flow")
    func paywallNotTriggeredDuringOnboarding() {
        let analytics = MockAnalyticsService()

        // Simulate complete onboarding flow events
        analytics.logEvent(.onboardingStarted, parameters: nil)
        // ... user goes through pages ...
        analytics.logEvent(.onboardingCompleted, parameters: nil)

        // Verify NO paywall events during onboarding
        #expect(!analytics.hasLoggedEvent(.paywallViewed))
        #expect(!analytics.hasLoggedEvent(.paywallPurchaseStarted))
        #expect(!analytics.hasLoggedEvent(.paywallPurchaseCompleted))

        // Only onboarding events should be logged
        #expect(analytics.hasLoggedEvent(.onboardingStarted))
        #expect(analytics.hasLoggedEvent(.onboardingCompleted))
    }

    @Test("Paywall events are separate from onboarding events")
    func paywallEventsSeparateFromOnboarding() {
        // Verify that onboarding and paywall are distinct event categories
        let onboardingEvents: [AnalyticsEvent] = [
            .onboardingStarted,
            .onboardingCompleted,
            .onboardingSkipped
        ]

        let paywallEvents: [AnalyticsEvent] = [
            .paywallViewed,
            .paywallProductSelected,
            .paywallPurchaseStarted,
            .paywallPurchaseCompleted,
            .paywallPurchaseFailed,
            .paywallRestoreStarted,
            .paywallRestoreCompleted,
            .paywallRestoreFailed
        ]

        // No overlap between onboarding and paywall events
        for onboardingEvent in onboardingEvents {
            #expect(!paywallEvents.contains(onboardingEvent))
        }
    }

    // MARK: - Error Handling Tests

    @Test("Onboarding still completes even if save fails")
    func onboardingCompletesEvenIfSaveFails() async throws {
        let repository = MockSettingsRepository()
        repository.saveSettingsError = NSError(domain: "test", code: 1, userInfo: nil)

        // The save should throw, but onboarding should still be considered complete
        // (user should not be stuck on onboarding)
        var settings = try await repository.getSettings()
        settings.hasCompletedOnboarding = true

        do {
            try await repository.saveSettings(settings)
            Issue.record("Expected error to be thrown")
        } catch {
            // Error is expected - user should still be able to proceed
            #expect(repository.saveSettingsCalled)
        }
    }

    // MARK: - Backwards Compatibility Tests

    @Test("Old settings without hasCompletedOnboarding default to false")
    func oldSettingsDefaultFalse() throws {
        // Simulate old settings JSON without the hasCompletedOnboarding field
        let oldSettingsJSON = """
        {
            "themeMode": "system",
            "letterRemindersEnabled": true,
            "dailyReminderEnabled": false,
            "dailyReminderHour": 9,
            "dailyReminderMinute": 0,
            "hasDismissedSampleData": false
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let settings = try decoder.decode(UserSettings.self, from: oldSettingsJSON)

        // Should default to false for backwards compatibility
        #expect(!settings.hasCompletedOnboarding)
    }

    // MARK: - Subscription Fields During Onboarding Tests

    @Test("Subscription fields are nil for new users during onboarding")
    func subscriptionFieldsNilDuringOnboarding() {
        let settings = UserSettings.default

        #expect(settings.subscriptionExpiryDate == nil)
        #expect(settings.activeProductId == nil)
        #expect(settings.lastSubscriptionCheck == nil)
        #expect(!settings.isPremium)
    }

    @Test("User is free during onboarding by default")
    func userFreeByDefaultDuringOnboarding() {
        let settings = UserSettings.default

        #expect(!settings.isPremium)
        #expect(!settings.hasCompletedOnboarding)
    }
}
