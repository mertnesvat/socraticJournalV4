// UserSettings.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents user app settings and preferences
public struct UserSettings: Codable, Sendable, Equatable {
    public var themeMode: ThemeMode
    public var hasCompletedOnboarding: Bool
    public var dailyReminderEnabled: Bool
    public var dailyReminderHour: Int
    public var dailyReminderMinute: Int

    // MARK: - Subscription State

    /// The expiry date of the current subscription, nil for free users
    public var subscriptionExpiryDate: Date?

    /// The product ID of the active subscription, nil for free users
    public var activeProductId: String?

    /// When the subscription status was last verified with the App Store
    public var lastSubscriptionCheck: Date?

    /// Whether the user has premium access (computed from subscription state)
    public var isPremium: Bool {
        guard let expiryDate = subscriptionExpiryDate else { return false }
        return expiryDate > Date()
    }

    public init(
        themeMode: ThemeMode = .system,
        hasCompletedOnboarding: Bool = false,
        dailyReminderEnabled: Bool = false,
        dailyReminderHour: Int = 19,
        dailyReminderMinute: Int = 0,
        subscriptionExpiryDate: Date? = nil,
        activeProductId: String? = nil,
        lastSubscriptionCheck: Date? = nil
    ) {
        self.themeMode = themeMode
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderHour = dailyReminderHour
        self.dailyReminderMinute = dailyReminderMinute
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.activeProductId = activeProductId
        self.lastSubscriptionCheck = lastSubscriptionCheck
    }

    // Custom decoder for backwards compatibility
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        themeMode = try container.decodeIfPresent(ThemeMode.self, forKey: .themeMode) ?? .system
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        dailyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .dailyReminderEnabled) ?? false
        dailyReminderHour = try container.decodeIfPresent(Int.self, forKey: .dailyReminderHour) ?? 19
        dailyReminderMinute = try container.decodeIfPresent(Int.self, forKey: .dailyReminderMinute) ?? 0
        subscriptionExpiryDate = try container.decodeIfPresent(Date.self, forKey: .subscriptionExpiryDate)
        activeProductId = try container.decodeIfPresent(String.self, forKey: .activeProductId)
        lastSubscriptionCheck = try container.decodeIfPresent(Date.self, forKey: .lastSubscriptionCheck)
    }

    /// Default settings
    public static let `default` = UserSettings()

    // MARK: - Subscription Helpers

    /// Updates subscription state from a SubscriptionStatus
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
