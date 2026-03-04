// UserSettings.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

public struct UserSettings: Codable, Sendable, Equatable {
    public var themeMode: ThemeMode
    public var dailyGoalMinutes: Int
    public var breathReminderEnabled: Bool
    public var dailyReminderHour: Int
    public var dailyReminderMinute: Int
    public var hapticFeedbackEnabled: Bool
    public var hasCompletedOnboarding: Bool

    public init(
        themeMode: ThemeMode = .system,
        dailyGoalMinutes: Int = 5,
        breathReminderEnabled: Bool = false,
        dailyReminderHour: Int = 7,
        dailyReminderMinute: Int = 30,
        hapticFeedbackEnabled: Bool = true,
        hasCompletedOnboarding: Bool = false
    ) {
        self.themeMode = themeMode
        self.dailyGoalMinutes = dailyGoalMinutes
        self.breathReminderEnabled = breathReminderEnabled
        self.dailyReminderHour = dailyReminderHour
        self.dailyReminderMinute = dailyReminderMinute
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeMode = try container.decodeIfPresent(ThemeMode.self, forKey: .themeMode) ?? .system
        dailyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyGoalMinutes) ?? 5
        breathReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .breathReminderEnabled) ?? false
        dailyReminderHour = try container.decodeIfPresent(Int.self, forKey: .dailyReminderHour) ?? 7
        dailyReminderMinute = try container.decodeIfPresent(Int.self, forKey: .dailyReminderMinute) ?? 30
        hapticFeedbackEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticFeedbackEnabled) ?? true
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    }

    public static let `default` = UserSettings()

    public var reminderTime: Date {
        var components = DateComponents()
        components.hour = dailyReminderHour
        components.minute = dailyReminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    public mutating func setReminderTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        dailyReminderHour = components.hour ?? 7
        dailyReminderMinute = components.minute ?? 30
    }

    public var formattedReminderTime: String {
        let hour = dailyReminderHour
        let minute = dailyReminderMinute
        let ampm = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, ampm)
    }
}

public enum ThemeMode: String, Codable, Sendable, CaseIterable {
    case system, light, dark

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
