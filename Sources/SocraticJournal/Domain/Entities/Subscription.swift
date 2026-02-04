// Subscription.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

// MARK: - Subscription Status

/// Represents the current subscription state of the user
public enum SubscriptionStatus: Equatable, Sendable {
    /// User has no active subscription
    case free

    /// User has an active premium subscription
    case premium(expiryDate: Date, productId: String)

    /// User's subscription has expired
    case expired

    /// Whether the user currently has premium access
    public var isPremium: Bool {
        if case .premium = self {
            return true
        }
        return false
    }

    /// The expiry date if subscribed, nil otherwise
    public var expiryDate: Date? {
        if case .premium(let date, _) = self {
            return date
        }
        return nil
    }

    /// The product ID if subscribed, nil otherwise
    public var productId: String? {
        if case .premium(_, let productId) = self {
            return productId
        }
        return nil
    }

    /// Human-readable status description
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

// MARK: - SubscriptionStatus Codable

extension SubscriptionStatus: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case expiryDate
        case productId
    }

    private enum StatusType: String, Codable {
        case free
        case premium
        case expired
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StatusType.self, forKey: .type)

        switch type {
        case .free:
            self = .free
        case .premium:
            let expiryDate = try container.decode(Date.self, forKey: .expiryDate)
            let productId = try container.decode(String.self, forKey: .productId)
            self = .premium(expiryDate: expiryDate, productId: productId)
        case .expired:
            self = .expired
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .free:
            try container.encode(StatusType.free, forKey: .type)
        case .premium(let expiryDate, let productId):
            try container.encode(StatusType.premium, forKey: .type)
            try container.encode(expiryDate, forKey: .expiryDate)
            try container.encode(productId, forKey: .productId)
        case .expired:
            try container.encode(StatusType.expired, forKey: .type)
        }
    }
}

// MARK: - Subscription Period

/// The billing period for a subscription
public enum SubscriptionPeriod: String, Codable, Sendable, Equatable {
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
            return "month"
        case .yearly:
            return "year"
        }
    }
}

// MARK: - Subscription Product

/// Represents a subscription product available for purchase
public struct SubscriptionProduct: Equatable, Sendable, Identifiable {
    /// The App Store product identifier
    public let id: String

    /// Display name for the product
    public let displayName: String

    /// Formatted price string (e.g., "$4.99")
    public let displayPrice: String

    /// The subscription period
    public let period: SubscriptionPeriod

    /// The numeric price value
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

    /// Calculates the monthly equivalent price for yearly subscriptions
    public var monthlyEquivalent: Decimal? {
        guard period == .yearly else { return nil }
        return priceValue / 12
    }

    /// Calculates savings percentage compared to monthly pricing
    /// - Parameter monthlyProduct: The monthly product to compare against
    /// - Returns: Savings percentage (0-100), or nil if comparison not possible
    public func savingsPercentage(comparedTo monthlyProduct: SubscriptionProduct) -> Int? {
        guard period == .yearly, monthlyProduct.period == .monthly else { return nil }
        let yearlyIfMonthly = monthlyProduct.priceValue * 12
        guard yearlyIfMonthly > 0 else { return nil }
        let savings = (yearlyIfMonthly - priceValue) / yearlyIfMonthly * 100
        let rounded = NSDecimalNumber(decimal: savings).rounding(
            accordingToBehavior: NSDecimalNumberHandler(
                roundingMode: .plain,
                scale: 0,
                raiseOnExactness: false,
                raiseOnOverflow: false,
                raiseOnUnderflow: false,
                raiseOnDivideByZero: false
            )
        )
        return rounded.intValue
    }
}

// MARK: - Product IDs

/// App Store Connect product identifiers
public enum SubscriptionProductID {
    /// Monthly subscription product ID
    public static let monthly = "com.StudioNext.socraticJournal.monthly"

    /// Yearly subscription product ID
    public static let yearly = "com.StudioNext.socraticJournal.yearly"

    /// All product IDs
    public static let all: Set<String> = [monthly, yearly]
}

// MARK: - Subscription Error

/// Errors that can occur during subscription operations
public enum SubscriptionError: Error, LocalizedError, Equatable {
    /// Requested product was not found in the App Store
    case productNotFound

    /// Purchase failed with underlying error
    case purchaseFailed(String)

    /// User cancelled the purchase
    case purchaseCancelled

    /// User is not entitled to the subscription
    case notEntitled

    /// Network error during operation
    case networkError

    /// Verification of purchase failed
    case verificationFailed

    /// Unknown error occurred
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found. Please try again later."
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .purchaseCancelled:
            return nil // Don't show error for user cancellation
        case .notEntitled:
            return "You don't have access to this subscription."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .verificationFailed:
            return "Purchase verification failed. Please contact support."
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }

    /// User-friendly error message for display
    public var userMessage: String {
        errorDescription ?? "Something went wrong. Please try again."
    }

    /// Whether this error should be shown to the user
    public var shouldShowToUser: Bool {
        switch self {
        case .purchaseCancelled:
            return false
        default:
            return true
        }
    }
}
