// SubscriptionIntegrationTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

#if os(iOS)
import Testing
import Foundation
@testable import SocraticJournal

/// Integration tests for the complete subscription flow
@Suite("Subscription Integration Tests")
@MainActor
struct SubscriptionIntegrationTests {

    // MARK: - Full Purchase Flow Tests

    @Suite("Full Purchase Flow")
    @MainActor
    struct FullPurchaseFlowTests {

        @Test("User starts as free")
        func userStartsAsFree() async throws {
            let subscriptionService = TestMockSubscriptionService()
            let settingsRepository = MockSettingsRepository()

            // User's initial state
            let settings = try await settingsRepository.getSettings()
            let subscriptionStatus = await subscriptionService.currentStatus()

            #expect(!settings.isPremium)
            #expect(subscriptionStatus == .free)
        }

        @Test("Products load correctly in paywall")
        func productsLoadInPaywall() async {
            let subscriptionService = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: subscriptionService)

            await viewModel.loadProducts()

            #expect(viewModel.products.count == 2)
            #expect(viewModel.monthlyProduct != nil)
            #expect(viewModel.yearlyProduct != nil)
            #expect(viewModel.selectedProduct != nil)
        }

        @Test("Purchase completes successfully")
        func purchaseCompletes() async {
            let subscriptionService = TestMockSubscriptionService()
            let viewModel = PaywallViewModel(subscriptionService: subscriptionService)

            await viewModel.loadProducts()
            let success = await viewModel.purchase()

            #expect(success)
            #expect(viewModel.purchaseSucceeded)
            #expect(viewModel.currentStatus.isPremium)
        }

        @Test("Settings shows Premium after purchase")
        func settingsShowsPremiumAfterPurchase() async throws {
            let subscriptionService = TestMockSubscriptionService()
            let settingsRepository = MockSettingsRepository()

            // Purchase subscription
            let product = subscriptionService.mockProducts[0]
            let status = try await subscriptionService.purchase(product)

            // Update settings from status
            var settings = try await settingsRepository.getSettings()
            settings.updateSubscription(from: status)
            try await settingsRepository.saveSettings(settings)

            // Verify settings updated
            let updatedSettings = try await settingsRepository.getSettings()
            #expect(updatedSettings.isPremium)
            #expect(updatedSettings.activeProductId != nil)
            #expect(updatedSettings.subscriptionExpiryDate != nil)
        }

        @Test("Premium status persists after simulated relaunch")
        func premiumStatusPersists() async throws {
            let subscriptionService = TestMockSubscriptionService()
            let settingsRepository = MockSettingsRepository()

            // Purchase and save
            let product = subscriptionService.mockProducts[0]
            let status = try await subscriptionService.purchase(product)
            var settings = try await settingsRepository.getSettings()
            settings.updateSubscription(from: status)
            try await settingsRepository.saveSettings(settings)

            // Simulate relaunch - load settings again
            let reloadedSettings = try await settingsRepository.getSettings()

            #expect(reloadedSettings.isPremium)
            #expect(reloadedSettings.subscriptionExpiryDate != nil)
        }

        @Test("Correct expiry date format displayed")
        func correctExpiryDateFormat() async throws {
            let subscriptionService = TestMockSubscriptionService()
            let settingsRepository = MockSettingsRepository()

            // Purchase monthly subscription
            let product = subscriptionService.mockProducts[0]
            let status = try await subscriptionService.purchase(product)

            var settings = try await settingsRepository.getSettings()
            settings.updateSubscription(from: status)

            // Verify formatted expiry is not nil and not empty
            #expect(settings.formattedSubscriptionExpiry != nil)
            #expect(!settings.formattedSubscriptionExpiry!.isEmpty)
        }
    }

    // MARK: - Settings Integration Tests

    @Suite("Settings Integration")
    @MainActor
    struct SettingsIntegrationTests {

        @Test("Free user sees upgrade button")
        func freeUserSeesUpgrade() async {
            let subscriptionService = TestMockSubscriptionService()
            subscriptionService.mockStatus = .free

            let status = await subscriptionService.currentStatus()

            #expect(!status.isPremium)
            // In UI, this would show "Upgrade to Premium" button
        }

        @Test("Premium user sees manage subscription")
        func premiumUserSeesManage() async {
            let subscriptionService = TestMockSubscriptionService()
            subscriptionService.setPremium(daysUntilExpiry: 30)

            let status = await subscriptionService.currentStatus()

            #expect(status.isPremium)
            // In UI, this would show "Manage Subscription" button
        }

        @Test("Restore purchases updates settings")
        func restoreUpdatesSettings() async throws {
            let subscriptionService = TestMockSubscriptionService()
            subscriptionService.setPremium(daysUntilExpiry: 30)
            let settingsRepository = MockSettingsRepository()

            // Restore purchases
            let status = try await subscriptionService.restorePurchases()

            // Update settings
            var settings = try await settingsRepository.getSettings()
            settings.updateSubscription(from: status)
            try await settingsRepository.saveSettings(settings)

            let updatedSettings = try await settingsRepository.getSettings()
            #expect(updatedSettings.isPremium)
        }
    }

    // MARK: - State Transition Tests

    @Suite("State Transitions")
    @MainActor
    struct StateTransitionTests {

        @Test("Free to Premium transition")
        func freeToPremiumTransition() async throws {
            let subscriptionService = TestMockSubscriptionService()

            // Start free
            let initialStatus = await subscriptionService.currentStatus()
            #expect(initialStatus == .free)

            // Purchase
            let product = subscriptionService.mockProducts[0]
            let newStatus = try await subscriptionService.purchase(product)

            #expect(newStatus.isPremium)
        }

        @Test("Premium to Expired transition")
        func premiumToExpiredTransition() {
            let subscriptionService = TestMockSubscriptionService()

            // Set premium
            subscriptionService.setPremium(daysUntilExpiry: 30)
            #expect(subscriptionService.mockStatus.isPremium)

            // Simulate expiration
            subscriptionService.setExpired(daysAgo: 1)
            #expect(!subscriptionService.mockStatus.isPremium)
            if case .expired = subscriptionService.mockStatus {
                // Expected
            } else {
                Issue.record("Expected expired status")
            }
        }

        @Test("Expired to Premium transition via renewal")
        func expiredToPremiumRenewal() async throws {
            let subscriptionService = TestMockSubscriptionService()

            // Start expired
            subscriptionService.setExpired(daysAgo: 1)
            #expect(!subscriptionService.mockStatus.isPremium)

            // Renew
            let product = subscriptionService.mockProducts[0]
            let newStatus = try await subscriptionService.purchase(product)

            #expect(newStatus.isPremium)
        }
    }

    // MARK: - Error Handling Integration Tests

    @Suite("Error Handling Integration")
    @MainActor
    struct ErrorHandlingIntegrationTests {

        @Test("Network error during purchase shows friendly message")
        func networkErrorShowsFriendlyMessage() async {
            let subscriptionService = TestMockSubscriptionService()
            subscriptionService.shouldFailPurchase = true
            subscriptionService.purchaseError = .networkError("Connection failed")
            let viewModel = PaywallViewModel(subscriptionService: subscriptionService)

            await viewModel.loadProducts()
            _ = await viewModel.purchase()

            #expect(viewModel.hasDisplayableError)
            #expect(!viewModel.errorMessage.isEmpty)
        }

        @Test("Purchase cancellation does not show error")
        func cancellationNoError() async {
            let subscriptionService = TestMockSubscriptionService()
            subscriptionService.shouldCancelPurchase = true
            let viewModel = PaywallViewModel(subscriptionService: subscriptionService)

            await viewModel.loadProducts()
            _ = await viewModel.purchase()

            // Error is set but not displayable
            #expect(!viewModel.hasDisplayableError)
        }

        @Test("Restore with no subscription handled gracefully")
        func restoreNoSubscriptionGraceful() async {
            let subscriptionService = TestMockSubscriptionService()
            subscriptionService.mockStatus = .free
            let viewModel = PaywallViewModel(subscriptionService: subscriptionService)

            let restored = await viewModel.restorePurchases()

            #expect(!restored)
            #expect(!viewModel.purchaseSucceeded)
            #expect(viewModel.error == nil)
        }
    }

    // MARK: - UserSettings Update Tests

    @Suite("UserSettings Updates")
    @MainActor
    struct UserSettingsUpdateTests {

        @Test("updateSubscription correctly sets premium state")
        func updateSubscriptionSetsPremium() {
            var settings = UserSettings.default
            let expiryDate = Date().addingTimeInterval(86400 * 30)
            let status = SubscriptionStatus.premium(expiryDate: expiryDate, productId: "test.monthly")

            settings.updateSubscription(from: status)

            #expect(settings.isPremium)
            #expect(settings.subscriptionExpiryDate == expiryDate)
            #expect(settings.activeProductId == "test.monthly")
            #expect(settings.lastSubscriptionCheck != nil)
        }

        @Test("updateSubscription correctly handles free state")
        func updateSubscriptionHandlesFree() {
            var settings = UserSettings.default
            // First set premium
            let expiryDate = Date().addingTimeInterval(86400 * 30)
            settings.updateSubscription(from: .premium(expiryDate: expiryDate, productId: "test"))

            // Then update to free
            settings.updateSubscription(from: .free)

            #expect(!settings.isPremium)
            #expect(settings.subscriptionExpiryDate == nil)
            #expect(settings.activeProductId == nil)
        }

        @Test("subscriptionPeriod computed correctly")
        func subscriptionPeriodComputed() {
            var settings = UserSettings.default

            settings.activeProductId = "com.StudioNext.socraticJournal.monthly"
            #expect(settings.subscriptionPeriod == .monthly)

            settings.activeProductId = "com.StudioNext.socraticJournal.yearly"
            #expect(settings.subscriptionPeriod == .yearly)

            settings.activeProductId = nil
            #expect(settings.subscriptionPeriod == nil)
        }
    }

    // MARK: - End-to-End Journey Documentation

    @Suite("End-to-End User Journey")
    @MainActor
    struct EndToEndJourneyTests {

        /// Documents the complete subscription purchase journey
        @Test("Complete subscription journey")
        func completeSubscriptionJourney() async throws {
            // STEP 1: User opens app as free user
            let subscriptionService = TestMockSubscriptionService()
            let settingsRepository = MockSettingsRepository()

            var settings = try await settingsRepository.getSettings()
            let initialStatus = await subscriptionService.currentStatus()

            #expect(!settings.isPremium)
            #expect(initialStatus == .free)

            // STEP 2: User navigates to Settings and sees "Free" status
            // (Verified by initialStatus == .free)

            // STEP 3: User taps "Upgrade to Premium" which opens PaywallView
            let viewModel = PaywallViewModel(subscriptionService: subscriptionService)
            await viewModel.loadProducts()

            #expect(viewModel.products.count == 2)

            // STEP 4: User sees products, yearly is pre-selected
            #expect(viewModel.selectedProduct?.period == .yearly)
            #expect(viewModel.yearlySavingsPercentage > 0)

            // STEP 5: User taps "Subscribe Now"
            let purchaseSuccess = await viewModel.purchase()

            #expect(purchaseSuccess)
            #expect(viewModel.purchaseSucceeded)

            // STEP 6: Paywall shows success state and dismisses
            #expect(viewModel.currentStatus.isPremium)

            // STEP 7: Settings now shows "Premium" with expiry date
            settings.updateSubscription(from: viewModel.currentStatus)
            try await settingsRepository.saveSettings(settings)

            let finalSettings = try await settingsRepository.getSettings()
            #expect(finalSettings.isPremium)
            #expect(finalSettings.formattedSubscriptionExpiry != nil)

            // STEP 8: User relaunches app - premium status preserved
            let relaunchSettings = try await settingsRepository.getSettings()
            #expect(relaunchSettings.isPremium)

            // Journey complete!
        }
    }
}
#endif
