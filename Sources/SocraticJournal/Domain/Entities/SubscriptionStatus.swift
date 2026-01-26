// SubscriptionStatus.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents the user's subscription tier
public enum SubscriptionTier: String, Codable, Sendable, Equatable {
    case monthly
    case yearly
    case lifetime

    /// Display name for the subscription tier
    public var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    /// Short badge text for UI display
    public var badgeText: String {
        switch self {
        case .monthly: return "PRO"
        case .yearly: return "PRO"
        case .lifetime: return "PRO ∞"
        }
    }
}

/// Represents the user's current subscription status
public enum SubscriptionStatus: Sendable, Equatable {
    /// Subscription status has not yet been determined
    case unknown
    /// User has no active subscription
    case inactive
    /// User has an active subscription with a specific tier
    case active(tier: SubscriptionTier)

    /// Whether the user has any active subscription (is a Pro user)
    public var isPro: Bool {
        if case .active = self {
            return true
        }
        return false
    }

    /// The subscription tier if active, nil otherwise
    public var tier: SubscriptionTier? {
        if case .active(let tier) = self {
            return tier
        }
        return nil
    }

    /// Display text for the current status
    public var displayText: String {
        switch self {
        case .unknown:
            return "Loading..."
        case .inactive:
            return "Free"
        case .active(let tier):
            return tier.displayName
        }
    }
}

/// Represents triggers for showing paywalls
public enum PaywallTrigger: String, Sendable {
    /// User tapped upgrade button in settings
    case settingsUpgrade = "campaign_trigger"
    /// User attempted to access a premium feature
    case featureGate = "feature_gate"
    /// User completed onboarding
    case onboardingComplete = "onboarding_complete"
    /// User completed a journal session
    case sessionComplete = "session_complete"
    /// Character Discovery feature gate
    case characterDiscovery = "character_discovery"
    /// Wisdom Quotes premium feature
    case wisdomQuotes = "wisdom_quotes"
    /// Data export premium feature
    case dataExport = "data_export"
    /// Campaign-based trigger (custom placement)
    case campaign = "campaign"
}
