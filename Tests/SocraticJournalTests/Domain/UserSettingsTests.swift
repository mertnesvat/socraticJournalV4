// UserSettingsTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("UserSettings Tests")
struct UserSettingsTests {

    @Test("Default settings have expected values")
    func defaultValues() {
        let settings = UserSettings.default
        #expect(settings.dailyGoalMinutes == 5)
        #expect(settings.hapticRhythmEnabled == true)
        #expect(settings.themeMode == .system)
        #expect(settings.dailyReminderEnabled == false)
        #expect(settings.dailyReminderHour == 7)
        #expect(settings.dailyReminderMinute == 30)
        #expect(settings.hasCompletedOnboarding == false)
    }

    @Test("Codable round-trip preserves all fields")
    func codableRoundTrip() throws {
        var settings = UserSettings.default
        settings.dailyGoalMinutes = 10
        settings.hapticRhythmEnabled = false
        settings.themeMode = .dark
        settings.dailyReminderEnabled = true
        settings.hasCompletedOnboarding = true

        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UserSettings.self, from: data)

        #expect(decoded == settings)
    }

    @Test("Backwards compatibility — decode settings missing newer fields")
    func backwardsCompatibility() throws {
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

        // Missing fields should fall back to defaults
        #expect(settings.hasCompletedOnboarding == false)
        #expect(settings.dailyGoalMinutes == 5)
        #expect(settings.hapticRhythmEnabled == true)
        // Explicitly set fields should be preserved
        #expect(settings.dailyReminderHour == 9)
        #expect(settings.dailyReminderMinute == 0)
    }

    @Test("formattedReminderTime produces correct string for morning")
    func formattedReminderTimeMorning() {
        var settings = UserSettings.default
        settings.dailyReminderHour = 7
        settings.dailyReminderMinute = 30
        #expect(settings.formattedReminderTime == "7:30 AM")
    }

    @Test("formattedReminderTime produces correct string for afternoon")
    func formattedReminderTimeAfternoon() {
        var settings = UserSettings.default
        settings.dailyReminderHour = 14
        settings.dailyReminderMinute = 0
        #expect(settings.formattedReminderTime == "2:00 PM")
    }

    @Test("formattedReminderTime produces correct string for midnight")
    func formattedReminderTimeMidnight() {
        var settings = UserSettings.default
        settings.dailyReminderHour = 0
        settings.dailyReminderMinute = 0
        #expect(settings.formattedReminderTime == "12:00 AM")
    }

    @Test("formattedReminderTime produces correct string for noon")
    func formattedReminderTimeNoon() {
        var settings = UserSettings.default
        settings.dailyReminderHour = 12
        settings.dailyReminderMinute = 0
        #expect(settings.formattedReminderTime == "12:00 PM")
    }
}
