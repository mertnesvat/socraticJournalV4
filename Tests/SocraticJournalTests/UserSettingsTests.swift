// UserSettingsTests.swift
// Breathe
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("UserSettings Tests")
struct UserSettingsTests {

    // MARK: - Default Values

    @Test("Default settings have expected values")
    func testDefaultValues() {
        let settings = UserSettings.default

        #expect(settings.themeMode == .system)
        #expect(settings.dailyReminderEnabled == false)
        #expect(settings.dailyReminderHour == 9)
        #expect(settings.dailyReminderMinute == 0)
        #expect(settings.hasCompletedOnboarding == false)
        #expect(settings.hasDismissedSampleData == false)
        #expect(settings.dailyGoalMinutes == 5)
        #expect(settings.defaultTechniqueId == "resonance")
        #expect(settings.lastUsedTechniqueId == nil)
    }

    // MARK: - Daily Goal Minutes

    @Test("Daily goal minutes can be set to valid options")
    func testDailyGoalMinutesOptions() {
        var settings = UserSettings.default

        for minutes in [3, 5, 10, 15, 20] {
            settings.dailyGoalMinutes = minutes
            #expect(settings.dailyGoalMinutes == minutes)
        }
    }

    @Test("Daily goal minutes initializer sets value")
    func testDailyGoalMinutesInit() {
        let settings = UserSettings(dailyGoalMinutes: 15)
        #expect(settings.dailyGoalMinutes == 15)
    }

    // MARK: - Reminder Time

    @Test("Formatted reminder time displays correctly for AM")
    func testFormattedReminderTimeAM() {
        let settings = UserSettings(dailyReminderHour: 9, dailyReminderMinute: 30)
        #expect(settings.formattedReminderTime == "9:30 AM")
    }

    @Test("Formatted reminder time displays correctly for PM")
    func testFormattedReminderTimePM() {
        let settings = UserSettings(dailyReminderHour: 14, dailyReminderMinute: 0)
        #expect(settings.formattedReminderTime == "2:00 PM")
    }

    @Test("Formatted reminder time displays correctly for noon")
    func testFormattedReminderTimeNoon() {
        let settings = UserSettings(dailyReminderHour: 12, dailyReminderMinute: 0)
        #expect(settings.formattedReminderTime == "12:00 PM")
    }

    @Test("Formatted reminder time displays correctly for midnight")
    func testFormattedReminderTimeMidnight() {
        let settings = UserSettings(dailyReminderHour: 0, dailyReminderMinute: 0)
        #expect(settings.formattedReminderTime == "12:00 AM")
    }

    @Test("Set reminder time from date updates hour and minute")
    func testSetReminderTimeFromDate() {
        var settings = UserSettings.default
        var components = DateComponents()
        components.hour = 15
        components.minute = 45
        let date = Calendar.current.date(from: components)!

        settings.setReminderTime(from: date)

        #expect(settings.dailyReminderHour == 15)
        #expect(settings.dailyReminderMinute == 45)
    }

    // MARK: - Codable

    @Test("Settings round-trips through JSON encoding and decoding")
    func testCodableRoundTrip() throws {
        let original = UserSettings(
            themeMode: .dark,
            dailyReminderEnabled: true,
            dailyReminderHour: 8,
            dailyReminderMinute: 30,
            hasCompletedOnboarding: true,
            hasDismissedSampleData: true,
            dailyGoalMinutes: 20,
            defaultTechniqueId: "boxBreathing",
            lastUsedTechniqueId: "478"
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserSettings.self, from: data)

        #expect(decoded == original)
    }

    @Test("Decoding with missing fields uses defaults")
    func testDecodingWithMissingFields() throws {
        let json = "{}"
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(UserSettings.self, from: data)

        #expect(decoded.themeMode == .system)
        #expect(decoded.dailyGoalMinutes == 5)
        #expect(decoded.defaultTechniqueId == "resonance")
        #expect(decoded.dailyReminderEnabled == false)
        #expect(decoded.hasCompletedOnboarding == false)
    }

    @Test("Decoding with partial fields preserves provided values")
    func testDecodingWithPartialFields() throws {
        let json = """
        {"dailyGoalMinutes": 10, "themeMode": "dark"}
        """
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(UserSettings.self, from: data)

        #expect(decoded.dailyGoalMinutes == 10)
        #expect(decoded.themeMode == .dark)
        #expect(decoded.defaultTechniqueId == "resonance")
    }

    // MARK: - Equatable

    @Test("Two default settings are equal")
    func testEquatable() {
        let a = UserSettings.default
        let b = UserSettings.default
        #expect(a == b)
    }

    @Test("Settings with different daily goal are not equal")
    func testNotEqual() {
        let a = UserSettings(dailyGoalMinutes: 5)
        let b = UserSettings(dailyGoalMinutes: 10)
        #expect(a != b)
    }

    // MARK: - ThemeMode

    @Test("ThemeMode display names")
    func testThemeModeDisplayNames() {
        #expect(ThemeMode.system.displayName == "System")
        #expect(ThemeMode.light.displayName == "Light")
        #expect(ThemeMode.dark.displayName == "Dark")
    }

    @Test("ThemeMode icon names")
    func testThemeModeIconNames() {
        #expect(ThemeMode.system.iconName == "iphone")
        #expect(ThemeMode.light.iconName == "sun.max.fill")
        #expect(ThemeMode.dark.iconName == "moon.fill")
    }

    @Test("ThemeMode has all three cases")
    func testThemeModeAllCases() {
        #expect(ThemeMode.allCases.count == 3)
    }
}
