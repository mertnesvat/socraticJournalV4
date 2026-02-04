// PaywallViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

/// Tests for PaywallViewModel
@Suite("PaywallViewModel Tests")
@MainActor
struct PaywallViewModelTests {

    // MARK: - Initial State Tests

    @Suite("Initial State")
    @MainActor
    struct InitialStateTests {

        @Test("Initial state has no products")
        func initialStateNoProducts() {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(viewModel.products.isEmpty)
        }

        @Test("Initial state is not loading")
        func initialStateNotLoading() {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(!viewModel.isLoadingProducts)
        }

        @Test("Initial state is not purchasing")
        func initialStateNotPurchasing() {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(!viewModel.isPurchasing)
        }

        @Test("Initial state has no error")
        func initialStateNoError() {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(viewModel.error == nil)
        }

        @Test("Initial state purchase not succeeded")
        func initialStatePurchaseNotSucceeded() {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(!viewModel.purchaseSucceeded)
        }

        @Test("Initial state has free status")
        func initialStateFreeStatus() {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            #expect(viewModel.currentStatus == .free)
        }
    }

    // MARK: - Load Products Tests

    @Suite("Load Products")
    @MainActor
    struct LoadProductsTests {

        @Test("Load products sets products array")
        func loadProductsSetsProducts() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.products.count == 2)
        }

        @Test("Load products sets loading state correctly")
        func loadProductsSetsLoadingState() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            // Before loading
            #expect(!viewModel.isLoadingProducts)

            await viewModel.loadProducts()

            // After loading
            #expect(!viewModel.isLoadingProducts)
        }

        @Test("Load products selects yearly by default")
        func loadProductsSelectsYearly() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.selectedProduct?.period == .yearly)
        }

        @Test("Load products handles error")
        func loadProductsHandlesError() async {
            let service = TestMockSubscriptionService()
            service.shouldFailFetch = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.error != nil)
            #expect(viewModel.products.isEmpty)
        }

        @Test("Monthly product computed property works")
        func monthlyProductComputed() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.monthlyProduct?.period == .monthly)
        }

        @Test("Yearly product computed property works")
        func yearlyProductComputed() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.yearlyProduct?.period == .yearly)
        }

        @Test("Yearly savings percentage calculated")
        func yearlySavingsCalculated() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.yearlySavingsPercentage > 0)
        }
    }

    // MARK: - Select Product Tests

    @Suite("Select Product")
    @MainActor
    struct SelectProductTests {

        @Test("Select product updates selected product")
        func selectProductUpdatesSelection() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            let monthly = viewModel.monthlyProduct!

            viewModel.selectProduct(monthly)

            #expect(viewModel.selectedProduct?.id == monthly.id)
        }

        @Test("Can change selection between products")
        func canChangeSelection() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            let monthly = viewModel.monthlyProduct!
            let yearly = viewModel.yearlyProduct!

            viewModel.selectProduct(monthly)
            #expect(viewModel.selectedProduct?.period == .monthly)

            viewModel.selectProduct(yearly)
            #expect(viewModel.selectedProduct?.period == .yearly)
        }
    }

    // MARK: - Purchase Tests

    @Suite("Purchase")
    @MainActor
    struct PurchaseTests {

        @Test("Purchase succeeds and updates state")
        func purchaseSucceeds() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            let result = await viewModel.purchase()

            #expect(result)
            #expect(viewModel.purchaseSucceeded)
            #expect(viewModel.currentStatus.isPremium)
        }

        @Test("Purchase sets purchasing state")
        func purchaseSetsPurchasingState() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            // After purchase completes
            _ = await viewModel.purchase()
            #expect(!viewModel.isPurchasing)
        }

        @Test("Purchase handles cancellation without error display")
        func purchaseHandlesCancellation() async {
            let service = TestMockSubscriptionService()
            service.shouldCancelPurchase = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            let result = await viewModel.purchase()

            #expect(!result)
            #expect(!viewModel.purchaseSucceeded)
            // Error is set but should not be displayed
            #expect(viewModel.error != nil)
            #expect(!viewModel.hasDisplayableError)
        }

        @Test("Purchase handles failure with error")
        func purchaseHandlesFailure() async {
            let service = TestMockSubscriptionService()
            service.shouldFailPurchase = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            let result = await viewModel.purchase()

            #expect(!result)
            #expect(!viewModel.purchaseSucceeded)
            #expect(viewModel.error != nil)
            #expect(viewModel.hasDisplayableError)
        }

        @Test("Purchase returns false when no product selected")
        func purchaseNoProduct() async {
            let service = TestMockSubscriptionService()
            service.mockProducts = []
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            let result = await viewModel.purchase()

            #expect(!result)
        }
    }

    // MARK: - Restore Purchases Tests

    @Suite("Restore Purchases")
    @MainActor
    struct RestorePurchasesTests {

        @Test("Restore finds subscription")
        func restoreFindsSubscription() async {
            let service = TestMockSubscriptionService()
            service.setPremium(daysUntilExpiry: 30)
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.restorePurchases()

            #expect(result)
            #expect(viewModel.purchaseSucceeded)
            #expect(viewModel.currentStatus.isPremium)
        }

        @Test("Restore handles no subscription")
        func restoreNoSubscription() async {
            let service = TestMockSubscriptionService()
            service.mockStatus = .free
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.restorePurchases()

            #expect(!result)
            #expect(!viewModel.purchaseSucceeded)
        }

        @Test("Restore handles failure")
        func restoreHandlesFailure() async {
            let service = TestMockSubscriptionService()
            service.shouldFailRestore = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            let result = await viewModel.restorePurchases()

            #expect(!result)
            #expect(viewModel.error != nil)
        }

        @Test("Restore sets restoring state")
        func restoreSetsRestoringState() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            // After restore completes
            _ = await viewModel.restorePurchases()
            #expect(!viewModel.isRestoring)
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling")
    @MainActor
    struct ErrorHandlingTests {

        @Test("Clear error removes error")
        func clearErrorRemovesError() async {
            let service = TestMockSubscriptionService()
            service.shouldFailFetch = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            #expect(viewModel.error != nil)

            viewModel.clearError()
            #expect(viewModel.error == nil)
        }

        @Test("Error message returns user friendly message")
        func errorMessageUserFriendly() async {
            let service = TestMockSubscriptionService()
            service.shouldFailFetch = true
            service.fetchError = .networkError("Test error")
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(!viewModel.errorMessage.isEmpty)
        }

        @Test("Has displayable error false for cancellation")
        func hasDisplayableErrorFalseForCancellation() async {
            let service = TestMockSubscriptionService()
            service.shouldCancelPurchase = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            _ = await viewModel.purchase()

            #expect(!viewModel.hasDisplayableError)
        }

        @Test("Has displayable error true for other errors")
        func hasDisplayableErrorTrueForOtherErrors() async {
            let service = TestMockSubscriptionService()
            service.shouldFailPurchase = true
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()
            _ = await viewModel.purchase()

            #expect(viewModel.hasDisplayableError)
        }
    }

    // MARK: - Already Subscribed Tests

    @Suite("Already Subscribed")
    @MainActor
    struct AlreadySubscribedTests {

        @Test("Is already subscribed when premium")
        func isAlreadySubscribedWhenPremium() async {
            let service = TestMockSubscriptionService()
            service.setPremium(daysUntilExpiry: 30)
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(viewModel.isAlreadySubscribed)
        }

        @Test("Is not already subscribed when free")
        func isNotAlreadySubscribedWhenFree() async {
            let service = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: service)

            await viewModel.loadProducts()

            #expect(!viewModel.isAlreadySubscribed)
        }
    }
}
#endif
