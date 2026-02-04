// SubscriptionServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the subscription service interface
/// Manages subscription products, purchases, and status tracking
public protocol SubscriptionServiceProtocol: Sendable {
    /// Fetches available subscription products from the App Store
    /// - Returns: Array of available subscription products
    /// - Throws: SubscriptionError if products cannot be fetched
    func fetchProducts() async throws -> [SubscriptionProduct]

    /// Purchases a subscription product
    /// - Parameter product: The product to purchase
    /// - Returns: The new subscription status after purchase
    /// - Throws: SubscriptionError if purchase fails
    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus

    /// Restores previous purchases
    /// - Returns: The subscription status after restoration
    /// - Throws: SubscriptionError if restoration fails
    func restorePurchases() async throws -> SubscriptionStatus

    /// Gets the current subscription status
    /// - Returns: The current subscription status
    func currentStatus() async -> SubscriptionStatus

    /// A stream of subscription status updates
    /// Use this to observe real-time changes to subscription status
    var statusStream: AsyncStream<SubscriptionStatus> { get }
}

/// Extension with helper methods for subscription management
extension SubscriptionServiceProtocol {
    /// Checks if the user currently has premium access
    /// - Returns: True if the user has an active premium subscription
    public func isPremium() async -> Bool {
        await currentStatus().isPremium
    }

    /// Gets the monthly product from a list of products
    /// - Parameter products: List of subscription products
    /// - Returns: The monthly product if found
    public func monthlyProduct(from products: [SubscriptionProduct]) -> SubscriptionProduct? {
        products.first { $0.period == .monthly }
    }

    /// Gets the yearly product from a list of products
    /// - Parameter products: List of subscription products
    /// - Returns: The yearly product if found
    public func yearlyProduct(from products: [SubscriptionProduct]) -> SubscriptionProduct? {
        products.first { $0.period == .yearly }
    }
}
