// StoreKitSubscriptionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import StoreKit
import os.log

/// StoreKit 2 implementation of the subscription service
@MainActor
public final class StoreKitSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    // MARK: - Properties

    private let logger = Logger(subsystem: "com.StudioNext.socraticJournal", category: "StoreKit")

    /// UserDefaults key for persisted subscription status
    private static let statusKey = "subscription_status"
    private static let lastCheckKey = "subscription_last_check"

    /// Cached subscription status
    private var cachedStatus: SubscriptionStatus = .free

    /// Continuation for the status stream
    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?

    /// Task handling transaction updates
    private var transactionListenerTask: Task<Void, Never>?

    /// UserDefaults for persistence
    private let userDefaults: UserDefaults

    // MARK: - Status Stream

    public let statusStream: AsyncStream<SubscriptionStatus>

    // MARK: - Initialization

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Create the status stream
        var continuation: AsyncStream<SubscriptionStatus>.Continuation?
        statusStream = AsyncStream { cont in
            continuation = cont
        }
        statusContinuation = continuation

        // Load persisted status
        if let data = userDefaults.data(forKey: Self.statusKey),
           let status = try? JSONDecoder().decode(SubscriptionStatus.self, from: data) {
            cachedStatus = status
            logger.info("Loaded persisted subscription status: \(status.displayName)")
        }

        // Log environment
        logStoreKitEnvironment()

        // Start listening for transaction updates
        startTransactionListener()

        // Check current entitlements
        Task {
            await refreshSubscriptionStatus()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
        statusContinuation?.finish()
    }

    // MARK: - SubscriptionServiceProtocol

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        logger.info("Fetching subscription products...")

        do {
            let storeProducts = try await Product.products(for: SubscriptionProductID.all)

            guard !storeProducts.isEmpty else {
                logger.error("No products returned from App Store")
                throw SubscriptionError.productNotFound
            }

            let products = storeProducts.compactMap { product -> SubscriptionProduct? in
                guard let subscription = product.subscription else {
                    logger.warning("Product \(product.id) is not a subscription")
                    return nil
                }

                let period: SubscriptionPeriod
                switch subscription.subscriptionPeriod.unit {
                case .month:
                    period = .monthly
                case .year:
                    period = .yearly
                default:
                    logger.warning("Unsupported subscription period for \(product.id)")
                    return nil
                }

                return SubscriptionProduct(
                    id: product.id,
                    displayName: product.displayName,
                    displayPrice: product.displayPrice,
                    period: period,
                    priceValue: product.price,
                    description: product.description
                )
            }

            logger.info("Fetched \(products.count) subscription products")
            return products.sorted { $0.period == .monthly && $1.period == .yearly }
        } catch let error as StoreKitError {
            logger.error("StoreKit error fetching products: \(error.localizedDescription)")
            throw mapStoreKitError(error)
        } catch {
            logger.error("Unknown error fetching products: \(error.localizedDescription)")
            throw SubscriptionError.networkError(error.localizedDescription)
        }
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        logger.info("Initiating purchase for product: \(product.id)")

        // Find the StoreKit product
        let storeProducts = try await Product.products(for: [product.id])
        guard let storeProduct = storeProducts.first else {
            logger.error("Product not found: \(product.id)")
            throw SubscriptionError.productNotFound
        }

        do {
            let result = try await storeProduct.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                logger.info("Purchase successful for \(product.id)")

                // Finish the transaction
                await transaction.finish()

                // Refresh and return the new status
                return await refreshSubscriptionStatus()

            case .userCancelled:
                logger.info("User cancelled purchase")
                throw SubscriptionError.purchaseCancelled

            case .pending:
                logger.info("Purchase pending (requires approval)")
                // Return current status, transaction listener will update when approved
                return cachedStatus

            @unknown default:
                logger.warning("Unknown purchase result")
                throw SubscriptionError.unknown("Unknown purchase result")
            }
        } catch let error as SubscriptionError {
            throw error
        } catch let error as StoreKitError {
            logger.error("StoreKit purchase error: \(error.localizedDescription)")
            throw mapStoreKitError(error)
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            throw SubscriptionError.purchaseFailed(error.localizedDescription)
        }
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        logger.info("Restoring purchases...")

        do {
            // Sync with App Store
            try await AppStore.sync()
            logger.info("App Store sync completed")

            // Refresh subscription status
            return await refreshSubscriptionStatus()
        } catch let error as StoreKitError {
            logger.error("StoreKit restore error: \(error.localizedDescription)")
            throw mapStoreKitError(error)
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            throw SubscriptionError.networkError(error.localizedDescription)
        }
    }

    public nonisolated func currentStatus() async -> SubscriptionStatus {
        await MainActor.run {
            cachedStatus
        }
    }

    // MARK: - Private Methods

    /// Refreshes the subscription status by checking current entitlements
    @discardableResult
    private func refreshSubscriptionStatus() async -> SubscriptionStatus {
        logger.debug("Refreshing subscription status...")

        var newStatus: SubscriptionStatus = .free

        // Check for active subscriptions
        for productId in SubscriptionProductID.all {
            if let verification = await Transaction.currentEntitlement(for: productId) {
                do {
                    let transaction = try checkVerified(verification)

                    // Check if subscription is still valid
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            newStatus = .premium(expiryDate: expirationDate, productId: productId)
                            logger.info("Active subscription found: \(productId), expires: \(expirationDate)")
                            break
                        } else {
                            newStatus = .expired(lastExpiryDate: expirationDate, lastProductId: productId)
                            logger.info("Expired subscription found: \(productId), expired: \(expirationDate)")
                        }
                    }
                } catch {
                    logger.warning("Failed to verify transaction for \(productId): \(error.localizedDescription)")
                }
            }
        }

        // Update cached status
        updateStatus(newStatus)
        return newStatus
    }

    /// Updates the cached status and persists it
    private func updateStatus(_ status: SubscriptionStatus) {
        guard cachedStatus != status else { return }

        cachedStatus = status

        // Persist to UserDefaults
        if let data = try? JSONEncoder().encode(status) {
            userDefaults.set(data, forKey: Self.statusKey)
            userDefaults.set(Date(), forKey: Self.lastCheckKey)
        }

        // Notify observers
        statusContinuation?.yield(status)

        logger.info("Subscription status updated to: \(status.displayName)")
    }

    /// Starts listening for transaction updates
    private func startTransactionListener() {
        transactionListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { break }
                do {
                    let transaction = try await self.checkVerifiedNonisolated(result)
                    await transaction.finish()
                    await self.refreshSubscriptionStatus()
                } catch {
                    await self.logWarning("Transaction verification failed: \(error.localizedDescription)")
                }
            }
        }
        logger.info("Transaction listener started")
    }

    /// Verifies a transaction result
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            logger.error("Transaction verification failed: \(error.localizedDescription)")
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    /// Nonisolated version for use in detached tasks
    private nonisolated func checkVerifiedNonisolated<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    /// Nonisolated logging helper
    private nonisolated func logWarning(_ message: String) async {
        await MainActor.run {
            logger.warning("\(message)")
        }
    }

    /// Maps StoreKit errors to SubscriptionError
    private func mapStoreKitError(_ error: StoreKitError) -> SubscriptionError {
        switch error {
        case .networkError:
            return .networkError("Network connection unavailable")
        case .userCancelled:
            return .purchaseCancelled
        case .notAvailableInStorefront:
            return .productNotFound
        case .notEntitled:
            return .notEntitled
        default:
            return .unknown(error.localizedDescription)
        }
    }

    /// Logs the current StoreKit environment
    private func logStoreKitEnvironment() {
        Task {
            if let appTransaction = try? await AppTransaction.shared {
                switch appTransaction {
                case .verified(let transaction):
                    let environment = transaction.environment
                    logger.info("StoreKit environment: \(environment.rawValue)")
                case .unverified:
                    logger.warning("App transaction unverified")
                }
            } else {
                logger.info("StoreKit environment: Unable to determine (likely simulator)")
            }
        }
    }
}

// MARK: - Preview/Testing Support

#if DEBUG
/// Mock subscription service for previews and testing
public final class MockSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    public var mockProducts: [SubscriptionProduct] = [
        SubscriptionProduct(
            id: SubscriptionProductID.monthly,
            displayName: "Monthly Premium",
            displayPrice: "$4.99",
            period: .monthly,
            priceValue: 4.99,
            description: "Full access to all premium features"
        ),
        SubscriptionProduct(
            id: SubscriptionProductID.yearly,
            displayName: "Yearly Premium",
            displayPrice: "$29.99",
            period: .yearly,
            priceValue: 29.99,
            description: "Save 50% with annual billing"
        )
    ]

    public var mockStatus: SubscriptionStatus = .free
    public var shouldFailFetch: Bool = false
    public var shouldFailPurchase: Bool = false
    public var shouldCancelPurchase: Bool = false

    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?
    public let statusStream: AsyncStream<SubscriptionStatus>

    public init() {
        var continuation: AsyncStream<SubscriptionStatus>.Continuation?
        statusStream = AsyncStream { cont in
            continuation = cont
        }
        statusContinuation = continuation
    }

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        try await Task.sleep(for: .milliseconds(500))
        if shouldFailFetch {
            throw SubscriptionError.networkError("Mock network error")
        }
        return mockProducts
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        try await Task.sleep(for: .seconds(1))
        if shouldCancelPurchase {
            throw SubscriptionError.purchaseCancelled
        }
        if shouldFailPurchase {
            throw SubscriptionError.purchaseFailed("Mock purchase error")
        }
        let expiryDate = Calendar.current.date(byAdding: product.period == .monthly ? .month : .year, value: 1, to: Date())!
        mockStatus = .premium(expiryDate: expiryDate, productId: product.id)
        statusContinuation?.yield(mockStatus)
        return mockStatus
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        try await Task.sleep(for: .milliseconds(500))
        statusContinuation?.yield(mockStatus)
        return mockStatus
    }

    public func currentStatus() async -> SubscriptionStatus {
        mockStatus
    }

    /// Helper to simulate subscription status changes
    public func simulateStatusChange(_ status: SubscriptionStatus) {
        mockStatus = status
        statusContinuation?.yield(status)
    }
}
#endif
#endif
