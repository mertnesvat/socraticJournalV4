// SubscriptionServiceTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for subscription service and domain entities
@Suite("Subscription Service Tests")
struct SubscriptionServiceTests {

    // MARK: - SubscriptionProduct Tests

    @Suite("SubscriptionProduct")
    struct SubscriptionProductTests {

        @Test("Monthly price returns correct value for monthly product")
        func monthlyPriceForMonthly() {
            let product = SubscriptionProduct(
                id: "test.monthly",
                displayName: "Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            )

            #expect(product.monthlyPrice == 4.99)
        }

        @Test("Monthly price calculates correctly for yearly product")
        func monthlyPriceForYearly() {
            let product = SubscriptionProduct(
                id: "test.yearly",
                displayName: "Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )

            let expectedMonthly = Decimal(29.99) / 12
            #expect(product.monthlyPrice == expectedMonthly)
        }

        @Test("Savings percentage calculates correctly")
        func savingsPercentageCalculation() {
            let monthly = SubscriptionProduct(
                id: "test.monthly",
                displayName: "Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            )

            let yearly = SubscriptionProduct(
                id: "test.yearly",
                displayName: "Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )

            // Yearly = $29.99, Monthly * 12 = $59.88
            // Savings = (59.88 - 29.99) / 59.88 = ~50%
            let savings = yearly.savingsPercentage(comparedTo: monthly)
            #expect(savings >= 49 && savings <= 51)
        }

        @Test("Savings percentage returns 0 for monthly product")
        func savingsPercentageForMonthly() {
            let monthly = SubscriptionProduct(
                id: "test.monthly",
                displayName: "Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            )

            let yearly = SubscriptionProduct(
                id: "test.yearly",
                displayName: "Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )

            #expect(monthly.savingsPercentage(comparedTo: yearly) == 0)
        }
    }

    // MARK: - SubscriptionStatus Tests

    @Suite("SubscriptionStatus")
    struct SubscriptionStatusTests {

        @Test("Free status is not premium")
        func freeStatusNotPremium() {
            let status = SubscriptionStatus.free
            #expect(!status.isPremium)
        }

        @Test("Premium status is premium")
        func premiumStatusIsPremium() {
            let expiryDate = Date().addingTimeInterval(86400 * 30)
            let status = SubscriptionStatus.premium(expiryDate: expiryDate, productId: "test")
            #expect(status.isPremium)
        }

        @Test("Expired status is not premium")
        func expiredStatusNotPremium() {
            let expiryDate = Date().addingTimeInterval(-86400)
            let status = SubscriptionStatus.expired(lastExpiryDate: expiryDate, lastProductId: "test")
            #expect(!status.isPremium)
        }

        @Test("Free status has nil expiry date")
        func freeStatusNilExpiryDate() {
            let status = SubscriptionStatus.free
            #expect(status.expiryDate == nil)
        }

        @Test("Premium status has expiry date")
        func premiumStatusHasExpiryDate() {
            let expiryDate = Date().addingTimeInterval(86400 * 30)
            let status = SubscriptionStatus.premium(expiryDate: expiryDate, productId: "test")
            #expect(status.expiryDate == expiryDate)
        }

        @Test("Expired status has last expiry date")
        func expiredStatusHasLastExpiryDate() {
            let expiryDate = Date().addingTimeInterval(-86400)
            let status = SubscriptionStatus.expired(lastExpiryDate: expiryDate, lastProductId: "test")
            #expect(status.expiryDate == expiryDate)
        }

        @Test("Display names are correct")
        func displayNames() {
            #expect(SubscriptionStatus.free.displayName == "Free")
            #expect(SubscriptionStatus.premium(expiryDate: Date(), productId: "test").displayName == "Premium")
            #expect(SubscriptionStatus.expired(lastExpiryDate: Date(), lastProductId: "test").displayName == "Expired")
        }

        @Test("SubscriptionStatus is Codable")
        func codable() throws {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Test free
            let freeData = try encoder.encode(SubscriptionStatus.free)
            let decodedFree = try decoder.decode(SubscriptionStatus.self, from: freeData)
            #expect(decodedFree == .free)

            // Test premium
            let expiryDate = Date()
            let premium = SubscriptionStatus.premium(expiryDate: expiryDate, productId: "test.monthly")
            let premiumData = try encoder.encode(premium)
            let decodedPremium = try decoder.decode(SubscriptionStatus.self, from: premiumData)
            #expect(decodedPremium == premium)

            // Test expired
            let expired = SubscriptionStatus.expired(lastExpiryDate: expiryDate, lastProductId: "test.monthly")
            let expiredData = try encoder.encode(expired)
            let decodedExpired = try decoder.decode(SubscriptionStatus.self, from: expiredData)
            #expect(decodedExpired == expired)
        }
    }

    // MARK: - SubscriptionError Tests

    @Suite("SubscriptionError")
    struct SubscriptionErrorTests {

        @Test("Purchase cancelled should not show to user")
        func purchaseCancelledNotShownToUser() {
            let error = SubscriptionError.purchaseCancelled
            #expect(!error.shouldShowToUser)
        }

        @Test("Other errors should show to user")
        func otherErrorsShownToUser() {
            #expect(SubscriptionError.productNotFound.shouldShowToUser)
            #expect(SubscriptionError.purchaseFailed("test").shouldShowToUser)
            #expect(SubscriptionError.networkError("test").shouldShowToUser)
            #expect(SubscriptionError.verificationFailed.shouldShowToUser)
        }

        @Test("User friendly messages are not empty")
        func userFriendlyMessagesNotEmpty() {
            #expect(!SubscriptionError.productNotFound.userFriendlyMessage.isEmpty)
            #expect(!SubscriptionError.purchaseFailed("test").userFriendlyMessage.isEmpty)
            #expect(!SubscriptionError.networkError("test").userFriendlyMessage.isEmpty)
            #expect(SubscriptionError.purchaseCancelled.userFriendlyMessage.isEmpty)
        }

        @Test("Error descriptions are not empty")
        func errorDescriptionsNotEmpty() {
            #expect(SubscriptionError.productNotFound.errorDescription != nil)
            #expect(SubscriptionError.purchaseFailed("test").errorDescription != nil)
            #expect(SubscriptionError.purchaseCancelled.errorDescription != nil)
            #expect(SubscriptionError.notEntitled.errorDescription != nil)
            #expect(SubscriptionError.networkError("test").errorDescription != nil)
            #expect(SubscriptionError.verificationFailed.errorDescription != nil)
            #expect(SubscriptionError.storeKitNotAvailable.errorDescription != nil)
            #expect(SubscriptionError.unknown("test").errorDescription != nil)
        }
    }

    // MARK: - Mock Service Tests

    @Suite("Mock Subscription Service")
    struct MockServiceTests {
        var service: TestMockSubscriptionService!

        init() {
            service = TestMockSubscriptionService()
        }

        @Test("Fetch products returns mock products")
        func fetchProductsSuccess() async throws {
            let products = try await service.fetchProducts()

            #expect(products.count == 2)
            #expect(service.fetchProductsCalled)
            #expect(service.fetchProductsCallCount == 1)
        }

        @Test("Fetch products can fail")
        func fetchProductsFailure() async {
            service.shouldFailFetch = true

            await #expect(throws: SubscriptionError.self) {
                try await service.fetchProducts()
            }
        }

        @Test("Fetch products returns empty when configured")
        func fetchProductsEmpty() async throws {
            service.mockProducts = []

            let products = try await service.fetchProducts()
            #expect(products.isEmpty)
        }

        @Test("Purchase succeeds and updates status")
        func purchaseSuccess() async throws {
            let product = service.mockProducts[0]

            let status = try await service.purchase(product)

            #expect(service.purchaseCalled)
            #expect(service.purchasedProduct?.id == product.id)
            #expect(status.isPremium)
        }

        @Test("Purchase can be cancelled")
        func purchaseCancelled() async {
            service.shouldCancelPurchase = true
            let product = service.mockProducts[0]

            await #expect(throws: SubscriptionError.self) {
                try await service.purchase(product)
            }
        }

        @Test("Purchase can fail")
        func purchaseFailure() async {
            service.shouldFailPurchase = true
            let product = service.mockProducts[0]

            await #expect(throws: SubscriptionError.self) {
                try await service.purchase(product)
            }
        }

        @Test("Restore purchases returns current status")
        func restoreSuccess() async throws {
            service.setPremium(daysUntilExpiry: 30)

            let status = try await service.restorePurchases()

            #expect(service.restorePurchasesCalled)
            #expect(status.isPremium)
        }

        @Test("Restore purchases finds no subscription")
        func restoreNoSubscription() async throws {
            service.mockStatus = .free

            let status = try await service.restorePurchases()

            #expect(!status.isPremium)
        }

        @Test("Restore purchases can fail")
        func restoreFailure() async {
            service.shouldFailRestore = true

            await #expect(throws: SubscriptionError.self) {
                try await service.restorePurchases()
            }
        }

        @Test("Current status returns mock status")
        func currentStatusReturnsCorrect() async {
            service.setPremium(daysUntilExpiry: 30)

            let status = await service.currentStatus()

            #expect(status.isPremium)
            #expect(service.currentStatusCalled)
        }

        @Test("Status transitions from free to premium")
        func statusTransitionFreeToPremium() async throws {
            #expect(!service.mockStatus.isPremium)

            let product = service.mockProducts[0]
            let status = try await service.purchase(product)

            #expect(status.isPremium)
            #expect(service.mockStatus.isPremium)
        }

        @Test("Reset clears all state")
        func resetClearsState() async throws {
            // Perform some operations
            _ = try await service.fetchProducts()
            _ = try await service.purchase(service.mockProducts[0])
            _ = try await service.restorePurchases()

            service.reset()

            #expect(!service.fetchProductsCalled)
            #expect(!service.purchaseCalled)
            #expect(!service.restorePurchasesCalled)
            #expect(service.mockStatus == .free)
        }
    }

    // MARK: - SubscriptionPeriod Tests

    @Suite("SubscriptionPeriod")
    struct SubscriptionPeriodTests {

        @Test("Display names are correct")
        func displayNames() {
            #expect(SubscriptionPeriod.monthly.displayName == "Monthly")
            #expect(SubscriptionPeriod.yearly.displayName == "Yearly")
        }

        @Test("Short names are correct")
        func shortNames() {
            #expect(SubscriptionPeriod.monthly.shortName == "mo")
            #expect(SubscriptionPeriod.yearly.shortName == "yr")
        }

        @Test("Raw values are correct")
        func rawValues() {
            #expect(SubscriptionPeriod.monthly.rawValue == "monthly")
            #expect(SubscriptionPeriod.yearly.rawValue == "yearly")
        }
    }

    // MARK: - Product IDs Tests

    @Suite("SubscriptionProductID")
    struct SubscriptionProductIDTests {

        @Test("Product IDs are correct")
        func productIDs() {
            #expect(SubscriptionProductID.monthly == "com.StudioNext.socraticJournal.monthly")
            #expect(SubscriptionProductID.yearly == "com.StudioNext.socraticJournal.yearly")
        }

        @Test("All returns both product IDs")
        func allProductIDs() {
            let all = SubscriptionProductID.all
            #expect(all.count == 2)
            #expect(all.contains(SubscriptionProductID.monthly))
            #expect(all.contains(SubscriptionProductID.yearly))
        }
    }
}
