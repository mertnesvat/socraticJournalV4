// PaywallViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import os.log

/// ViewModel that manages paywall state, product selection, and purchase flow
@Observable
@MainActor
public final class PaywallViewModel {
    // MARK: - Properties

    /// Available subscription products
    private(set) var products: [SubscriptionProduct] = []

    /// Currently selected product (defaults to yearly for best value)
    var selectedProduct: SubscriptionProduct?

    /// Whether products are being loaded
    private(set) var isLoadingProducts: Bool = false

    /// Whether a purchase is in progress
    private(set) var isPurchasing: Bool = false

    /// Whether a restore is in progress
    private(set) var isRestoring: Bool = false

    /// Current error, if any
    private(set) var error: SubscriptionError?

    /// Whether purchase succeeded (used for dismissal)
    private(set) var purchaseSucceeded: Bool = false

    /// Whether restore succeeded with a subscription
    private(set) var restoreSucceeded: Bool = false

    // MARK: - Dependencies

    private let subscriptionService: SubscriptionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    private let logger = Logger(subsystem: "com.StudioNext.socraticJournal", category: "Paywall")

    // MARK: - Computed Properties

    /// The monthly product, if available
    var monthlyProduct: SubscriptionProduct? {
        products.first { $0.period == .monthly }
    }

    /// The yearly product, if available
    var yearlyProduct: SubscriptionProduct? {
        products.first { $0.period == .yearly }
    }

    /// Savings percentage for yearly plan
    var yearlySavingsPercent: Int? {
        guard let yearly = yearlyProduct, let monthly = monthlyProduct else { return nil }
        return yearly.savingsPercentage(comparedTo: monthly)
    }

    /// Whether any product is available
    var hasProducts: Bool {
        !products.isEmpty
    }

    /// User-friendly error message
    var errorMessage: String? {
        error?.userMessage
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

    /// Loads subscription products from the App Store
    public func loadProducts() async {
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        error = nil

        logEvent(.paywallViewed)

        do {
            products = try await subscriptionService.fetchProducts()

            // Default to yearly (best value)
            selectedProduct = yearlyProduct ?? products.first

            logger.info("Loaded \(self.products.count) products")
        } catch let subscriptionError as SubscriptionError {
            error = subscriptionError
            logger.error("Failed to load products: \(subscriptionError.localizedDescription)")
        } catch {
            self.error = .networkError
            logger.error("Failed to load products: \(error.localizedDescription)")
        }

        isLoadingProducts = false
    }

    /// Selects a product for purchase
    public func selectProduct(_ product: SubscriptionProduct) {
        selectedProduct = product
        logEvent(.paywallProductSelected, parameters: ["product_id": product.id])
    }

    /// Initiates purchase of the selected product
    /// - Returns: true if purchase succeeded, false otherwise
    @discardableResult
    public func purchase() async -> Bool {
        guard let product = selectedProduct else {
            logger.warning("No product selected for purchase")
            return false
        }

        guard !isPurchasing else { return false }

        isPurchasing = true
        error = nil
        purchaseSucceeded = false

        logEvent(.paywallPurchaseStarted, parameters: ["product_id": product.id])

        do {
            let status = try await subscriptionService.purchase(product)

            if status.isPremium {
                purchaseSucceeded = true
                logEvent(.paywallPurchaseCompleted, parameters: [
                    "product_id": product.id,
                    "period": product.period.rawValue
                ])
                logger.info("Purchase succeeded: \(product.id)")
            }

            isPurchasing = false
            return purchaseSucceeded
        } catch let subscriptionError as SubscriptionError {
            isPurchasing = false

            // Don't show error for user cancellation
            if subscriptionError != .purchaseCancelled {
                error = subscriptionError
                logEvent(.paywallPurchaseFailed, parameters: [
                    "product_id": product.id,
                    "error": subscriptionError.localizedDescription ?? "unknown"
                ])
            } else {
                logEvent(.paywallPurchaseCancelled, parameters: ["product_id": product.id])
            }

            return false
        } catch {
            isPurchasing = false
            self.error = .purchaseFailed(error.localizedDescription)
            logEvent(.paywallPurchaseFailed, parameters: [
                "product_id": product.id,
                "error": error.localizedDescription
            ])
            return false
        }
    }

    /// Restores previous purchases
    /// - Returns: true if a subscription was restored, false otherwise
    @discardableResult
    public func restorePurchases() async -> Bool {
        guard !isRestoring else { return false }

        isRestoring = true
        error = nil
        restoreSucceeded = false

        logEvent(.paywallRestoreStarted)

        do {
            let status = try await subscriptionService.restorePurchases()

            if status.isPremium {
                restoreSucceeded = true
                purchaseSucceeded = true // Also set this to trigger dismissal
                logEvent(.paywallRestoreCompleted, parameters: ["has_subscription": true])
                logger.info("Restore succeeded with active subscription")
            } else {
                logEvent(.paywallRestoreCompleted, parameters: ["has_subscription": false])
                logger.info("Restore completed but no active subscription found")
            }

            isRestoring = false
            return restoreSucceeded
        } catch let subscriptionError as SubscriptionError {
            isRestoring = false
            error = subscriptionError
            logEvent(.paywallRestoreFailed, parameters: [
                "error": subscriptionError.localizedDescription ?? "unknown"
            ])
            return false
        } catch {
            isRestoring = false
            self.error = .networkError
            logEvent(.paywallRestoreFailed, parameters: ["error": error.localizedDescription])
            return false
        }
    }

    /// Clears any displayed error
    public func clearError() {
        error = nil
    }

    // MARK: - Analytics

    private func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        analyticsService?.logEvent(event, parameters: parameters)
    }
}
#endif
