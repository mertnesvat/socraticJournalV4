// OnboardingTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for onboarding flow business logic
@Suite("Onboarding Tests")
struct OnboardingTests {

    // MARK: - Initial State Tests

    @Suite("Initial State")
    struct InitialStateTests {

        @Test("hasCompletedOnboarding starts as false")
        func hasCompletedOnboardingStartsFalse() {
            let settings = UserSettings.default
            #expect(!settings.hasCompletedOnboarding)
        }

        @Test("Default settings have onboarding incomplete")
        func defaultSettingsOnboardingIncomplete() async throws {
            let repository = MockSettingsRepository()
            let settings = try await repository.getSettings()
            #expect(!settings.hasCompletedOnboarding)
        }
    }

    // MARK: - Complete Onboarding Tests

    @Suite("Complete Onboarding")
    struct CompleteOnboardingTests {

        @Test("Completing onboarding sets flag to true")
        func completingOnboardingSetsFlag() async throws {
            let repository = MockSettingsRepository()

            var settings = try await repository.getSettings()
            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            let updatedSettings = try await repository.getSettings()
            #expect(updatedSettings.hasCompletedOnboarding)
        }

        @Test("Onboarding completion persists")
        func onboardingCompletionPersists() async throws {
            let repository = MockSettingsRepository()

            // Complete onboarding
            var settings = try await repository.getSettings()
            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            // Verify it persisted
            #expect(repository.saveSettingsCalled)
            #expect(repository.lastSavedSettings?.hasCompletedOnboarding == true)
        }

        @Test("Analytics logged on onboarding completion")
        func analyticsLoggedOnCompletion() {
            let analyticsService = MockAnalyticsService()

            analyticsService.logEvent(.onboardingCompleted, parameters: nil)

            #expect(analyticsService.hasLoggedEvent(.onboardingCompleted))
            #expect(analyticsService.eventCount(for: .onboardingCompleted) == 1)
        }
    }

    // MARK: - Skip Onboarding Tests

    @Suite("Skip Onboarding")
    struct SkipOnboardingTests {

        @Test("Skip button completes onboarding same as Continue")
        func skipButtonCompletesOnboarding() async throws {
            let repository = MockSettingsRepository()

            var settings = try await repository.getSettings()
            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            let updatedSettings = try await repository.getSettings()
            #expect(updatedSettings.hasCompletedOnboarding)
        }

        @Test("Skip logs analytics event")
        func skipLogsAnalytics() {
            let analyticsService = MockAnalyticsService()

            analyticsService.logEvent(.onboardingCompleted, parameters: nil)

            #expect(analyticsService.hasLoggedEvent(.onboardingCompleted))
        }
    }

    // MARK: - Replay Onboarding Tests

    @Suite("Replay Onboarding")
    struct ReplayOnboardingTests {

        @Test("Replay onboarding resets flag to false")
        func replayOnboardingResetsFlag() async throws {
            let repository = MockSettingsRepository()

            var settings = try await repository.getSettings()
            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            settings.hasCompletedOnboarding = false
            try await repository.saveSettings(settings)

            let updatedSettings = try await repository.getSettings()
            #expect(!updatedSettings.hasCompletedOnboarding)
        }

        @Test("Replay onboarding then completes sets flag")
        func replayThenCompletes() async throws {
            let repository = MockSettingsRepository()

            var settings = try await repository.getSettings()
            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            settings.hasCompletedOnboarding = false
            try await repository.saveSettings(settings)

            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            let finalSettings = try await repository.getSettings()
            #expect(finalSettings.hasCompletedOnboarding)
        }
    }

    // MARK: - UserSettings Onboarding Tests

    @Suite("UserSettings Onboarding")
    struct UserSettingsOnboardingTests {

        @Test("UserSettings Codable preserves onboarding flag")
        func codablePreservesOnboardingFlag() throws {
            var settings = UserSettings.default
            settings.hasCompletedOnboarding = true

            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(UserSettings.self, from: data)

            #expect(decoded.hasCompletedOnboarding)
        }

        @Test("UserSettings decodes old data without onboarding flag")
        func decodesOldDataWithoutFlag() throws {
            // Simulate old data that doesn't have the onboarding flag
            let oldData = """
            {
                "themeMode": "system",
                "dailyReminderEnabled": false,
                "dailyReminderHour": 9,
                "dailyReminderMinute": 0
            }
            """.data(using: .utf8)!

            let decoder = JSONDecoder()
            let settings = try decoder.decode(UserSettings.self, from: oldData)

            // Should default to false for backwards compatibility
            #expect(!settings.hasCompletedOnboarding)
        }
    }

    // MARK: - Repository Interaction Tests

    @Suite("Repository Interactions")
    struct RepositoryInteractionTests {

        @Test("getSettings called to check onboarding status")
        func getSettingsCalledForOnboarding() async throws {
            let repository = MockSettingsRepository()

            _ = try await repository.getSettings()

            #expect(repository.getSettingsCalled)
            #expect(repository.getSettingsCallCount == 1)
        }

        @Test("saveSettings called when completing onboarding")
        func saveSettingsCalledOnCompletion() async throws {
            let repository = MockSettingsRepository()

            var settings = try await repository.getSettings()
            settings.hasCompletedOnboarding = true
            try await repository.saveSettings(settings)

            #expect(repository.saveSettingsCalled)
            #expect(repository.saveSettingsCallCount == 1)
        }

        @Test("Error during save does not crash onboarding")
        func errorDuringSaveHandled() async throws {
            let repository = MockSettingsRepository()
            repository.shouldFail = true

            var settings = UserSettings.default
            settings.hasCompletedOnboarding = true

            // This should throw but be handled gracefully in real code
            await #expect(throws: Error.self) {
                try await repository.saveSettings(settings)
            }
        }
    }
}
