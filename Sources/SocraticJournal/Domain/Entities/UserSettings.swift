// UserSettings.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents user app settings and preferences
public struct UserSettings: Codable, Sendable, Equatable {
    public var themeMode: ThemeMode
    public var dailyReminderEnabled: Bool
    public var dailyReminderHour: Int
    public var dailyReminderMinute: Int
    public var hasCompletedOnboarding: Bool

    // MARK: - Subscription State

    public var subscriptionExpiryDate: Date?
    public var activeProductId: String?
    public var lastSubscriptionCheck: Date?

    public var isPremium: Bool {
        guard let expiryDate = subscriptionExpiryDate else { return false }
        return expiryDate > Date()
    }

    public init(
        themeMode: ThemeMode = .system,
        dailyReminderEnabled: Bool = false,
        dailyReminderHour: Int = 18,
        dailyReminderMinute: Int = 0,
        hasCompletedOnboarding: Bool = false,
        subscriptionExpiryDate: Date? = nil,
        activeProductId: String? = nil,
        lastSubscriptionCheck: Date? = nil
    ) {
        self.themeMode = themeMode
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderHour = dailyReminderHour
        self.dailyReminderMinute = dailyReminderMinute
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.activeProductId = activeProductId
        self.lastSubscriptionCheck = lastSubscriptionCheck
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeMode = try container.decodeIfPresent(ThemeMode.self, forKey: .themeMode) ?? .system
        dailyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .dailyReminderEnabled) ?? false
        dailyReminderHour = try container.decodeIfPresent(Int.self, forKey: .dailyReminderHour) ?? 18
        dailyReminderMinute = try container.decodeIfPresent(Int.self, forKey: .dailyReminderMinute) ?? 0
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        subscriptionExpiryDate = try container.decodeIfPresent(Date.self, forKey: .subscriptionExpiryDate)
        activeProductId = try container.decodeIfPresent(String.self, forKey: .activeProductId)
        lastSubscriptionCheck = try container.decodeIfPresent(Date.self, forKey: .lastSubscriptionCheck)
    }

    public static let `default` = UserSettings()

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
        dailyReminderHour = components.hour ?? 18
        dailyReminderMinute = components.minute ?? 0
    }

    // MARK: - Subscription Helpers

    public mutating func updateSubscription(from status: SubscriptionStatus) {
        switch status {
        case .free:
            subscriptionExpiryDate = nil
            activeProductId = nil
        case .premium(let expiryDate, let productId):
            subscriptionExpiryDate = expiryDate
            activeProductId = productId
        case .expired(let lastExpiryDate, let lastProductId):
            subscriptionExpiryDate = lastExpiryDate
            activeProductId = lastProductId
        }
        lastSubscriptionCheck = Date()
    }

    public var formattedSubscriptionExpiry: String? {
        guard let expiryDate = subscriptionExpiryDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: expiryDate)
    }

    public var subscriptionPeriod: SubscriptionPeriod? {
        guard let productId = activeProductId else { return nil }
        if productId.contains("monthly") { return .monthly }
        if productId.contains("yearly") { return .yearly }
        return nil
    }
}

/// Theme mode options
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
