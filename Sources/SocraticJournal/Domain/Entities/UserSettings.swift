// UserSettings.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents user app settings and preferences
public struct UserSettings: Codable, Sendable, Equatable {
    public var themeMode: ThemeMode
    public var dailyGoalMinutes: Int
    public var breathReminderEnabled: Bool
    public var breathReminderHour: Int
    public var breathReminderMinute: Int
    public var hasCompletedOnboarding: Bool

    public init(
        themeMode: ThemeMode = .system,
        dailyGoalMinutes: Int = 5,
        breathReminderEnabled: Bool = false,
        breathReminderHour: Int = 9,
        breathReminderMinute: Int = 0,
        hasCompletedOnboarding: Bool = false
    ) {
        self.themeMode = themeMode
        self.dailyGoalMinutes = dailyGoalMinutes
        self.breathReminderEnabled = breathReminderEnabled
        self.breathReminderHour = breathReminderHour
        self.breathReminderMinute = breathReminderMinute
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeMode = try container.decodeIfPresent(ThemeMode.self, forKey: .themeMode) ?? .system
        dailyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyGoalMinutes) ?? 5
        breathReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .breathReminderEnabled) ?? false
        breathReminderHour = try container.decodeIfPresent(Int.self, forKey: .breathReminderHour) ?? 9
        breathReminderMinute = try container.decodeIfPresent(Int.self, forKey: .breathReminderMinute) ?? 0
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case themeMode
        case dailyGoalMinutes
        case breathReminderEnabled
        case breathReminderHour
        case breathReminderMinute
        case hasCompletedOnboarding
    }

    public static let `default` = UserSettings()

    public var formattedReminderTime: String {
        let hour = breathReminderHour
        let minute = breathReminderMinute
        let ampm = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, ampm)
    }

    public var reminderTime: Date {
        var components = DateComponents()
        components.hour = breathReminderHour
        components.minute = breathReminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    public mutating func setReminderTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        breathReminderHour = components.hour ?? 9
        breathReminderMinute = components.minute ?? 0
    }
}

/// Theme mode options for the app
public enum ThemeMode: String, Codable, Sendable, CaseIterable {
    case system
    case light
    case dark

    public var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    public var iconName: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
