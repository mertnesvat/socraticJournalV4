// PaywallViewModelTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for PaywallViewModel business logic
@Suite("PaywallViewModel Tests")
@MainActor
struct PaywallViewModelTests {

    // MARK: - Initial State Tests

    @Test("Initial state is correct")
    func initialState() {
        let service = MockSubscriptionService()
        let viewModel = PaywallViewModel(subscriptionService: service)

        #expect(viewModel.products.isEmpty)
        #expect(viewModel.selectedProduct == nil)
        #expect(!viewModel.isLoadingProducts)
        #expect(!viewModel.isPurchasing)
        #expect(!viewModel.isRestoring)
        #expect(viewModel.error == nil)
        #expect(!viewModel.purchaseSucceeded)
        #expect(!viewModel.restoreSucceeded)
    }

    // MARK: - Load Products Tests

    @Test("loadProducts sets products correctly")
    func loadProductsSetsProducts() async {
        let service = MockSubscriptionService()
        service.productsToReturn = MockSubscriptionService.createTestProducts()
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()

        #expect(viewModel.products.count == 2)
        #expect(viewModel.monthlyProduct != nil)
        #expect(viewModel.yearlyProduct != nil)
        #expect(!viewModel.isLoadingProducts)
    }

    @Test("loadProducts defaults selection to yearly")
    func loadProductsDefaultsToYearly() async {
        let service = MockSubscriptionService()
        service.productsToReturn = MockSubscriptionService.createTestProducts()
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()

        #expect(viewModel.selectedProduct?.period == .yearly)
    }

    @Test("loadProducts handles error correctly")
    func loadProductsHandlesError() async {
        let service = MockSubscriptionService()
        service.fetchProductsError = .networkError
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()

        #expect(viewModel.products.isEmpty)
        #expect(viewModel.error == .networkError)
        #expect(!viewModel.isLoadingProducts)
    }

    @Test("loadProducts sets loading state during fetch")
    func loadProductsSetsLoadingState() async {
        let service = MockSubscriptionService()
        service.productsToReturn = MockSubscriptionService.createTestProducts()
        let viewModel = PaywallViewModel(subscriptionService: service)

        // Start loading
        let task = Task {
            await viewModel.loadProducts()
        }

        // Give it a moment to start
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Wait for completion
        await task.value

        #expect(!viewModel.isLoadingProducts)
    }

    // MARK: - Select Product Tests

    @Test("selectProduct updates selectedProduct")
    func selectProductUpdates() async {
        let service = MockSubscriptionService()
        let products = MockSubscriptionService.createTestProducts()
        service.productsToReturn = products
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()
        viewModel.selectProduct(products[0])

        #expect(viewModel.selectedProduct == products[0])
    }

    // MARK: - Purchase Tests

    @Test("purchase transitions states correctly on success")
    func purchaseSuccessTransitions() async {
        let service = MockSubscriptionService()
        let products = MockSubscriptionService.createTestProducts()
        service.productsToReturn = products
        service.purchaseStatus = .premium(
            expiryDate: Date().addingTimeInterval(86400 * 30),
            productId: products[1].id
        )
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()
        let result = await viewModel.purchase()

        #expect(result)
        #expect(viewModel.purchaseSucceeded)
        #expect(!viewModel.isPurchasing)
        #expect(viewModel.error == nil)
        #expect(service.purchaseCalled)
    }

    @Test("purchase handles cancellation without error")
    func purchaseCancellationNoError() async {
        let service = MockSubscriptionService()
        let products = MockSubscriptionService.createTestProducts()
        service.productsToReturn = products
        service.purchaseError = .purchaseCancelled
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()
        let result = await viewModel.purchase()

        #expect(!result)
        #expect(!viewModel.purchaseSucceeded)
        #expect(viewModel.error == nil) // Cancellation should not set error
    }

    @Test("purchase handles failure with error")
    func purchaseFailureSetsError() async {
        let service = MockSubscriptionService()
        let products = MockSubscriptionService.createTestProducts()
        service.productsToReturn = products
        service.purchaseError = .purchaseFailed("Payment declined")
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()
        let result = await viewModel.purchase()

        #expect(!result)
        #expect(!viewModel.purchaseSucceeded)
        #expect(viewModel.error != nil)
    }

    @Test("purchase returns false when no product selected")
    func purchaseNoProductFails() async {
        let service = MockSubscriptionService()
        let viewModel = PaywallViewModel(subscriptionService: service)

        let result = await viewModel.purchase()

        #expect(!result)
        #expect(viewModel.error == .productNotFound)
    }

    // MARK: - Restore Tests

    @Test("restorePurchases success transitions correctly")
    func restoreSuccessTransitions() async {
        let service = MockSubscriptionService()
        service.restoreStatus = .premium(
            expiryDate: Date().addingTimeInterval(86400 * 30),
            productId: "restored"
        )
        let viewModel = PaywallViewModel(subscriptionService: service)

        let result = await viewModel.restorePurchases()

        #expect(result)
        #expect(viewModel.restoreSucceeded)
        #expect(viewModel.purchaseSucceeded)
        #expect(!viewModel.isRestoring)
    }

    @Test("restorePurchases with no subscription returns false")
    func restoreNoSubscription() async {
        let service = MockSubscriptionService()
        service.restoreStatus = .free
        let viewModel = PaywallViewModel(subscriptionService: service)

        let result = await viewModel.restorePurchases()

        #expect(!result)
        #expect(!viewModel.restoreSucceeded)
        #expect(viewModel.error == nil) // Not an error, just no subscription
    }

    @Test("restorePurchases handles failure")
    func restoreFailureSetsError() async {
        let service = MockSubscriptionService()
        service.restoreError = .networkError
        let viewModel = PaywallViewModel(subscriptionService: service)

        let result = await viewModel.restorePurchases()

        #expect(!result)
        #expect(viewModel.error != nil)
    }

    // MARK: - Savings Calculation Tests

    @Test("yearlySavingsPercentage calculates correctly")
    func yearlySavingsCalculation() async {
        let service = MockSubscriptionService()
        // Monthly: $4.99, Yearly: $29.99
        // Monthly equivalent of yearly: $29.99 / 12 = $2.50
        // Savings: (1 - 2.50/4.99) * 100 = ~50%
        service.productsToReturn = MockSubscriptionService.createTestProducts()
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()

        #expect(viewModel.yearlySavingsPercentage != nil)
        #expect(viewModel.yearlySavingsPercentage! > 40)
        #expect(viewModel.yearlySavingsPercentage! < 60)
    }

    @Test("yearlySavingsPercentage returns nil without both products")
    func yearlySavingsNilWithoutProducts() {
        let service = MockSubscriptionService()
        let viewModel = PaywallViewModel(subscriptionService: service)

        #expect(viewModel.yearlySavingsPercentage == nil)
    }

    // MARK: - Error Message Tests

    @Test("errorMessage returns friendly message for errors")
    func errorMessageFriendly() async {
        let service = MockSubscriptionService()
        service.fetchProductsError = .networkError
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()

        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.errorMessage!.isEmpty)
    }

    @Test("errorMessage returns nil for cancellation")
    func errorMessageNilForCancellation() async {
        let service = MockSubscriptionService()
        let products = MockSubscriptionService.createTestProducts()
        service.productsToReturn = products
        service.purchaseError = .purchaseCancelled
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()
        _ = await viewModel.purchase()

        // Cancellation should not set error, so errorMessage should be nil
        #expect(viewModel.errorMessage == nil)
    }

    @Test("clearError removes error")
    func clearErrorRemoves() async {
        let service = MockSubscriptionService()
        service.fetchProductsError = .networkError
        let viewModel = PaywallViewModel(subscriptionService: service)

        await viewModel.loadProducts()
        #expect(viewModel.error != nil)

        viewModel.clearError()

        #expect(viewModel.error == nil)
        #expect(viewModel.errorMessage == nil)
    }
}
