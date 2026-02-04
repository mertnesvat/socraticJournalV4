// MockSubscriptionService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock implementation of SubscriptionServiceProtocol for testing
@MainActor
public final class MockSubscriptionService: SubscriptionServiceProtocol {
    // MARK: - Configuration

    /// Products to return from fetchProducts()
    public var productsToReturn: [SubscriptionProduct] = []

    /// Error to throw from fetchProducts()
    public var fetchProductsError: SubscriptionError?

    /// Status to return from purchase()
    public var purchaseStatus: SubscriptionStatus = .free

    /// Error to throw from purchase()
    public var purchaseError: SubscriptionError?

    /// Status to return from restorePurchases()
    public var restoreStatus: SubscriptionStatus = .free

    /// Error to throw from restorePurchases()
    public var restoreError: SubscriptionError?

    /// Current status to return
    public var currentStatusValue: SubscriptionStatus = .free

    // MARK: - Call Tracking

    /// Number of times fetchProducts was called
    public private(set) var fetchProductsCallCount = 0

    /// Number of times purchase was called
    public private(set) var purchaseCallCount = 0

    /// Products passed to purchase()
    public private(set) var purchasedProducts: [SubscriptionProduct] = []

    /// Number of times restorePurchases was called
    public private(set) var restoreCallCount = 0

    /// Number of times currentStatus was called
    public private(set) var currentStatusCallCount = 0

    // MARK: - Status Stream

    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?

    public var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream { continuation in
            self.statusContinuation = continuation
            continuation.yield(self.currentStatusValue)
        }
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - SubscriptionServiceProtocol

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        fetchProductsCallCount += 1

        if let error = fetchProductsError {
            throw error
        }

        return productsToReturn
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        purchaseCallCount += 1
        purchasedProducts.append(product)

        if let error = purchaseError {
            throw error
        }

        currentStatusValue = purchaseStatus
        statusContinuation?.yield(purchaseStatus)
        return purchaseStatus
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        restoreCallCount += 1

        if let error = restoreError {
            throw error
        }

        currentStatusValue = restoreStatus
        statusContinuation?.yield(restoreStatus)
        return restoreStatus
    }

    public func currentStatus() async -> SubscriptionStatus {
        currentStatusCallCount += 1
        return currentStatusValue
    }

    // MARK: - Test Helpers

    /// Emits a status update through the status stream
    public func emitStatus(_ status: SubscriptionStatus) {
        currentStatusValue = status
        statusContinuation?.yield(status)
    }

    /// Resets all call counts and configurations
    public func reset() {
        productsToReturn = []
        fetchProductsError = nil
        purchaseStatus = .free
        purchaseError = nil
        restoreStatus = .free
        restoreError = nil
        currentStatusValue = .free

        fetchProductsCallCount = 0
        purchaseCallCount = 0
        purchasedProducts = []
        restoreCallCount = 0
        currentStatusCallCount = 0
    }

    // MARK: - Test Data Helpers

    /// Returns standard test products
    public static var testProducts: [SubscriptionProduct] {
        [
            SubscriptionProduct(
                id: SubscriptionProductID.monthly,
                displayName: "Premium Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            ),
            SubscriptionProduct(
                id: SubscriptionProductID.yearly,
                displayName: "Premium Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )
        ]
    }

    /// Returns a test premium status
    public static func testPremiumStatus(productId: String = SubscriptionProductID.yearly) -> SubscriptionStatus {
        .premium(expiryDate: Date().addingTimeInterval(365 * 24 * 60 * 60), productId: productId)
    }
}
