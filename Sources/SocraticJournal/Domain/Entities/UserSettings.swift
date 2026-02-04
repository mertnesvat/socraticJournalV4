// UserSettings.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents user app settings and preferences
public struct UserSettings: Codable, Sendable, Equatable {
    public var themeMode: ThemeMode
    public var letterRemindersEnabled: Bool
    public var dailyReminderEnabled: Bool
    public var dailyReminderHour: Int
    public var dailyReminderMinute: Int
    public var hasCompletedOnboarding: Bool
    public var hasDismissedSampleData: Bool

    // MARK: - Subscription State

    /// Expiry date of the current subscription, nil for free users
    public var subscriptionExpiryDate: Date?
    /// Product ID of the active subscription, nil for free users
    public var activeProductId: String?
    /// Last time subscription status was checked (for cache invalidation)
    public var lastSubscriptionCheck: Date?

    /// Computed property indicating if user has premium access
    public var isPremium: Bool {
        guard let expiryDate = subscriptionExpiryDate else { return false }
        return expiryDate > Date()
    }

    public init(
        themeMode: ThemeMode = .system,
        letterRemindersEnabled: Bool = true,
        dailyReminderEnabled: Bool = false,
        dailyReminderHour: Int = 9,
        dailyReminderMinute: Int = 0,
        hasCompletedOnboarding: Bool = false,
        hasDismissedSampleData: Bool = false,
        subscriptionExpiryDate: Date? = nil,
        activeProductId: String? = nil,
        lastSubscriptionCheck: Date? = nil
    ) {
        self.themeMode = themeMode
        self.letterRemindersEnabled = letterRemindersEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderHour = dailyReminderHour
        self.dailyReminderMinute = dailyReminderMinute
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasDismissedSampleData = hasDismissedSampleData
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.activeProductId = activeProductId
        self.lastSubscriptionCheck = lastSubscriptionCheck
    }

    // Custom decoder to handle backwards compatibility with existing saved settings
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeMode = try container.decodeIfPresent(ThemeMode.self, forKey: .themeMode) ?? .system
        letterRemindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .letterRemindersEnabled) ?? true
        dailyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .dailyReminderEnabled) ?? false
        dailyReminderHour = try container.decodeIfPresent(Int.self, forKey: .dailyReminderHour) ?? 9
        dailyReminderMinute = try container.decodeIfPresent(Int.self, forKey: .dailyReminderMinute) ?? 0
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        hasDismissedSampleData = try container.decodeIfPresent(Bool.self, forKey: .hasDismissedSampleData) ?? false
        // Subscription fields - defaults to nil for backwards compatibility
        subscriptionExpiryDate = try container.decodeIfPresent(Date.self, forKey: .subscriptionExpiryDate)
        activeProductId = try container.decodeIfPresent(String.self, forKey: .activeProductId)
        lastSubscriptionCheck = try container.decodeIfPresent(Date.self, forKey: .lastSubscriptionCheck)
    }

    private enum CodingKeys: String, CodingKey {
        case themeMode
        case letterRemindersEnabled
        case dailyReminderEnabled
        case dailyReminderHour
        case dailyReminderMinute
        case hasCompletedOnboarding
        case hasDismissedSampleData
        case subscriptionExpiryDate
        case activeProductId
        case lastSubscriptionCheck
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
        dailyReminderHour = components.hour ?? 9
        dailyReminderMinute = components.minute ?? 0
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
