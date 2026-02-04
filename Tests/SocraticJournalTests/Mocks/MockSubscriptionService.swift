// MockSubscriptionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock subscription service for testing
/// Allows configuring return values and simulating various scenarios
public final class MockSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
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

    public private(set) var fetchProductsCalled = false
    public private(set) var purchaseCalled = false
    public private(set) var purchasedProduct: SubscriptionProduct?
    public private(set) var restoreCalled = false
    public private(set) var currentStatusCalled = false

    // MARK: - Status Stream

    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?

    public lazy var statusStream: AsyncStream<SubscriptionStatus> = {
        AsyncStream { continuation in
            self.statusContinuation = continuation
            continuation.yield(self.currentStatusValue)
        }
    }()

    // MARK: - Initialization

    public init() {}

    // MARK: - SubscriptionServiceProtocol

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        fetchProductsCalled = true

        if let error = fetchProductsError {
            throw error
        }

        return productsToReturn
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        purchaseCalled = true
        purchasedProduct = product

        if let error = purchaseError {
            throw error
        }

        statusContinuation?.yield(purchaseStatus)
        return purchaseStatus
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        restoreCalled = true

        if let error = restoreError {
            throw error
        }

        statusContinuation?.yield(restoreStatus)
        return restoreStatus
    }

    public func currentStatus() async -> SubscriptionStatus {
        currentStatusCalled = true
        return currentStatusValue
    }

    // MARK: - Test Helpers

    /// Emits a new status to the status stream
    public func emitStatus(_ status: SubscriptionStatus) {
        statusContinuation?.yield(status)
    }

    /// Resets all tracking state
    public func reset() {
        fetchProductsCalled = false
        purchaseCalled = false
        purchasedProduct = nil
        restoreCalled = false
        currentStatusCalled = false
    }

    /// Creates a standard set of test products
    public static func createTestProducts() -> [SubscriptionProduct] {
        [
            SubscriptionProduct(
                id: SubscriptionProductId.monthly,
                displayName: "Monthly Premium",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            ),
            SubscriptionProduct(
                id: SubscriptionProductId.yearly,
                displayName: "Yearly Premium",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )
        ]
    }
}
