// PaywallViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import os.log

/// ViewModel for the Paywall screen
@Observable
@MainActor
public final class PaywallViewModel {
    // MARK: - State

    /// Available subscription products
    private(set) var products: [SubscriptionProduct] = []

    /// Currently selected product (defaults to yearly for best value)
    var selectedProduct: SubscriptionProduct?

    /// Whether products are being loaded
    private(set) var isLoadingProducts: Bool = false

    /// Whether a purchase is in progress
    private(set) var isPurchasing: Bool = false

    /// Whether restore is in progress
    private(set) var isRestoring: Bool = false

    /// Current error if any
    private(set) var error: SubscriptionError?

    /// Tracks whether error should be shown as alert (only for purchase/restore, not product loading)
    private(set) var showErrorAsAlert: Bool = false

    /// Whether the purchase was successful
    private(set) var purchaseSucceeded: Bool = false

    /// The current subscription status
    private(set) var currentStatus: SubscriptionStatus = .free

    // MARK: - Computed Properties

    /// The monthly product if available
    var monthlyProduct: SubscriptionProduct? {
        products.first { $0.period == .monthly }
    }

    /// The yearly product if available
    var yearlyProduct: SubscriptionProduct? {
        products.first { $0.period == .yearly }
    }

    /// Savings percentage for yearly vs monthly
    var yearlySavingsPercentage: Int {
        guard let yearly = yearlyProduct, let monthly = monthlyProduct else { return 0 }
        return yearly.savingsPercentage(comparedTo: monthly)
    }

    /// Whether the user is already subscribed
    var isAlreadySubscribed: Bool {
        currentStatus.isPremium
    }

    /// Whether there's an error to display as an alert (only for purchase/restore errors, not product loading)
    var hasDisplayableError: Bool {
        guard let error = error else { return false }
        // Only show alert for purchase/restore errors (showErrorAsAlert must be true)
        // Product loading errors are shown inline in the error view, never as alerts
        return showErrorAsAlert && error.shouldShowToUser
    }

    /// User-friendly error message
    var errorMessage: String {
        error?.userFriendlyMessage ?? ""
    }

    // MARK: - Dependencies

    private let subscriptionService: SubscriptionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    private let logger = Logger(subsystem: "com.StudioNext.socraticJournal", category: "Paywall")

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
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        error = nil
        showErrorAsAlert = false

        do {
            // Fetch products and current status in parallel
            async let productsTask = subscriptionService.fetchProducts()
            async let statusTask = subscriptionService.currentStatus()

            let (fetchedProducts, status) = try await (productsTask, statusTask)

            products = fetchedProducts
            currentStatus = status

            // Select yearly by default (best value)
            if selectedProduct == nil {
                selectedProduct = yearlyProduct ?? monthlyProduct
            }

            logger.info("Loaded \(fetchedProducts.count) products")
            analyticsService?.logEvent(.paywallProductsLoaded)
        } catch let subscriptionError as SubscriptionError {
            self.error = subscriptionError
            logger.error("Failed to load products: \(subscriptionError.localizedDescription)")
            analyticsService?.logEvent(.paywallProductsLoadFailed)
        } catch {
            self.error = .unknown(error.localizedDescription)
            logger.error("Unknown error loading products: \(error.localizedDescription)")
        }

        isLoadingProducts = false
    }

    /// Selects a product for purchase
    public func selectProduct(_ product: SubscriptionProduct) {
        selectedProduct = product
        analyticsService?.logEvent(.paywallProductSelected)
    }

    /// Purchases the selected product
    /// - Returns: True if purchase was successful
    @discardableResult
    public func purchase() async -> Bool {
        guard let product = selectedProduct else {
            logger.warning("No product selected for purchase")
            return false
        }

        guard !isPurchasing else { return false }

        isPurchasing = true
        error = nil
        showErrorAsAlert = true
        purchaseSucceeded = false

        analyticsService?.logEvent(.paywallPurchaseStarted)

        do {
            let status = try await subscriptionService.purchase(product)
            currentStatus = status
            purchaseSucceeded = status.isPremium

            if purchaseSucceeded {
                logger.info("Purchase successful for \(product.id)")
                analyticsService?.logEvent(.paywallPurchaseCompleted)
            }

            isPurchasing = false
            return purchaseSucceeded
        } catch let subscriptionError as SubscriptionError {
            self.error = subscriptionError
            isPurchasing = false

            // Don't log cancellation as an error
            if case .purchaseCancelled = subscriptionError {
                logger.info("User cancelled purchase")
                analyticsService?.logEvent(.paywallPurchaseCancelled)
            } else {
                logger.error("Purchase failed: \(subscriptionError.localizedDescription)")
                analyticsService?.logEvent(.paywallPurchaseFailed)
            }

            return false
        } catch {
            self.error = .unknown(error.localizedDescription)
            isPurchasing = false
            logger.error("Unknown purchase error: \(error.localizedDescription)")
            return false
        }
    }

    /// Restores previous purchases
    /// - Returns: True if a subscription was restored
    @discardableResult
    public func restorePurchases() async -> Bool {
        guard !isRestoring else { return false }

        isRestoring = true
        error = nil
        showErrorAsAlert = true

        analyticsService?.logEvent(.paywallRestoreStarted)

        do {
            let status = try await subscriptionService.restorePurchases()
            currentStatus = status

            if status.isPremium {
                purchaseSucceeded = true
                logger.info("Subscription restored successfully")
                analyticsService?.logEvent(.paywallRestoreCompleted)
            } else {
                logger.info("No subscription to restore")
                analyticsService?.logEvent(.paywallRestoreCompleted)
            }

            isRestoring = false
            return status.isPremium
        } catch let subscriptionError as SubscriptionError {
            self.error = subscriptionError
            isRestoring = false
            logger.error("Restore failed: \(subscriptionError.localizedDescription)")
            analyticsService?.logEvent(.paywallRestoreFailed)
            return false
        } catch {
            self.error = .unknown(error.localizedDescription)
            isRestoring = false
            logger.error("Unknown restore error: \(error.localizedDescription)")
            return false
        }
    }

    /// Clears the current error
    public func clearError() {
        error = nil
        showErrorAsAlert = false
    }

    /// Logs that the paywall was viewed
    public func logPaywallViewed() {
        analyticsService?.logEvent(.paywallViewed)
    }

    /// Logs that the paywall was dismissed
    public func logPaywallDismissed() {
        analyticsService?.logEvent(.paywallDismissed)
    }
}
#endif
