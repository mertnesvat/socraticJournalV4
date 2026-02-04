// Subscription.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

// MARK: - Subscription Status

/// Represents the user's current subscription state
public enum SubscriptionStatus: Codable, Sendable, Equatable {
    /// User has no active subscription
    case free
    /// User has an active premium subscription
    case premium(expiryDate: Date, productId: String)
    /// User's subscription has expired
    case expired(expiryDate: Date, productId: String)

    /// Returns true if the user currently has premium access
    public var isPremium: Bool {
        switch self {
        case .premium:
            return true
        case .free, .expired:
            return false
        }
    }

    /// Returns the expiry date if subscribed or expired
    public var expiryDate: Date? {
        switch self {
        case .premium(let date, _), .expired(let date, _):
            return date
        case .free:
            return nil
        }
    }

    /// Returns the product ID if subscribed or expired
    public var productId: String? {
        switch self {
        case .premium(_, let id), .expired(_, let id):
            return id
        case .free:
            return nil
        }
    }

    /// Display name for the status
    public var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .premium:
            return "Premium"
        case .expired:
            return "Expired"
        }
    }
}

// MARK: - Subscription Period

/// Billing period for a subscription product
public enum SubscriptionPeriod: String, Codable, Sendable, Equatable, CaseIterable {
    case monthly
    case yearly

    /// Display name for the period
    public var displayName: String {
        switch self {
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }

    /// Short name for compact display
    public var shortName: String {
        switch self {
        case .monthly:
            return "/month"
        case .yearly:
            return "/year"
        }
    }
}

// MARK: - Subscription Product

/// Represents a subscription product available for purchase
public struct SubscriptionProduct: Codable, Sendable, Equatable, Identifiable {
    /// Product identifier (App Store Connect product ID)
    public let id: String
    /// Localized display name
    public let displayName: String
    /// Localized price string (e.g., "$4.99")
    public let displayPrice: String
    /// Billing period
    public let period: SubscriptionPeriod
    /// Raw price value for calculations
    public let priceValue: Decimal

    public init(
        id: String,
        displayName: String,
        displayPrice: String,
        period: SubscriptionPeriod,
        priceValue: Decimal
    ) {
        self.id = id
        self.displayName = displayName
        self.displayPrice = displayPrice
        self.period = period
        self.priceValue = priceValue
    }

    /// Monthly equivalent price for yearly subscriptions (for savings calculation)
    public var monthlyEquivalent: Decimal {
        switch period {
        case .monthly:
            return priceValue
        case .yearly:
            return priceValue / 12
        }
    }
}

// MARK: - Subscription Error

/// Errors that can occur during subscription operations
public enum SubscriptionError: Error, LocalizedError, Sendable, Equatable {
    /// The requested product was not found in App Store
    case productNotFound
    /// Purchase failed with underlying error
    case purchaseFailed(String)
    /// User cancelled the purchase
    case purchaseCancelled
    /// User is not entitled to the subscription
    case notEntitled
    /// Network error occurred
    case networkError
    /// Verification of purchase failed
    case verificationFailed
    /// Unknown error
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found. Please try again later."
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .purchaseCancelled:
            return "Purchase was cancelled."
        case .notEntitled:
            return "No active subscription found."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .verificationFailed:
            return "Could not verify purchase. Please contact support."
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }

    /// User-friendly message for display in UI
    public var userFriendlyMessage: String {
        switch self {
        case .purchaseCancelled:
            // Don't show error for user-initiated cancellation
            return ""
        case .productNotFound, .networkError:
            return "Unable to load subscription options. Please check your connection and try again."
        case .purchaseFailed, .verificationFailed, .unknown:
            return "Something went wrong. Please try again or contact support."
        case .notEntitled:
            return "No active subscription found. Would you like to subscribe?"
        }
    }

    public static func == (lhs: SubscriptionError, rhs: SubscriptionError) -> Bool {
        switch (lhs, rhs) {
        case (.productNotFound, .productNotFound),
             (.purchaseCancelled, .purchaseCancelled),
             (.notEntitled, .notEntitled),
             (.networkError, .networkError),
             (.verificationFailed, .verificationFailed):
            return true
        case (.purchaseFailed(let a), .purchaseFailed(let b)):
            return a == b
        case (.unknown(let a), .unknown(let b)):
            return a == b
        default:
            return false
        }
    }
}
