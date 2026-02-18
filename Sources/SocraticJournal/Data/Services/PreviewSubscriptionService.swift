// PreviewSubscriptionService.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Lightweight mock subscription service for SwiftUI previews.
/// For comprehensive test mocks, see TestMockSubscriptionService in the test target.
public final class PreviewSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    public init() {}

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        [
            SubscriptionProduct(
                id: SubscriptionProductID.yearly,
                displayName: "Yearly Premium",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99,
                description: "Save 50% with annual billing"
            ),
            SubscriptionProduct(
                id: SubscriptionProductID.monthly,
                displayName: "Monthly Premium",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99,
                description: "Full access to all features"
            )
        ]
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        .premium(expiryDate: Date().addingTimeInterval(86400 * 30), productId: product.id)
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        .free
    }

    public func currentStatus() async -> SubscriptionStatus {
        .free
    }

    public var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream { _ in }
    }
}
