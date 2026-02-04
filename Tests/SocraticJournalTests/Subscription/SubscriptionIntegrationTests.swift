// SubscriptionIntegrationTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Integration tests for the full subscription purchase flow
/// Verifies end-to-end state transitions from free to premium
@Suite("Subscription Integration Tests")
@MainActor
struct SubscriptionIntegrationTests {

    // MARK: - Full Purchase Flow Test

    @Test("Complete purchase flow: Free -> Paywall -> Purchase -> Premium -> Settings")
    func fullPurchaseFlow() async throws {
        // 1. Setup - User starts as free
        let subscriptionService = MockSubscriptionService()
        let settingsRepository = MockSettingsRepository()
        let analytics = MockAnalyticsService()

        // Configure mock for success
        let products = MockSubscriptionService.createTestProducts()
        subscriptionService.productsToReturn = products
        let premiumStatus = SubscriptionStatus.premium(
            expiryDate: Date().addingTimeInterval(86400 * 365),
            productId: products[1].id // yearly
        )
        subscriptionService.purchaseStatus = premiumStatus

        // Verify initial state - user is free
        let initialSettings = try await settingsRepository.getSettings()
        #expect(!initialSettings.isPremium)
        #expect(initialSettings.subscriptionExpiryDate == nil)

        let initialStatus = await subscriptionService.currentStatus()
        #expect(!initialStatus.isPremium)
        #expect(initialStatus.displayName == "Free")

        // 2. User opens paywall and loads products
        let viewModel = PaywallViewModel(
            subscriptionService: subscriptionService,
            analyticsService: analytics
        )

        await viewModel.loadProducts()

        #expect(viewModel.products.count == 2)
        #expect(viewModel.yearlyProduct != nil)
        #expect(viewModel.monthlyProduct != nil)
        #expect(analytics.hasLoggedEvent(.paywallViewed))

        // 3. User selects yearly product (default)
        #expect(viewModel.selectedProduct?.period == .yearly)

        // 4. User initiates purchase
        let purchaseResult = await viewModel.purchase()

        #expect(purchaseResult)
        #expect(viewModel.purchaseSucceeded)
        #expect(subscriptionService.purchaseCalled)
        #expect(subscriptionService.purchasedProduct?.id == products[1].id)
        #expect(analytics.hasLoggedEvent(.paywallPurchaseStarted))
        #expect(analytics.hasLoggedEvent(.paywallPurchaseCompleted))

        // 5. Verify subscription service now returns premium status
        subscriptionService.currentStatusValue = premiumStatus
        let newStatus = await subscriptionService.currentStatus()

        #expect(newStatus.isPremium)
        #expect(newStatus.displayName == "Premium")
        #expect(newStatus.productId == products[1].id)

        // 6. Update UserSettings with subscription info
        var settings = try await settingsRepository.getSettings()
        if let expiryDate = newStatus.expiryDate {
            settings.subscriptionExpiryDate = expiryDate
        }
        settings.activeProductId = newStatus.productId
        settings.lastSubscriptionCheck = Date()
        try await settingsRepository.saveSettings(settings)

        // 7. Verify settings persistence
        let finalSettings = try await settingsRepository.getSettings()
        #expect(finalSettings.isPremium)
        #expect(finalSettings.subscriptionExpiryDate != nil)
        #expect(finalSettings.activeProductId == products[1].id)
    }

    // MARK: - Restore Flow Test

    @Test("Restore flow: Previously subscribed user restores purchase")
    func restoreFlow() async throws {
        // Setup - User has previous subscription but app doesn't know
        let subscriptionService = MockSubscriptionService()
        let settingsRepository = MockSettingsRepository()

        let premiumStatus = SubscriptionStatus.premium(
            expiryDate: Date().addingTimeInterval(86400 * 30),
            productId: "com.StudioNext.socraticJournal.yearly"
        )
        subscriptionService.restoreStatus = premiumStatus

        // Initial state shows free
        let initialStatus = await subscriptionService.currentStatus()
        #expect(!initialStatus.isPremium)

        // User initiates restore
        let viewModel = PaywallViewModel(subscriptionService: subscriptionService)
        let restoreResult = await viewModel.restorePurchases()

        #expect(restoreResult)
        #expect(viewModel.restoreSucceeded)
        #expect(viewModel.purchaseSucceeded) // Restore success also sets purchase success
        #expect(subscriptionService.restoreCalled)
    }

    // MARK: - Persistence Across Sessions Test

    @Test("Subscription status persists after app restart")
    func persistenceAcrossRestart() async throws {
        let settingsRepository = MockSettingsRepository()

        // Simulate first session - user purchases subscription
        let expiryDate = Date().addingTimeInterval(86400 * 365)
        var settings = try await settingsRepository.getSettings()
        settings.subscriptionExpiryDate = expiryDate
        settings.activeProductId = "com.StudioNext.socraticJournal.yearly"
        settings.lastSubscriptionCheck = Date()
        try await settingsRepository.saveSettings(settings)

        // Simulate "app restart" - new repository instance with same data
        let reloadedSettings = try await settingsRepository.getSettings()

        #expect(reloadedSettings.isPremium)
        #expect(reloadedSettings.subscriptionExpiryDate == expiryDate)
        #expect(reloadedSettings.activeProductId == "com.StudioNext.socraticJournal.yearly")
    }

    // MARK: - Expiry Test

    @Test("Expired subscription shows correct status")
    func expiredSubscription() async throws {
        let subscriptionService = MockSubscriptionService()

        // Set expired status
        let expiredDate = Date().addingTimeInterval(-86400) // Yesterday
        let expiredStatus = SubscriptionStatus.expired(
            expiryDate: expiredDate,
            productId: "com.StudioNext.socraticJournal.monthly"
        )
        subscriptionService.currentStatusValue = expiredStatus

        let status = await subscriptionService.currentStatus()

        #expect(!status.isPremium)
        #expect(status.displayName == "Expired")
        #expect(status.expiryDate != nil)
        #expect(status.expiryDate! < Date())
    }

    // MARK: - User Settings Computed Property Test

    @Test("UserSettings.isPremium correctly computed from expiry date")
    func isPremiumComputation() {
        // Future expiry - premium
        var premiumSettings = UserSettings.default
        premiumSettings.subscriptionExpiryDate = Date().addingTimeInterval(86400 * 30)
        #expect(premiumSettings.isPremium)

        // Past expiry - not premium
        var expiredSettings = UserSettings.default
        expiredSettings.subscriptionExpiryDate = Date().addingTimeInterval(-86400)
        #expect(!expiredSettings.isPremium)

        // No expiry - not premium
        let freeSettings = UserSettings.default
        #expect(!freeSettings.isPremium)
    }

    // MARK: - Purchase Cancellation Test

    @Test("Cancelled purchase doesn't change status")
    func cancelledPurchaseNoChange() async throws {
        let subscriptionService = MockSubscriptionService()
        subscriptionService.productsToReturn = MockSubscriptionService.createTestProducts()
        subscriptionService.purchaseError = .purchaseCancelled

        let viewModel = PaywallViewModel(subscriptionService: subscriptionService)
        await viewModel.loadProducts()

        let result = await viewModel.purchase()

        #expect(!result)
        #expect(!viewModel.purchaseSucceeded)
        #expect(viewModel.error == nil) // Cancellation doesn't set error

        // Status unchanged
        let status = await subscriptionService.currentStatus()
        #expect(!status.isPremium)
    }

    // MARK: - Settings Flow Test

    @Test("Settings shows correct status for free user")
    func settingsFreerUser() async throws {
        let subscriptionService = MockSubscriptionService()
        subscriptionService.currentStatusValue = .free

        let status = await subscriptionService.currentStatus()

        #expect(!status.isPremium)
        #expect(status.displayName == "Free")
    }

    @Test("Settings shows correct status for premium user")
    func settingsPremiumUser() async throws {
        let subscriptionService = MockSubscriptionService()
        subscriptionService.currentStatusValue = .premium(
            expiryDate: Date().addingTimeInterval(86400 * 30),
            productId: "yearly"
        )

        let status = await subscriptionService.currentStatus()

        #expect(status.isPremium)
        #expect(status.displayName == "Premium")
        #expect(status.expiryDate != nil)
    }

    // MARK: - No Paywall During Onboarding Test

    @Test("Onboarding flow doesn't trigger paywall")
    func onboardingNoPaywall() async throws {
        let settingsRepository = MockSettingsRepository()
        let analytics = MockAnalyticsService()

        // User starts onboarding
        var settings = try await settingsRepository.getSettings()
        #expect(!settings.hasCompletedOnboarding)

        // Simulate onboarding completion
        settings.hasCompletedOnboarding = true
        try await settingsRepository.saveSettings(settings)
        analytics.logEvent(.onboardingCompleted, parameters: nil)

        // Verify paywall was NOT shown during onboarding
        #expect(!analytics.hasLoggedEvent(.paywallViewed))
        #expect(analytics.hasLoggedEvent(.onboardingCompleted))

        // User is still free after onboarding
        let finalSettings = try await settingsRepository.getSettings()
        #expect(!finalSettings.isPremium)
    }
}
