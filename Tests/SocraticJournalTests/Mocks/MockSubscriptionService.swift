// MockSubscriptionService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock subscription service for testing
public final class TestMockSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    // MARK: - Configuration

    public var mockProducts: [SubscriptionProduct] = [
        SubscriptionProduct(
            id: SubscriptionProductID.monthly,
            displayName: "Monthly Premium",
            displayPrice: "$4.99",
            period: .monthly,
            priceValue: 4.99,
            description: "Full access to all premium features"
        ),
        SubscriptionProduct(
            id: SubscriptionProductID.yearly,
            displayName: "Yearly Premium",
            displayPrice: "$29.99",
            period: .yearly,
            priceValue: 29.99,
            description: "Save 50% with annual billing"
        )
    ]

    public var mockStatus: SubscriptionStatus = .free
    public var shouldFailFetch: Bool = false
    public var fetchError: SubscriptionError = .networkError("Mock network error")
    public var shouldFailPurchase: Bool = false
    public var purchaseError: SubscriptionError = .purchaseFailed("Mock purchase error")
    public var shouldCancelPurchase: Bool = false
    public var shouldFailRestore: Bool = false
    public var restoreError: SubscriptionError = .networkError("Mock restore error")

    // MARK: - Call Tracking

    public private(set) var fetchProductsCalled: Bool = false
    public private(set) var fetchProductsCallCount: Int = 0
    public private(set) var purchaseCalled: Bool = false
    public private(set) var purchaseCallCount: Int = 0
    public private(set) var purchasedProduct: SubscriptionProduct?
    public private(set) var restorePurchasesCalled: Bool = false
    public private(set) var restorePurchasesCallCount: Int = 0
    public private(set) var currentStatusCalled: Bool = false
    public private(set) var currentStatusCallCount: Int = 0

    // MARK: - Status Stream

    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?
    public let statusStream: AsyncStream<SubscriptionStatus>

    // MARK: - Initialization

    public init() {
        var continuation: AsyncStream<SubscriptionStatus>.Continuation?
        statusStream = AsyncStream { cont in
            continuation = cont
        }
        statusContinuation = continuation
    }

    // MARK: - Protocol Methods

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        fetchProductsCalled = true
        fetchProductsCallCount += 1

        // Simulate network delay
        try await Task.sleep(for: .milliseconds(10))

        if shouldFailFetch {
            throw fetchError
        }
        return mockProducts
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        purchaseCalled = true
        purchaseCallCount += 1
        purchasedProduct = product

        // Simulate purchase delay
        try await Task.sleep(for: .milliseconds(10))

        if shouldCancelPurchase {
            throw SubscriptionError.purchaseCancelled
        }

        if shouldFailPurchase {
            throw purchaseError
        }

        // Simulate successful purchase
        let expiryDate = Calendar.current.date(
            byAdding: product.period == .monthly ? .month : .year,
            value: 1,
            to: Date()
        )!
        mockStatus = .premium(expiryDate: expiryDate, productId: product.id)
        statusContinuation?.yield(mockStatus)
        return mockStatus
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        restorePurchasesCalled = true
        restorePurchasesCallCount += 1

        // Simulate restore delay
        try await Task.sleep(for: .milliseconds(10))

        if shouldFailRestore {
            throw restoreError
        }

        statusContinuation?.yield(mockStatus)
        return mockStatus
    }

    public func currentStatus() async -> SubscriptionStatus {
        currentStatusCalled = true
        currentStatusCallCount += 1
        return mockStatus
    }

    // MARK: - Test Helpers

    /// Resets all call tracking state
    public func reset() {
        fetchProductsCalled = false
        fetchProductsCallCount = 0
        purchaseCalled = false
        purchaseCallCount = 0
        purchasedProduct = nil
        restorePurchasesCalled = false
        restorePurchasesCallCount = 0
        currentStatusCalled = false
        currentStatusCallCount = 0
        shouldFailFetch = false
        shouldFailPurchase = false
        shouldCancelPurchase = false
        shouldFailRestore = false
        mockStatus = .free
    }

    /// Simulates a status change event
    public func simulateStatusChange(_ status: SubscriptionStatus) {
        mockStatus = status
        statusContinuation?.yield(status)
    }

    /// Sets up a premium subscription
    public func setPremium(daysUntilExpiry: Int = 30, productId: String = SubscriptionProductID.monthly) {
        let expiryDate = Calendar.current.date(byAdding: .day, value: daysUntilExpiry, to: Date())!
        mockStatus = .premium(expiryDate: expiryDate, productId: productId)
    }

    /// Sets up an expired subscription
    public func setExpired(daysAgo: Int = 7, productId: String = SubscriptionProductID.monthly) {
        let expiryDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        mockStatus = .expired(lastExpiryDate: expiryDate, lastProductId: productId)
    }
}
