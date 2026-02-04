// PurchaseFlowIntegrationTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Integration tests for the complete subscription purchase flow
/// Tests the journey from free user through paywall to premium status
@Suite("Purchase Flow Integration Tests")
@MainActor
struct PurchaseFlowIntegrationTests {

    // MARK: - Full Purchase Flow

    @Suite("Complete Purchase Journey")
    @MainActor
    struct CompletePurchaseJourneyTests {

        @Test("User starts as free, purchases, becomes premium")
        func completePurchaseFlow() async throws {
            // 1. Setup - User starts as free
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.productsToReturn = MockSubscriptionService.testProducts
            subscriptionService.purchaseStatus = MockSubscriptionService.testPremiumStatus()

            // Verify initial state
            let initialSettings = try await settingsRepository.getSettings()
            #expect(!initialSettings.isPremium)
            #expect(initialSettings.subscriptionExpiryDate == nil)

            // 2. User views paywall and loads products
            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            await paywallViewModel.loadProducts()

            #expect(paywallViewModel.hasProducts)
            #expect(paywallViewModel.selectedProduct != nil)

            // 3. User completes purchase
            let purchaseResult = await paywallViewModel.purchase()

            #expect(purchaseResult)
            #expect(paywallViewModel.purchaseSucceeded)
            #expect(subscriptionService.purchaseCallCount == 1)

            // 4. Settings are updated with premium status
            let newStatus = await subscriptionService.currentStatus()
            var updatedSettings = try await settingsRepository.getSettings()
            updatedSettings.updateSubscriptionState(from: newStatus)
            try await settingsRepository.saveSettings(updatedSettings)

            // 5. Verify premium state persisted
            let finalSettings = try await settingsRepository.getSettings()
            #expect(finalSettings.isPremium)
            #expect(finalSettings.subscriptionExpiryDate != nil)
            #expect(finalSettings.activeProductId != nil)
        }

        @Test("Settings show correct status after purchase")
        func settingsShowCorrectStatus() async throws {
            // Setup
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.productsToReturn = MockSubscriptionService.testProducts
            let premiumStatus = MockSubscriptionService.testPremiumStatus(
                productId: SubscriptionProductID.yearly
            )
            subscriptionService.purchaseStatus = premiumStatus

            // Purchase
            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            await paywallViewModel.loadProducts()
            await paywallViewModel.purchase()

            // Update settings
            var settings = try await settingsRepository.getSettings()
            settings.updateSubscriptionState(from: premiumStatus)
            try await settingsRepository.saveSettings(settings)

            // Verify settings display
            let finalSettings = try await settingsRepository.getSettings()
            #expect(finalSettings.isPremium)
            #expect(finalSettings.formattedSubscriptionExpiry != nil)
            #expect(finalSettings.subscriptionPeriod == .yearly)
        }

        @Test("Premium status persists after simulated app restart")
        func premiumStatusPersists() async throws {
            // Setup - simulate saved premium state
            let settingsRepository = MockSettingsRepository()
            var settings = UserSettings.default
            settings.updateSubscriptionState(from: .premium(
                expiryDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
                productId: SubscriptionProductID.yearly
            ))
            try await settingsRepository.saveSettings(settings)

            // Simulate "app restart" - create new service instances
            let subscriptionService = MockSubscriptionService()
            subscriptionService.currentStatusValue = .premium(
                expiryDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
                productId: SubscriptionProductID.yearly
            )

            // Create SettingsViewModel as if app just launched
            let viewModel = SettingsViewModel(
                settingsRepository: settingsRepository,
                journalRepository: InMemoryJournalRepository(),
                subscriptionService: subscriptionService
            )
            await viewModel.loadSettings()

            // Verify status is still premium
            #expect(viewModel.subscriptionStatus.isPremium)
            #expect(viewModel.subscriptionExpiryDisplay != nil)
        }
    }

    // MARK: - Restore Flow

    @Suite("Restore Purchase Journey")
    @MainActor
    struct RestorePurchaseJourneyTests {

        @Test("Restore finds existing subscription")
        func restoreFindsSubscription() async throws {
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.restoreStatus = MockSubscriptionService.testPremiumStatus()

            // User attempts restore
            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            let result = await paywallViewModel.restorePurchases()

            #expect(result)
            #expect(paywallViewModel.restoreSucceeded)
            #expect(paywallViewModel.purchaseSucceeded) // Triggers dismissal

            // Update settings
            var settings = try await settingsRepository.getSettings()
            settings.updateSubscriptionState(from: subscriptionService.restoreStatus)
            try await settingsRepository.saveSettings(settings)

            // Verify premium
            let finalSettings = try await settingsRepository.getSettings()
            #expect(finalSettings.isPremium)
        }

        @Test("Restore handles no subscription gracefully")
        func restoreNoSubscription() async {
            let subscriptionService = MockSubscriptionService()
            subscriptionService.restoreStatus = .free

            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            let result = await paywallViewModel.restorePurchases()

            #expect(!result)
            #expect(!paywallViewModel.restoreSucceeded)
            #expect(paywallViewModel.error == nil) // No error, just no subscription
        }
    }

    // MARK: - Error Scenarios

    @Suite("Error Scenarios")
    @MainActor
    struct ErrorScenariosTests {

        @Test("Purchase failure does not grant premium")
        func purchaseFailureNoPremium() async throws {
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.productsToReturn = MockSubscriptionService.testProducts
            subscriptionService.purchaseError = .purchaseFailed("Card declined")

            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            await paywallViewModel.loadProducts()
            let result = await paywallViewModel.purchase()

            #expect(!result)
            #expect(!paywallViewModel.purchaseSucceeded)
            #expect(paywallViewModel.error != nil)

            // Settings should remain free
            let settings = try await settingsRepository.getSettings()
            #expect(!settings.isPremium)
        }

        @Test("Network error during product fetch shows error")
        func networkErrorProductFetch() async {
            let subscriptionService = MockSubscriptionService()
            subscriptionService.fetchProductsError = .networkError

            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            await paywallViewModel.loadProducts()

            #expect(!paywallViewModel.hasProducts)
            #expect(paywallViewModel.error == .networkError)
            #expect(paywallViewModel.errorMessage != nil)
        }

        @Test("Purchase cancellation does not show error")
        func purchaseCancellationNoError() async {
            let subscriptionService = MockSubscriptionService()
            subscriptionService.productsToReturn = MockSubscriptionService.testProducts
            subscriptionService.purchaseError = .purchaseCancelled

            let paywallViewModel = PaywallViewModel(subscriptionService: subscriptionService)
            await paywallViewModel.loadProducts()
            await paywallViewModel.purchase()

            // No error shown for user-initiated cancellation
            #expect(paywallViewModel.error == nil)
            #expect(!paywallViewModel.purchaseSucceeded)
        }
    }

    // MARK: - State Transitions

    @Suite("State Transitions")
    @MainActor
    struct StateTransitionTests {

        @Test("Free to premium transition updates all properties")
        func freeToPremuimTransition() {
            var settings = UserSettings.default

            // Initial state
            #expect(!settings.isPremium)
            #expect(settings.subscriptionExpiryDate == nil)
            #expect(settings.activeProductId == nil)
            #expect(settings.lastSubscriptionCheck == nil)

            // Transition to premium
            let expiryDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
            settings.updateSubscriptionState(from: .premium(
                expiryDate: expiryDate,
                productId: SubscriptionProductID.yearly
            ))

            // All properties updated
            #expect(settings.isPremium)
            #expect(settings.subscriptionExpiryDate == expiryDate)
            #expect(settings.activeProductId == SubscriptionProductID.yearly)
            #expect(settings.lastSubscriptionCheck != nil)
        }

        @Test("Premium to expired transition")
        func premiumToExpiredTransition() {
            var settings = UserSettings.default

            // Start with premium
            let pastDate = Date().addingTimeInterval(-24 * 60 * 60) // Yesterday
            settings.subscriptionExpiryDate = pastDate
            settings.activeProductId = SubscriptionProductID.monthly

            // Check isPremium returns false for expired
            #expect(!settings.isPremium) // Date is in the past
        }

        @Test("Premium to free transition clears subscription data")
        func premiumToFreeTransition() {
            var settings = UserSettings.default

            // Start with premium
            settings.updateSubscriptionState(from: .premium(
                expiryDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
                productId: SubscriptionProductID.monthly
            ))
            #expect(settings.isPremium)

            // Transition to free
            settings.updateSubscriptionState(from: .free)

            #expect(!settings.isPremium)
            #expect(settings.subscriptionExpiryDate == nil)
            #expect(settings.activeProductId == nil)
        }
    }

    // MARK: - SettingsViewModel Integration

    @Suite("SettingsViewModel Subscription Integration")
    @MainActor
    struct SettingsViewModelIntegrationTests {

        @Test("SettingsViewModel loads subscription status on init")
        func loadsSubscriptionStatus() async {
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.currentStatusValue = MockSubscriptionService.testPremiumStatus()

            let viewModel = SettingsViewModel(
                settingsRepository: settingsRepository,
                journalRepository: InMemoryJournalRepository(),
                subscriptionService: subscriptionService
            )

            await viewModel.loadSettings()

            #expect(viewModel.subscriptionStatus.isPremium)
            #expect(subscriptionService.currentStatusCallCount == 1)
        }

        @Test("SettingsViewModel restore updates status")
        func restoreUpdatesStatus() async {
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.restoreStatus = MockSubscriptionService.testPremiumStatus()

            let viewModel = SettingsViewModel(
                settingsRepository: settingsRepository,
                journalRepository: InMemoryJournalRepository(),
                subscriptionService: subscriptionService
            )

            await viewModel.restorePurchases()

            #expect(viewModel.subscriptionStatus.isPremium)
            #expect(settingsRepository.saveSettingsCallCount >= 1)
        }

        @Test("SettingsViewModel refreshes status after paywall")
        func refreshesAfterPaywall() async {
            let settingsRepository = MockSettingsRepository()
            let subscriptionService = MockSubscriptionService()
            subscriptionService.currentStatusValue = .free

            let viewModel = SettingsViewModel(
                settingsRepository: settingsRepository,
                journalRepository: InMemoryJournalRepository(),
                subscriptionService: subscriptionService
            )
            await viewModel.loadSettings()

            #expect(!viewModel.subscriptionStatus.isPremium)

            // Simulate purchase happened in paywall
            subscriptionService.currentStatusValue = MockSubscriptionService.testPremiumStatus()

            // Refresh after paywall dismissed
            await viewModel.refreshSubscriptionStatus()

            #expect(viewModel.subscriptionStatus.isPremium)
        }
    }
}

// MARK: - Test Checklist Documentation

/*
 After implementation, verify manually:

 - [ ] Products load from StoreKit configuration in simulator
 - [ ] Monthly subscription purchase flow completes
 - [ ] Yearly subscription purchase flow completes
 - [ ] Purchase cancellation handled (no error shown to user)
 - [ ] Purchase failure shows appropriate error
 - [ ] Restore purchases finds existing subscription
 - [ ] Restore purchases handles "no subscription" case
 - [ ] Subscription status persists after app restart
 - [ ] Settings shows correct status (Free/Premium)
 - [ ] Settings shows correct expiry date format
 - [ ] Paywall design matches app aesthetic
 - [ ] Paywall works in dark mode
 - [ ] Paywall is NOT shown during onboarding
 - [ ] Paywall is NOT auto-shown after purchase
 - [ ] "Manage Subscription" opens App Store
 - [ ] All unit tests pass
 - [ ] VoiceOver works on paywall
 */
