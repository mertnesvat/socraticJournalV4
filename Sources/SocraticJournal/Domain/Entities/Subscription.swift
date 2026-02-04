// Subscription.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

// MARK: - Subscription Period

/// Represents the billing period for a subscription
public enum SubscriptionPeriod: String, Codable, Sendable, Equatable, CaseIterable {
    case monthly
    case yearly

    public var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    public var shortName: String {
        switch self {
        case .monthly: return "mo"
        case .yearly: return "yr"
        }
    }
}

// MARK: - Subscription Status

/// Represents the current subscription state of a user
public enum SubscriptionStatus: Sendable, Equatable {
    /// User has no active subscription
    case free

    /// User has an active premium subscription
    case premium(expiryDate: Date, productId: String)

    /// User's subscription has expired
    case expired(lastExpiryDate: Date, lastProductId: String)

    /// Whether the user currently has premium access
    public var isPremium: Bool {
        if case .premium = self { return true }
        return false
    }

    /// The expiry date if available
    public var expiryDate: Date? {
        switch self {
        case .free:
            return nil
        case .premium(let date, _):
            return date
        case .expired(let date, _):
            return date
        }
    }

    /// The product ID if available
    public var productId: String? {
        switch self {
        case .free:
            return nil
        case .premium(_, let id):
            return id
        case .expired(_, let id):
            return id
        }
    }

    /// Display name for the current status
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
            let expiryDate = try container.decode(Date.self, forKey: .expiryDate)
            let productId = try container.decode(String.self, forKey: .productId)
            self = .expired(lastExpiryDate: expiryDate, lastProductId: productId)
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
        case .expired(let expiryDate, let productId):
            try container.encode(StatusType.expired, forKey: .type)
            try container.encode(expiryDate, forKey: .expiryDate)
            try container.encode(productId, forKey: .productId)
        }
    }
}

// MARK: - Subscription Product

/// Represents a subscription product available for purchase
public struct SubscriptionProduct: Sendable, Equatable, Identifiable {
    /// The product identifier from App Store Connect
    public let id: String

    /// Localized display name
    public let displayName: String

    /// Localized display price (e.g., "$4.99")
    public let displayPrice: String

    /// The subscription period
    public let period: SubscriptionPeriod

    /// The actual price value for calculations
    public let priceValue: Decimal

    /// Optional description
    public let description: String?

    public init(
        id: String,
        displayName: String,
        displayPrice: String,
        period: SubscriptionPeriod,
        priceValue: Decimal,
        description: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.displayPrice = displayPrice
        self.period = period
        self.priceValue = priceValue
        self.description = description
    }

    /// Calculate monthly price for comparison
    public var monthlyPrice: Decimal {
        switch period {
        case .monthly:
            return priceValue
        case .yearly:
            return priceValue / 12
        }
    }

    /// Calculate savings percentage compared to monthly pricing
    /// - Parameter monthlyProduct: The monthly subscription to compare against
    /// - Returns: Savings percentage (0-100)
    public func savingsPercentage(comparedTo monthlyProduct: SubscriptionProduct) -> Int {
        guard period == .yearly, monthlyProduct.period == .monthly else { return 0 }
        let yearlyTotal = priceValue
        let monthlyTotal = monthlyProduct.priceValue * 12
        guard monthlyTotal > 0 else { return 0 }
        let savings = ((monthlyTotal - yearlyTotal) / monthlyTotal) * 100
        // Convert Decimal to Double for proper rounding
        let savingsDouble = NSDecimalNumber(decimal: savings).doubleValue
        return Int(savingsDouble.rounded())
    }
}

// MARK: - Subscription Error

/// Errors that can occur during subscription operations
public enum SubscriptionError: Error, LocalizedError, Equatable, Sendable {
    /// The requested product was not found in the App Store
    case productNotFound

    /// The purchase failed with an underlying error
    case purchaseFailed(String)

    /// The user cancelled the purchase
    case purchaseCancelled

    /// The user is not entitled to the requested content
    case notEntitled

    /// A network error occurred
    case networkError(String)

    /// The subscription verification failed
    case verificationFailed

    /// StoreKit is not available on this device
    case storeKitNotAvailable

    /// Unknown error occurred
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "The subscription product could not be found. Please try again later."
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .purchaseCancelled:
            return "Purchase was cancelled."
        case .notEntitled:
            return "You are not entitled to this content."
        case .networkError(let message):
            return "Network error: \(message)"
        case .verificationFailed:
            return "Could not verify your purchase. Please try again."
        case .storeKitNotAvailable:
            return "The App Store is not available on this device."
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }

    /// User-friendly message to display in UI
    public var userFriendlyMessage: String {
        switch self {
        case .productNotFound:
            return "Unable to load subscription options. Please check your connection and try again."
        case .purchaseFailed:
            return "We couldn't complete your purchase. Please try again."
        case .purchaseCancelled:
            return "" // Don't show a message for cancellation
        case .notEntitled:
            return "This content requires a premium subscription."
        case .networkError:
            return "Please check your internet connection and try again."
        case .verificationFailed:
            return "We couldn't verify your purchase. Please try restoring purchases."
        case .storeKitNotAvailable:
            return "Subscriptions are not available on this device."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }

    /// Whether to show this error to the user
    public var shouldShowToUser: Bool {
        if case .purchaseCancelled = self { return false }
        return true
    }
}

// MARK: - Product IDs

/// App Store Connect product identifiers
public enum SubscriptionProductID {
    public static let monthly = "com.StudioNext.socraticJournal.monthly"
    public static let yearly = "com.StudioNext.socraticJournal.yearly"

    public static var all: [String] {
        [monthly, yearly]
    }
}
