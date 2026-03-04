// SettingsViewModelTests.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

@Suite("SettingsViewModel Tests")
struct SettingsViewModelTests {

    // MARK: - Load Settings

    @Test("Load settings succeeds and populates state")
    @MainActor
    func testLoadSettingsSuccess() async {
        let mockRepo = MockSettingsRepository(settings: UserSettings(
            dailyGoalMinutes: 10,
            defaultTechniqueId: "boxBreathing"
        ))
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)

        await viewModel.loadSettings()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.dailyGoalMinutes == 10)
        #expect(mockRepo.getSettingsCalled == true)
    }

    @Test("Load settings failure sets error")
    @MainActor
    func testLoadSettingsError() async {
        let mockRepo = MockSettingsRepository()
        mockRepo.shouldFail = true
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)

        await viewModel.loadSettings()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }

    @Test("Loading state is true during load")
    @MainActor
    func testLoadingStateInitiallyFalse() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)

        #expect(viewModel.isLoading == false)
    }

    // MARK: - Daily Goal Minutes

    @Test("Daily goal minutes default is 5")
    @MainActor
    func testDailyGoalMinutesDefault() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)

        await viewModel.loadSettings()

        #expect(viewModel.dailyGoalMinutes == 5)
    }

    @Test("Setting daily goal minutes updates settings and saves")
    @MainActor
    func testSetDailyGoalMinutes() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)
        await viewModel.loadSettings()

        viewModel.dailyGoalMinutes = 15

        // Allow the Task in the setter to run
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.dailyGoalMinutes == 15)
        #expect(mockRepo.saveSettingsCalled == true)
        #expect(mockRepo.lastSavedSettings?.dailyGoalMinutes == 15)
    }

    @Test("Daily goal minutes persists across valid options")
    @MainActor
    func testDailyGoalMinutesOptions() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)
        await viewModel.loadSettings()

        for minutes in [3, 5, 10, 15, 20] {
            viewModel.dailyGoalMinutes = minutes
            #expect(viewModel.dailyGoalMinutes == minutes)
        }
    }

    // MARK: - Theme Mode

    @Test("Theme mode default is system")
    @MainActor
    func testThemeModeDefault() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)

        await viewModel.loadSettings()

        #expect(viewModel.themeMode == .system)
    }

    @Test("Setting theme mode updates settings and saves")
    @MainActor
    func testSetThemeMode() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)
        await viewModel.loadSettings()

        viewModel.themeMode = .dark

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.themeMode == .dark)
        #expect(mockRepo.saveSettingsCalled == true)
        #expect(mockRepo.lastSavedSettings?.themeMode == .dark)
    }

    // MARK: - Reset Onboarding

    @Test("Reset onboarding sets hasCompletedOnboarding to false and saves")
    @MainActor
    func testResetOnboarding() async {
        let mockRepo = MockSettingsRepository(settings: UserSettings(hasCompletedOnboarding: true))
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)
        await viewModel.loadSettings()

        await viewModel.resetOnboarding()

        #expect(mockRepo.saveSettingsCalled == true)
        #expect(mockRepo.lastSavedSettings?.hasCompletedOnboarding == false)
    }

    // MARK: - Notifications Denied

    @Test("Notifications denied returns false by default")
    @MainActor
    func testNotificationsDeniedDefault() async {
        let mockRepo = MockSettingsRepository()
        let viewModel = SettingsViewModel(settingsRepository: mockRepo)

        #expect(viewModel.notificationsDenied == false)
    }
}
#endif
