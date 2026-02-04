// SubscriptionServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining the subscription service interface
/// Manages subscription products, purchases, and entitlement status
public protocol SubscriptionServiceProtocol: Sendable {
    /// Fetches available subscription products from the App Store
    /// - Returns: Array of available subscription products
    /// - Throws: `SubscriptionError` if products cannot be fetched
    func fetchProducts() async throws -> [SubscriptionProduct]

    /// Initiates a purchase for the given product
    /// - Parameter product: The subscription product to purchase
    /// - Returns: The updated subscription status after purchase
    /// - Throws: `SubscriptionError` if purchase fails or is cancelled
    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus

    /// Restores previously purchased subscriptions
    /// - Returns: The subscription status after restoration attempt
    /// - Throws: `SubscriptionError` if restoration fails
    func restorePurchases() async throws -> SubscriptionStatus

    /// Returns the current subscription status
    /// Checks both local cache and verifies with StoreKit if needed
    /// - Returns: The current subscription status
    func currentStatus() async -> SubscriptionStatus

    /// Stream of subscription status updates
    /// Emits when subscription status changes (purchase, expiry, restore)
    var statusStream: AsyncStream<SubscriptionStatus> { get }
}
