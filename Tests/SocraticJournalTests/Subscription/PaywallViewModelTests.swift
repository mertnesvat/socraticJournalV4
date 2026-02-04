// PaywallViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for PaywallViewModel business logic
@Suite("PaywallViewModel Tests")
@MainActor
struct PaywallViewModelTests {

    // MARK: - Initial State Tests

    @Suite("Initial State")
    @MainActor
    struct InitialStateTests {

        @Test("Initial state has no products")
        func noProducts() {
            let service = MockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(viewModel.products.isEmpty)
            #expect(viewModel.selectedProduct == nil)
            #expect(!viewModel.hasProducts)
        }

        @Test("Initial state is not loading")
        func notLoading() {
            let service = MockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(!viewModel.isLoadingProducts)
            #expect(!viewModel.isPurchasing)
            #expect(!viewModel.isRestoring)
        }

        @Test("Initial state has no error")
        func noError() {
            let service = MockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(viewModel.error == nil)
            #expect(viewModel.errorMessage == nil)
        }

        @Test("Initial state has not succeeded")
        func notSucceeded() {
            let service = MockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(!viewModel.purchaseSucceeded)
            #expect(!viewModel.restoreSucceeded)
        }
    }

    // MARK: - Load Products Tests

    @Suite("Load Products")
    @MainActor
    struct LoadProductsTests {

        @Test("Load products sets products and selects yearly by default")
        func loadProductsSuccess() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.products.count == 2)
            #expect(viewModel.hasProducts)
            #expect(viewModel.selectedProduct?.period == .yearly)
            #expect(!viewModel.isLoadingProducts)
            #expect(viewModel.error == nil)
        }

        @Test("Load products handles empty result")
        func loadProductsEmpty() async {
            let service = MockSubscriptionService()
            service.productsToReturn = []
            service.fetchProductsError = .productNotFound
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.products.isEmpty)
            #expect(!viewModel.hasProducts)
            #expect(viewModel.error == .productNotFound)
        }

        @Test("Load products handles network error")
        func loadProductsNetworkError() async {
            let service = MockSubscriptionService()
            service.fetchProductsError = .networkError
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.products.isEmpty)
            #expect(viewModel.error == .networkError)
        }

        @Test("Load products sets loading state correctly")
        func loadProductsLoadingState() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            let viewModel = PaywallViewModel(subscriptionService: service)

            // Before loading
            #expect(!viewModel.isLoadingProducts)

            // Start loading
            let task = Task {
                await viewModel.loadProducts()
            }

            await task.value

            // After loading
            #expect(!viewModel.isLoadingProducts)
        }

        @Test("Monthly and yearly computed properties work")
        func computedProperties() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.monthlyProduct != nil)
            #expect(viewModel.monthlyProduct?.period == .monthly)
            #expect(viewModel.yearlyProduct != nil)
            #expect(viewModel.yearlyProduct?.period == .yearly)
        }

        @Test("Yearly savings percentage is calculated")
        func yearlySavings() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            // $4.99/month * 12 = $59.88/year, $29.99/year = 50% savings
            let savings = viewModel.yearlySavingsPercent
            #expect(savings != nil)
            #expect(savings! > 0)
        }
    }

    // MARK: - Select Product Tests

    @Suite("Select Product")
    @MainActor
    struct SelectProductTests {

        @Test("Select product updates selectedProduct")
        func selectProduct() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            let viewModel = PaywallViewModel(subscriptionService: service)
            await viewModel.loadProducts()

            let monthly = viewModel.monthlyProduct!
            viewModel.selectProduct(monthly)

            #expect(viewModel.selectedProduct?.id == monthly.id)
            #expect(viewModel.selectedProduct?.period == .monthly)
        }
    }

    // MARK: - Purchase Tests

    @Suite("Purchase")
    @MainActor
    struct PurchaseTests {

        @Test("Purchase succeeds and sets purchaseSucceeded")
        func purchaseSuccess() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            service.purchaseStatus = MockSubscriptionService.testPremiumStatus()
            let viewModel = PaywallViewModel(subscriptionService: service)
            await viewModel.loadProducts()

            let result = await viewModel.purchase()

            #expect(result)
            #expect(viewModel.purchaseSucceeded)
            #expect(!viewModel.isPurchasing)
            #expect(viewModel.error == nil)
            #expect(service.purchaseCallCount == 1)
        }

        @Test("Purchase with no selected product returns false")
        func purchaseNoProduct() async {
            let service = MockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.purchase()

            #expect(!result)
            #expect(!viewModel.purchaseSucceeded)
            #expect(service.purchaseCallCount == 0)
        }

        @Test("Purchase cancellation does not show error")
        func purchaseCancelled() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            service.purchaseError = .purchaseCancelled
            let viewModel = PaywallViewModel(subscriptionService: service)
            await viewModel.loadProducts()

            let result = await viewModel.purchase()

            #expect(!result)
            #expect(!viewModel.purchaseSucceeded)
            #expect(viewModel.error == nil) // No error shown for cancellation
        }

        @Test("Purchase failure shows error")
        func purchaseFailure() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            service.purchaseError = .purchaseFailed("Test error")
            let viewModel = PaywallViewModel(subscriptionService: service)
            await viewModel.loadProducts()

            let result = await viewModel.purchase()

            #expect(!result)
            #expect(!viewModel.purchaseSucceeded)
            #expect(viewModel.error != nil)
        }

        @Test("Purchase sets isPurchasing state correctly")
        func purchaseLoadingState() async {
            let service = MockSubscriptionService()
            service.productsToReturn = MockSubscriptionService.testProducts
            service.purchaseStatus = MockSubscriptionService.testPremiumStatus()
            let viewModel = PaywallViewModel(subscriptionService: service)
            await viewModel.loadProducts()

            // Before purchase
            #expect(!viewModel.isPurchasing)

            // During/after purchase
            await viewModel.purchase()

            // After purchase
            #expect(!viewModel.isPurchasing)
        }
    }

    // MARK: - Restore Purchases Tests

    @Suite("Restore Purchases")
    @MainActor
    struct RestorePurchasesTests {

        @Test("Restore with subscription sets success")
        func restoreWithSubscription() async {
            let service = MockSubscriptionService()
            service.restoreStatus = MockSubscriptionService.testPremiumStatus()
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.restorePurchases()

            #expect(result)
            #expect(viewModel.restoreSucceeded)
            #expect(viewModel.purchaseSucceeded) // Also triggers dismissal
            #expect(!viewModel.isRestoring)
            #expect(service.restoreCallCount == 1)
        }

        @Test("Restore without subscription does not set success")
        func restoreWithoutSubscription() async {
            let service = MockSubscriptionService()
            service.restoreStatus = .free
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.restorePurchases()

            #expect(!result)
            #expect(!viewModel.restoreSucceeded)
            #expect(viewModel.error == nil)
        }

        @Test("Restore failure shows error")
        func restoreFailure() async {
            let service = MockSubscriptionService()
            service.restoreError = .networkError
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.restorePurchases()

            #expect(!result)
            #expect(!viewModel.restoreSucceeded)
            #expect(viewModel.error == .networkError)
        }

        @Test("Restore sets isRestoring state correctly")
        func restoreLoadingState() async {
            let service = MockSubscriptionService()
            service.restoreStatus = .free
            let viewModel = PaywallViewModel(subscriptionService: service)

            // Before restore
            #expect(!viewModel.isRestoring)

            // During/after restore
            await viewModel.restorePurchases()

            // After restore
            #expect(!viewModel.isRestoring)
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling")
    @MainActor
    struct ErrorHandlingTests {

        @Test("Clear error removes error")
        func clearError() async {
            let service = MockSubscriptionService()
            service.fetchProductsError = .networkError
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            #expect(viewModel.error != nil)

            viewModel.clearError()
            #expect(viewModel.error == nil)
            #expect(viewModel.errorMessage == nil)
        }

        @Test("Error message is user friendly")
        func errorMessageUserFriendly() async {
            let service = MockSubscriptionService()
            service.fetchProductsError = .networkError
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.errorMessage != nil)
            #expect(!viewModel.errorMessage!.isEmpty)
        }
    }
}
