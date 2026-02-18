// SocraticJournalTests.swift
// Circle
// Copyright 2024 StudioNext

import Testing
@testable import SocraticJournal

@Test func userSettingsDefaults() {
    let settings = UserSettings.default
    #expect(settings.themeMode == .system)
    #expect(settings.hasCompletedOnboarding == false)
    #expect(settings.dailyReminderEnabled == false)
    #expect(settings.isPremium == false)
}
