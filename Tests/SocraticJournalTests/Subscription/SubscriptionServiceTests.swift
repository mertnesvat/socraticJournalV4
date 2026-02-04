// SubscriptionServiceTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for subscription domain entities and mock service behavior
@Suite("Subscription Service Tests")
struct SubscriptionServiceTests {

    // MARK: - SubscriptionStatus Tests

    @Suite("SubscriptionStatus")
    struct SubscriptionStatusTests {

        @Test("Free status reports not premium")
        func freeStatusNotPremium() {
            let status = SubscriptionStatus.free
            #expect(!status.isPremium)
            #expect(status.expiryDate == nil)
            #expect(status.productId == nil)
            #expect(status.displayName == "Free")
        }

        @Test("Premium status reports premium with correct data")
        func premiumStatusIsPremium() {
            let expiryDate = Date().addingTimeInterval(86400 * 30)
            let productId = "test.product"
            let status = SubscriptionStatus.premium(expiryDate: expiryDate, productId: productId)

            #expect(status.isPremium)
            #expect(status.expiryDate == expiryDate)
            #expect(status.productId == productId)
            #expect(status.displayName == "Premium")
        }

        @Test("Expired status reports not premium")
        func expiredStatusNotPremium() {
            let expiryDate = Date().addingTimeInterval(-86400)
            let productId = "test.product"
            let status = SubscriptionStatus.expired(expiryDate: expiryDate, productId: productId)

            #expect(!status.isPremium)
            #expect(status.expiryDate == expiryDate)
            #expect(status.productId == productId)
            #expect(status.displayName == "Expired")
        }

        @Test("Status is Codable")
        func statusCodable() throws {
            let expiryDate = Date()
            let original = SubscriptionStatus.premium(expiryDate: expiryDate, productId: "test.id")

            let encoded = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(SubscriptionStatus.self, from: encoded)

            #expect(decoded == original)
        }
    }

    // MARK: - SubscriptionProduct Tests

    @Suite("SubscriptionProduct")
    struct SubscriptionProductTests {

        @Test("Monthly product has correct monthly equivalent")
        func monthlyEquivalent() {
            let product = SubscriptionProduct(
                id: "monthly",
                displayName: "Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            )

            #expect(product.monthlyEquivalent == 4.99)
        }

        @Test("Yearly product calculates monthly equivalent")
        func yearlyMonthlyEquivalent() {
            let product = SubscriptionProduct(
                id: "yearly",
                displayName: "Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )

            let expected = Decimal(29.99) / 12
            #expect(product.monthlyEquivalent == expected)
        }

        @Test("Product is Identifiable by id")
        func productIdentifiable() {
            let product = SubscriptionProduct(
                id: "unique.id",
                displayName: "Test",
                displayPrice: "$1.99",
                period: .monthly,
                priceValue: 1.99
            )

            #expect(product.id == "unique.id")
        }
    }

    // MARK: - SubscriptionError Tests

    @Suite("SubscriptionError")
    struct SubscriptionErrorTests {

        @Test("Cancellation has empty user friendly message")
        func cancellationEmptyMessage() {
            let error = SubscriptionError.purchaseCancelled
            #expect(error.userFriendlyMessage.isEmpty)
        }

        @Test("Network error has user friendly message")
        func networkErrorMessage() {
            let error = SubscriptionError.networkError
            #expect(!error.userFriendlyMessage.isEmpty)
            #expect(error.userFriendlyMessage.contains("connection"))
        }

        @Test("Error equality works correctly")
        func errorEquality() {
            #expect(SubscriptionError.productNotFound == .productNotFound)
            #expect(SubscriptionError.purchaseCancelled == .purchaseCancelled)
            #expect(SubscriptionError.purchaseFailed("test") == .purchaseFailed("test"))
            #expect(SubscriptionError.purchaseFailed("a") != .purchaseFailed("b"))
        }
    }

    // MARK: - MockSubscriptionService Tests

    @Suite("MockSubscriptionService")
    struct MockSubscriptionServiceTests {

        @Test("Fetch products returns configured products")
        func fetchProductsReturnsConfigured() async throws {
            let service = MockSubscriptionService()
            let products = MockSubscriptionService.createTestProducts()
            service.productsToReturn = products

            let result = try await service.fetchProducts()

            #expect(service.fetchProductsCalled)
            #expect(result.count == 2)
            #expect(result.contains { $0.period == .monthly })
            #expect(result.contains { $0.period == .yearly })
        }

        @Test("Fetch products throws configured error")
        func fetchProductsThrowsError() async {
            let service = MockSubscriptionService()
            service.fetchProductsError = .networkError

            do {
                _ = try await service.fetchProducts()
                Issue.record("Expected error to be thrown")
            } catch let error as SubscriptionError {
                #expect(error == .networkError)
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }

        @Test("Purchase returns configured status")
        func purchaseReturnsStatus() async throws {
            let service = MockSubscriptionService()
            let products = MockSubscriptionService.createTestProducts()
            let expectedStatus = SubscriptionStatus.premium(
                expiryDate: Date().addingTimeInterval(86400 * 30),
                productId: products[0].id
            )
            service.purchaseStatus = expectedStatus

            let result = try await service.purchase(products[0])

            #expect(service.purchaseCalled)
            #expect(service.purchasedProduct == products[0])
            #expect(result == expectedStatus)
        }

        @Test("Purchase throws cancellation error")
        func purchaseThrowsCancellation() async {
            let service = MockSubscriptionService()
            let products = MockSubscriptionService.createTestProducts()
            service.purchaseError = .purchaseCancelled

            do {
                _ = try await service.purchase(products[0])
                Issue.record("Expected error to be thrown")
            } catch let error as SubscriptionError {
                #expect(error == .purchaseCancelled)
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }

        @Test("Restore returns configured status")
        func restoreReturnsStatus() async throws {
            let service = MockSubscriptionService()
            let expectedStatus = SubscriptionStatus.premium(
                expiryDate: Date().addingTimeInterval(86400 * 30),
                productId: "restored.product"
            )
            service.restoreStatus = expectedStatus

            let result = try await service.restorePurchases()

            #expect(service.restoreCalled)
            #expect(result == expectedStatus)
        }

        @Test("Restore with no subscription returns free")
        func restoreNoSubscription() async throws {
            let service = MockSubscriptionService()
            service.restoreStatus = .free

            let result = try await service.restorePurchases()

            #expect(result == .free)
            #expect(!result.isPremium)
        }

        @Test("Current status returns configured value")
        func currentStatusReturns() async {
            let service = MockSubscriptionService()
            service.currentStatusValue = .premium(
                expiryDate: Date().addingTimeInterval(86400),
                productId: "test"
            )

            let status = await service.currentStatus()

            #expect(service.currentStatusCalled)
            #expect(status.isPremium)
        }

        @Test("Reset clears tracking state")
        func resetClearsState() async throws {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.createTestProducts()

            _ = try await service.fetchProducts()
            _ = try await service.purchase(service.productsToReturn[0])

            service.reset()

            #expect(!service.fetchProductsCalled)
            #expect(!service.purchaseCalled)
            #expect(service.purchasedProduct == nil)
        }
    }

    // MARK: - Status Transition Tests

    @Suite("Status Transitions")
    struct StatusTransitionTests {

        @Test("Free to premium transition")
        func freeToPermium() {
            let free = SubscriptionStatus.free
            let premium = SubscriptionStatus.premium(
                expiryDate: Date().addingTimeInterval(86400 * 30),
                productId: "test"
            )

            #expect(!free.isPremium)
            #expect(premium.isPremium)
        }

        @Test("Premium to expired when date passes")
        func premiumToExpired() {
            let pastDate = Date().addingTimeInterval(-86400)
            let expired = SubscriptionStatus.expired(expiryDate: pastDate, productId: "test")

            #expect(!expired.isPremium)
            #expect(expired.displayName == "Expired")
        }

        @Test("Expiry date validation")
        func expiryDateValidation() {
            let futureDate = Date().addingTimeInterval(86400 * 365)
            let premium = SubscriptionStatus.premium(expiryDate: futureDate, productId: "yearly")

            #expect(premium.isPremium)
            #expect(premium.expiryDate! > Date())
        }
    }
}
