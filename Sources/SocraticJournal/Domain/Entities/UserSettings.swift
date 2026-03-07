// UserSettings.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents user app settings and preferences
public struct UserSettings: Codable, Sendable, Equatable {
    public var themeMode: ThemeMode
    public var dailyReminderEnabled: Bool
    public var dailyReminderHour: Int
    public var dailyReminderMinute: Int
    public var hasCompletedOnboarding: Bool
    public var dailyGoalMinutes: Int
    public var hapticRhythmEnabled: Bool
    public var readArticleIndices: Set<Int>
    public var healthKitEnabled: Bool

    public init(
        themeMode: ThemeMode = .system,
        dailyReminderEnabled: Bool = false,
        dailyReminderHour: Int = 7,
        dailyReminderMinute: Int = 30,
        hasCompletedOnboarding: Bool = false,
        dailyGoalMinutes: Int = 5,
        hapticRhythmEnabled: Bool = true,
        readArticleIndices: Set<Int> = [],
        healthKitEnabled: Bool = true
    ) {
        self.themeMode = themeMode
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderHour = dailyReminderHour
        self.dailyReminderMinute = dailyReminderMinute
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.dailyGoalMinutes = dailyGoalMinutes
        self.hapticRhythmEnabled = hapticRhythmEnabled
        self.readArticleIndices = readArticleIndices
        self.healthKitEnabled = healthKitEnabled
    }

    // Custom decoder for backwards compatibility
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeMode = try container.decodeIfPresent(ThemeMode.self, forKey: .themeMode) ?? .system
        dailyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .dailyReminderEnabled) ?? false
        dailyReminderHour = try container.decodeIfPresent(Int.self, forKey: .dailyReminderHour) ?? 7
        dailyReminderMinute = try container.decodeIfPresent(Int.self, forKey: .dailyReminderMinute) ?? 30
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        dailyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyGoalMinutes) ?? 5
        hapticRhythmEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticRhythmEnabled) ?? true
        readArticleIndices = try container.decodeIfPresent(Set<Int>.self, forKey: .readArticleIndices) ?? []
        healthKitEnabled = try container.decodeIfPresent(Bool.self, forKey: .healthKitEnabled) ?? true
    }

    private enum CodingKeys: String, CodingKey {
        case themeMode
        case dailyReminderEnabled
        case dailyReminderHour
        case dailyReminderMinute
        case hasCompletedOnboarding
        case dailyGoalMinutes
        case hapticRhythmEnabled
        case readArticleIndices
        case healthKitEnabled
    }

    /// Default settings
    public static let `default` = UserSettings()

    /// Formatted reminder time for display
    public var formattedReminderTime: String {
        let hour = dailyReminderHour
        let minute = dailyReminderMinute
        let ampm = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, ampm)
    }

    /// Date representation of reminder time for DatePicker
    public var reminderTime: Date {
        var components = DateComponents()
        components.hour = dailyReminderHour
        components.minute = dailyReminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Updates reminder time from a Date
    public mutating func setReminderTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        dailyReminderHour = components.hour ?? 7
        dailyReminderMinute = components.minute ?? 30
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
