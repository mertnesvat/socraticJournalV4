// SubscriptionServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the subscription service interface
/// Manages subscription products, purchases, and status
public protocol SubscriptionServiceProtocol: Sendable {
    /// Fetches available subscription products from the App Store
    /// - Returns: Array of available subscription products
    /// - Throws: SubscriptionError if products cannot be fetched
    func fetchProducts() async throws -> [SubscriptionProduct]

    /// Initiates a purchase for the specified product
    /// - Parameter product: The subscription product to purchase
    /// - Returns: The updated subscription status after purchase
    /// - Throws: SubscriptionError if purchase fails
    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus

    /// Restores previously purchased subscriptions
    /// - Returns: The restored subscription status
    /// - Throws: SubscriptionError if restore fails
    func restorePurchases() async throws -> SubscriptionStatus

    /// Returns the current subscription status
    /// - Returns: Current subscription status
    func currentStatus() async -> SubscriptionStatus

    /// Stream of subscription status updates
    /// Emits when subscription status changes (purchase, expiration, etc.)
    var statusStream: AsyncStream<SubscriptionStatus> { get }
}

// MARK: - Product Identifiers

/// Product identifiers for Socratic Journal subscriptions
public enum SubscriptionProductId {
    public static let monthly = "com.StudioNext.socraticJournal.monthly"
    public static let yearly = "com.StudioNext.socraticJournal.yearly"

    /// All available product identifiers
    public static var all: Set<String> {
        [monthly, yearly]
    }
}
