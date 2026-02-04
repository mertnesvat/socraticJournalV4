// StoreKitSubscriptionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import StoreKit
import os.log

/// StoreKit 2 implementation of the subscription service
/// Handles product fetching, purchases, transaction verification, and status management
@MainActor
public final class StoreKitSubscriptionService: SubscriptionServiceProtocol {
    // MARK: - Shared Instance

    /// Shared instance for app-wide subscription management
    public static let shared = StoreKitSubscriptionService()

    // MARK: - Properties

    private let logger = Logger(subsystem: "com.StudioNext.socraticJournal", category: "Subscription")

    /// UserDefaults key for cached subscription status
    private let statusCacheKey = "subscription_status"

    /// UserDefaults key for last verification date
    private let lastVerificationKey = "subscription_last_verification"

    /// How long to trust cached status before re-verifying (1 hour)
    private let cacheValidityDuration: TimeInterval = 3600

    /// Cached subscription products
    private var cachedProducts: [SubscriptionProduct] = []

    /// Task handle for transaction listener
    private var transactionListenerTask: Task<Void, Never>?

    /// Continuation for status stream
    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?

    /// Current cached status
    private var currentCachedStatus: SubscriptionStatus = .free

    // MARK: - Status Stream

    public var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream { [weak self] continuation in
            self?.statusContinuation = continuation
            // Emit current status immediately
            if let status = self?.currentCachedStatus {
                continuation.yield(status)
            }
        }
    }

    // MARK: - Initialization

    public init() {
        // Load cached status
        currentCachedStatus = loadCachedStatus()

        // Start listening for transaction updates
        startTransactionListener()

        // Log environment
        logEnvironment()
    }

    deinit {
        transactionListenerTask?.cancel()
        statusContinuation?.finish()
    }

    // MARK: - Environment Logging

    private func logEnvironment() {
        #if DEBUG
        logger.info("StoreKit environment: Sandbox/Testing")
        #else
        logger.info("StoreKit environment: Production")
        #endif
    }

    // MARK: - Transaction Listener

    private func startTransactionListener() {
        transactionListenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }

                do {
                    let transaction = try self.checkVerified(result)
                    await self.handleVerifiedTransaction(transaction)
                    await transaction.finish()
                } catch {
                    self.logger.error("Transaction verification failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        // Check if this is for one of our subscription products
        guard SubscriptionProductID.all.contains(transaction.productID) else { return }

        // Update status based on transaction
        let status = await refreshSubscriptionStatus()
        self.currentCachedStatus = status
        self.statusContinuation?.yield(status)
        self.cacheStatus(status)
    }

    // MARK: - SubscriptionServiceProtocol

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        logger.info("Fetching subscription products...")

        do {
            let storeProducts = try await Product.products(for: SubscriptionProductID.all)

            guard !storeProducts.isEmpty else {
                logger.warning("No products found in App Store")
                throw SubscriptionError.productNotFound
            }

            let products = storeProducts.compactMap { mapToSubscriptionProduct($0) }

            // Sort: yearly first (better value), then monthly
            let sortedProducts = products.sorted { product1, product2 in
                if product1.period == .yearly && product2.period == .monthly {
                    return true
                }
                return false
            }

            cachedProducts = sortedProducts
            logger.info("Fetched \(sortedProducts.count) products")

            return sortedProducts
        } catch let error as SubscriptionError {
            throw error
        } catch {
            logger.error("Failed to fetch products: \(error.localizedDescription)")
            throw SubscriptionError.networkError
        }
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        logger.info("Starting purchase for product: \(product.id)")

        // Find the StoreKit product
        guard let storeProduct = try await findStoreProduct(productId: product.id) else {
            logger.error("Product not found: \(product.id)")
            throw SubscriptionError.productNotFound
        }

        do {
            let result = try await storeProduct.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()

                logger.info("Purchase successful for: \(product.id)")

                // Refresh and return new status
                let status = await refreshSubscriptionStatus()
                currentCachedStatus = status
                statusContinuation?.yield(status)
                cacheStatus(status)

                return status

            case .userCancelled:
                logger.info("User cancelled purchase")
                throw SubscriptionError.purchaseCancelled

            case .pending:
                logger.info("Purchase pending (Ask to Buy or other pending state)")
                // Return current status - transaction will be handled when it completes
                return currentCachedStatus

            @unknown default:
                logger.warning("Unknown purchase result")
                throw SubscriptionError.unknown("Unknown purchase result")
            }
        } catch let error as SubscriptionError {
            throw error
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

            // Refresh status
            let status = await refreshSubscriptionStatus()
            currentCachedStatus = status
            statusContinuation?.yield(status)
            cacheStatus(status)

            logger.info("Restore complete. Status: \(status.displayName)")
            return status
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            throw SubscriptionError.networkError
        }
    }

    public func currentStatus() async -> SubscriptionStatus {
        // Check if cached status is still valid
        if isCacheValid() {
            return currentCachedStatus
        }

        // Refresh from StoreKit
        let status = await refreshSubscriptionStatus()
        currentCachedStatus = status
        cacheStatus(status)

        return status
    }

    // MARK: - Helpers

    private func findStoreProduct(productId: String) async throws -> Product? {
        let products = try await Product.products(for: [productId])
        return products.first
    }

    private func mapToSubscriptionProduct(_ storeProduct: Product) -> SubscriptionProduct? {
        let period: SubscriptionPeriod

        // Determine period from product ID
        if storeProduct.id == SubscriptionProductID.monthly {
            period = .monthly
        } else if storeProduct.id == SubscriptionProductID.yearly {
            period = .yearly
        } else {
            logger.warning("Unknown product ID: \(storeProduct.id)")
            return nil
        }

        return SubscriptionProduct(
            id: storeProduct.id,
            displayName: storeProduct.displayName,
            displayPrice: storeProduct.displayPrice,
            period: period,
            priceValue: storeProduct.price
        )
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            logger.error("Verification failed: \(error.localizedDescription)")
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func refreshSubscriptionStatus() async -> SubscriptionStatus {
        // Check entitlements for our subscription products
        for productId in SubscriptionProductID.all {
            if let result = await Transaction.currentEntitlement(for: productId) {
                do {
                    let transaction = try checkVerified(result)

                    // Check if subscription is still active
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            logger.info("Active subscription found: \(productId), expires: \(expirationDate)")
                            return .premium(expiryDate: expirationDate, productId: productId)
                        } else {
                            logger.info("Subscription expired: \(productId)")
                            return .expired
                        }
                    } else {
                        // No expiration date (shouldn't happen for subscriptions)
                        logger.warning("Subscription has no expiration date: \(productId)")
                        return .premium(expiryDate: Date().addingTimeInterval(30 * 24 * 60 * 60), productId: productId)
                    }
                } catch {
                    logger.error("Failed to verify entitlement: \(error.localizedDescription)")
                }
            }
        }

        logger.info("No active subscription found")
        return .free
    }

    // MARK: - Caching

    private func cacheStatus(_ status: SubscriptionStatus) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(status)
            UserDefaults.standard.set(data, forKey: statusCacheKey)
            UserDefaults.standard.set(Date(), forKey: lastVerificationKey)
        } catch {
            logger.error("Failed to cache subscription status: \(error.localizedDescription)")
        }
    }

    private func loadCachedStatus() -> SubscriptionStatus {
        guard let data = UserDefaults.standard.data(forKey: statusCacheKey) else {
            return .free
        }

        do {
            let decoder = JSONDecoder()
            let status = try decoder.decode(SubscriptionStatus.self, from: data)

            // If premium, check if still valid
            if case .premium(let expiryDate, _) = status {
                if expiryDate <= Date() {
                    return .expired
                }
            }

            return status
        } catch {
            logger.error("Failed to decode cached status: \(error.localizedDescription)")
            return .free
        }
    }

    private func isCacheValid() -> Bool {
        guard let lastVerification = UserDefaults.standard.object(forKey: lastVerificationKey) as? Date else {
            return false
        }

        let elapsed = Date().timeIntervalSince(lastVerification)
        return elapsed < cacheValidityDuration
    }
}
#endif
