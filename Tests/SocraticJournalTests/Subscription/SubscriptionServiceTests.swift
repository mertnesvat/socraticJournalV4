// SubscriptionServiceTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for subscription domain entities and service behavior
@Suite("Subscription Service Tests")
struct SubscriptionServiceTests {

    // MARK: - SubscriptionStatus Tests

    @Suite("SubscriptionStatus")
    struct SubscriptionStatusTests {

        @Test("Free status is not premium")
        func freeIsNotPremium() {
            let status = SubscriptionStatus.free
            #expect(!status.isPremium)
            #expect(status.expiryDate == nil)
            #expect(status.productId == nil)
            #expect(status.displayName == "Free")
        }

        @Test("Premium status is premium")
        func premiumIsPremium() {
            let expiryDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
            let status = SubscriptionStatus.premium(expiryDate: expiryDate, productId: "test.product")

            #expect(status.isPremium)
            #expect(status.expiryDate == expiryDate)
            #expect(status.productId == "test.product")
            #expect(status.displayName == "Premium")
        }

        @Test("Expired status is not premium")
        func expiredIsNotPremium() {
            let status = SubscriptionStatus.expired
            #expect(!status.isPremium)
            #expect(status.displayName == "Expired")
        }

        @Test("SubscriptionStatus is Codable")
        func codable() throws {
            let statuses: [SubscriptionStatus] = [
                .free,
                .premium(expiryDate: Date(), productId: "test.product"),
                .expired
            ]

            for original in statuses {
                let encoder = JSONEncoder()
                let data = try encoder.encode(original)

                let decoder = JSONDecoder()
                let decoded = try decoder.decode(SubscriptionStatus.self, from: data)

                #expect(decoded == original)
            }
        }

        @Test("SubscriptionStatus is Equatable")
        func equatable() {
            let date = Date()

            #expect(SubscriptionStatus.free == SubscriptionStatus.free)
            #expect(SubscriptionStatus.expired == SubscriptionStatus.expired)
            #expect(SubscriptionStatus.premium(expiryDate: date, productId: "test") ==
                    SubscriptionStatus.premium(expiryDate: date, productId: "test"))

            #expect(SubscriptionStatus.free != SubscriptionStatus.expired)
            #expect(SubscriptionStatus.free != SubscriptionStatus.premium(expiryDate: date, productId: "test"))
        }
    }

    // MARK: - SubscriptionProduct Tests

    @Suite("SubscriptionProduct")
    struct SubscriptionProductTests {

        @Test("Product monthly equivalent returns nil for monthly")
        func monthlyEquivalentForMonthly() {
            let product = SubscriptionProduct(
                id: "test.monthly",
                displayName: "Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            )

            #expect(product.monthlyEquivalent == nil)
        }

        @Test("Product monthly equivalent calculates correctly for yearly")
        func monthlyEquivalentForYearly() {
            let product = SubscriptionProduct(
                id: "test.yearly",
                displayName: "Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 24.00 // $24/year = $2/month
            )

            let expected = Decimal(2)
            #expect(product.monthlyEquivalent == expected)
        }

        @Test("Savings percentage calculates correctly")
        func savingsPercentage() {
            let monthly = SubscriptionProduct(
                id: "test.monthly",
                displayName: "Monthly",
                displayPrice: "$5.00",
                period: .monthly,
                priceValue: 5.00
            )

            let yearly = SubscriptionProduct(
                id: "test.yearly",
                displayName: "Yearly",
                displayPrice: "$30.00",
                period: .yearly,
                priceValue: 30.00 // $60/year if monthly, so 50% savings
            )

            let savings = yearly.savingsPercentage(comparedTo: monthly)
            #expect(savings == 50)
        }

        @Test("Savings percentage returns nil for monthly product")
        func savingsPercentageForMonthly() {
            let monthly1 = SubscriptionProduct(
                id: "test.monthly1",
                displayName: "Monthly 1",
                displayPrice: "$5.00",
                period: .monthly,
                priceValue: 5.00
            )

            let monthly2 = SubscriptionProduct(
                id: "test.monthly2",
                displayName: "Monthly 2",
                displayPrice: "$4.00",
                period: .monthly,
                priceValue: 4.00
            )

            #expect(monthly1.savingsPercentage(comparedTo: monthly2) == nil)
        }

        @Test("Product ID constants are correct")
        func productIDConstants() {
            #expect(SubscriptionProductID.monthly == "com.StudioNext.socraticJournal.monthly")
            #expect(SubscriptionProductID.yearly == "com.StudioNext.socraticJournal.yearly")
            #expect(SubscriptionProductID.all.count == 2)
        }
    }

    // MARK: - SubscriptionPeriod Tests

    @Suite("SubscriptionPeriod")
    struct SubscriptionPeriodTests {

        @Test("Period display names are correct")
        func displayNames() {
            #expect(SubscriptionPeriod.monthly.displayName == "Monthly")
            #expect(SubscriptionPeriod.yearly.displayName == "Yearly")
        }

        @Test("Period short names are correct")
        func shortNames() {
            #expect(SubscriptionPeriod.monthly.shortName == "month")
            #expect(SubscriptionPeriod.yearly.shortName == "year")
        }

        @Test("Period is Codable")
        func codable() throws {
            let periods: [SubscriptionPeriod] = [.monthly, .yearly]

            for original in periods {
                let encoder = JSONEncoder()
                let data = try encoder.encode(original)

                let decoder = JSONDecoder()
                let decoded = try decoder.decode(SubscriptionPeriod.self, from: data)

                #expect(decoded == original)
            }
        }
    }

    // MARK: - SubscriptionError Tests

    @Suite("SubscriptionError")
    struct SubscriptionErrorTests {

        @Test("Error messages are user-friendly")
        func errorMessages() {
            #expect(SubscriptionError.productNotFound.errorDescription != nil)
            #expect(SubscriptionError.networkError.errorDescription != nil)
            #expect(SubscriptionError.verificationFailed.errorDescription != nil)
            #expect(SubscriptionError.notEntitled.errorDescription != nil)
        }

        @Test("Purchase cancelled has no error description")
        func purchaseCancelledNoMessage() {
            #expect(SubscriptionError.purchaseCancelled.errorDescription == nil)
        }

        @Test("Should show to user returns correct values")
        func shouldShowToUser() {
            #expect(SubscriptionError.productNotFound.shouldShowToUser)
            #expect(SubscriptionError.networkError.shouldShowToUser)
            #expect(!SubscriptionError.purchaseCancelled.shouldShowToUser)
        }

        @Test("User message always returns something")
        func userMessage() {
            let errors: [SubscriptionError] = [
                .productNotFound,
                .purchaseFailed("test"),
                .purchaseCancelled,
                .notEntitled,
                .networkError,
                .verificationFailed,
                .unknown("test")
            ]

            for error in errors {
                #expect(!error.userMessage.isEmpty)
            }
        }
    }

    // MARK: - Mock Service Tests

    @Suite("MockSubscriptionService")
    @MainActor
    struct MockServiceTests {

        @Test("Fetch products returns configured products")
        func fetchProducts() async throws {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts

            let products = try await service.fetchProducts()

            #expect(products.count == 2)
            #expect(service.fetchProductsCallCount == 1)
        }

        @Test("Fetch products throws configured error")
        func fetchProductsError() async {
            let service = MockSubscriptionService()
            service.fetchProductsError = .networkError

            do {
                _ = try await service.fetchProducts()
                #expect(Bool(false), "Should have thrown")
            } catch let error as SubscriptionError {
                #expect(error == .networkError)
            } catch {
                #expect(Bool(false), "Wrong error type")
            }
        }

        @Test("Purchase returns configured status")
        func purchase() async throws {
            let service = MockSubscriptionService()
            let product = MockSubscriptionService.testProducts[0]
            service.purchaseStatus = MockSubscriptionService.testPremiumStatus()

            let status = try await service.purchase(product)

            #expect(status.isPremium)
            #expect(service.purchaseCallCount == 1)
            #expect(service.purchasedProducts.count == 1)
        }

        @Test("Purchase throws configured error")
        func purchaseError() async {
            let service = MockSubscriptionService()
            let product = MockSubscriptionService.testProducts[0]
            service.purchaseError = .purchaseCancelled

            do {
                _ = try await service.purchase(product)
                #expect(Bool(false), "Should have thrown")
            } catch let error as SubscriptionError {
                #expect(error == .purchaseCancelled)
            } catch {
                #expect(Bool(false), "Wrong error type")
            }
        }

        @Test("Restore returns configured status")
        func restore() async throws {
            let service = MockSubscriptionService()
            service.restoreStatus = MockSubscriptionService.testPremiumStatus()

            let status = try await service.restorePurchases()

            #expect(status.isPremium)
            #expect(service.restoreCallCount == 1)
        }

        @Test("Current status returns configured value")
        func currentStatus() async {
            let service = MockSubscriptionService()
            service.currentStatusValue = MockSubscriptionService.testPremiumStatus()

            let status = await service.currentStatus()

            #expect(status.isPremium)
            #expect(service.currentStatusCallCount == 1)
        }

        @Test("Reset clears all state")
        func reset() async throws {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            service.purchaseStatus = MockSubscriptionService.testPremiumStatus()
            _ = try await service.fetchProducts()
            _ = try await service.purchase(MockSubscriptionService.testProducts[0])

            service.reset()

            #expect(service.productsToReturn.isEmpty)
            #expect(service.fetchProductsCallCount == 0)
            #expect(service.purchaseCallCount == 0)
            #expect(!service.purchaseStatus.isPremium)
        }
    }
}
