// PaywallViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// ViewModel for the paywall screen
/// Manages product loading, selection, and purchase flow
@Observable
@MainActor
public final class PaywallViewModel {
    // MARK: - State

    /// Available subscription products
    private(set) var products: [SubscriptionProduct] = []

    /// Currently selected product (defaults to yearly for best value)
    private(set) var selectedProduct: SubscriptionProduct?

    /// Whether products are being loaded
    private(set) var isLoadingProducts: Bool = false

    /// Whether a purchase is in progress
    private(set) var isPurchasing: Bool = false

    /// Whether a restore is in progress
    private(set) var isRestoring: Bool = false

    /// Current error state
    private(set) var error: SubscriptionError?

    /// Whether purchase completed successfully
    private(set) var purchaseSucceeded: Bool = false

    /// Whether restore completed successfully
    private(set) var restoreSucceeded: Bool = false

    // MARK: - Dependencies

    private let subscriptionService: SubscriptionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Computed Properties

    /// The yearly product if available
    var yearlyProduct: SubscriptionProduct? {
        products.first { $0.period == .yearly }
    }

    /// The monthly product if available
    var monthlyProduct: SubscriptionProduct? {
        products.first { $0.period == .monthly }
    }

    /// Calculates savings percentage for yearly vs monthly
    var yearlySavingsPercentage: Int? {
        guard let yearly = yearlyProduct, let monthly = monthlyProduct else { return nil }
        let yearlyPrice = NSDecimalNumber(decimal: yearly.priceValue).doubleValue
        let monthlyPrice = NSDecimalNumber(decimal: monthly.priceValue).doubleValue
        guard monthlyPrice > 0 else { return nil }
        let yearlyMonthlyEquivalent = yearlyPrice / 12.0
        let savings = (1.0 - (yearlyMonthlyEquivalent / monthlyPrice)) * 100.0
        return Int(savings.rounded())
    }

    /// User-friendly error message for display
    var errorMessage: String? {
        guard let error = error else { return nil }
        let message = error.userFriendlyMessage
        return message.isEmpty ? nil : message
    }

    // MARK: - Initialization

    public init(
        subscriptionService: SubscriptionServiceProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    /// Loads available subscription products
    public func loadProducts() async {
        isLoadingProducts = true
        error = nil

        logEvent(.paywallViewed)

        do {
            products = try await subscriptionService.fetchProducts()

            // Default selection to yearly (best value)
            if selectedProduct == nil {
                selectedProduct = yearlyProduct ?? products.first
            }
        } catch let subscriptionError as SubscriptionError {
            error = subscriptionError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoadingProducts = false
    }

    /// Selects a product for purchase
    public func selectProduct(_ product: SubscriptionProduct) {
        selectedProduct = product
        logEvent(.productSelected, parameters: [
            "product_id": product.id,
            "period": product.period.rawValue
        ])
    }

    /// Initiates purchase for the selected product
    /// - Returns: true if purchase succeeded
    public func purchase() async -> Bool {
        guard let product = selectedProduct else {
            error = .productNotFound
            return false
        }

        isPurchasing = true
        error = nil
        purchaseSucceeded = false

        logEvent(.purchaseStarted, parameters: ["product_id": product.id])

        do {
            let status = try await subscriptionService.purchase(product)

            if status.isPremium {
                purchaseSucceeded = true
                logEvent(.purchaseCompleted, parameters: [
                    "product_id": product.id,
                    "period": product.period.rawValue
                ])
            }
        } catch let subscriptionError as SubscriptionError {
            // Don't show error for user cancellation
            if subscriptionError != .purchaseCancelled {
                error = subscriptionError
                logEvent(.purchaseFailed, parameters: [
                    "product_id": product.id,
                    "error": subscriptionError.localizedDescription ?? "Unknown"
                ])
            }
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }

        isPurchasing = false
        return purchaseSucceeded
    }

    /// Restores previous purchases
    /// - Returns: true if restore found a valid subscription
    public func restorePurchases() async -> Bool {
        isRestoring = true
        error = nil
        restoreSucceeded = false

        logEvent(.restoreStarted)

        do {
            let status = try await subscriptionService.restorePurchases()

            if status.isPremium {
                restoreSucceeded = true
                purchaseSucceeded = true
                logEvent(.restoreCompleted, parameters: ["found_subscription": true])
            } else {
                // No subscription found - not an error, just inform user
                logEvent(.restoreCompleted, parameters: ["found_subscription": false])
            }
        } catch let subscriptionError as SubscriptionError {
            error = subscriptionError
            logEvent(.restoreFailed, parameters: [
                "error": subscriptionError.localizedDescription ?? "Unknown"
            ])
        } catch {
            self.error = .networkError
        }

        isRestoring = false
        return restoreSucceeded
    }

    /// Clears the current error
    public func clearError() {
        error = nil
    }

    // MARK: - Analytics Helpers

    private func logEvent(_ event: PaywallAnalyticsEvent, parameters: [String: Any]? = nil) {
        // Map paywall events to analytics events
        switch event {
        case .paywallViewed:
            analyticsService?.logEvent(.paywallViewed, parameters: parameters)
        case .productSelected:
            analyticsService?.logEvent(.paywallProductSelected, parameters: parameters)
        case .purchaseStarted:
            analyticsService?.logEvent(.paywallPurchaseStarted, parameters: parameters)
        case .purchaseCompleted:
            analyticsService?.logEvent(.paywallPurchaseCompleted, parameters: parameters)
        case .purchaseFailed:
            analyticsService?.logEvent(.paywallPurchaseFailed, parameters: parameters)
        case .restoreStarted:
            analyticsService?.logEvent(.paywallRestoreStarted, parameters: parameters)
        case .restoreCompleted:
            analyticsService?.logEvent(.paywallRestoreCompleted, parameters: parameters)
        case .restoreFailed:
            analyticsService?.logEvent(.paywallRestoreFailed, parameters: parameters)
        }
    }
}

// MARK: - Paywall Analytics Events

private enum PaywallAnalyticsEvent {
    case paywallViewed
    case productSelected
    case purchaseStarted
    case purchaseCompleted
    case purchaseFailed
    case restoreStarted
    case restoreCompleted
    case restoreFailed
}
