// StoreKitSubscriptionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import StoreKit

/// StoreKit 2 implementation of subscription service
@MainActor
public final class StoreKitSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    /// Shared instance for subscription operations
    public static let shared = StoreKitSubscriptionService()

    // MARK: - Private Properties

    private let defaults: UserDefaults
    private let statusKey = "com.socraticjournal.subscription_status"
    private var updateListenerTask: Task<Void, Error>?
    private var statusContinuation: AsyncStream<SubscriptionStatus>.Continuation?

    // MARK: - Public Properties

    public private(set) lazy var statusStream: AsyncStream<SubscriptionStatus> = {
        AsyncStream { continuation in
            self.statusContinuation = continuation
            // Emit current status immediately
            Task {
                let status = await self.currentStatus()
                continuation.yield(status)
            }
        }
    }()

    // MARK: - Initialization

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        startTransactionListener()
        logEnvironment()
    }

    deinit {
        updateListenerTask?.cancel()
        statusContinuation?.finish()
    }

    // MARK: - Environment Logging

    private func logEnvironment() {
        #if DEBUG
        print("[Subscription] Environment: Sandbox/Debug")
        print("[Subscription] Products: \(SubscriptionProductId.all)")
        #else
        print("[Subscription] Environment: Production")
        #endif
    }

    // MARK: - Transaction Listener

    private func startTransactionListener() {
        updateListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.handleTransactionUpdate(transaction)
                    await transaction.finish()
                } catch {
                    #if DEBUG
                    print("[Subscription] Transaction verification failed: \(error)")
                    #endif
                }
            }
        }
    }

    private func handleTransactionUpdate(_ transaction: Transaction) async {
        let status = await refreshSubscriptionStatus()
        statusContinuation?.yield(status)
        #if DEBUG
        print("[Subscription] Transaction update: \(transaction.productID), status: \(status)")
        #endif
    }

    // MARK: - SubscriptionServiceProtocol

    public func fetchProducts() async throws -> [SubscriptionProduct] {
        do {
            let storeProducts = try await Product.products(for: SubscriptionProductId.all)

            guard !storeProducts.isEmpty else {
                throw SubscriptionError.productNotFound
            }

            let subscriptionProducts = storeProducts.compactMap { product -> SubscriptionProduct? in
                guard let subscription = product.subscription else { return nil }

                let period: SubscriptionPeriod
                switch subscription.subscriptionPeriod.unit {
                case .month:
                    period = .monthly
                case .year:
                    period = .yearly
                default:
                    return nil
                }

                return SubscriptionProduct(
                    id: product.id,
                    displayName: product.displayName,
                    displayPrice: product.displayPrice,
                    period: period,
                    priceValue: product.price
                )
            }

            // Sort by price (monthly first, then yearly)
            return subscriptionProducts.sorted { $0.priceValue < $1.priceValue }

        } catch let error as SubscriptionError {
            throw error
        } catch {
            #if DEBUG
            print("[Subscription] Failed to fetch products: \(error)")
            #endif
            throw SubscriptionError.networkError
        }
    }

    public func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        do {
            // Find the StoreKit product
            let storeProducts = try await Product.products(for: [product.id])
            guard let storeProduct = storeProducts.first else {
                throw SubscriptionError.productNotFound
            }

            // Initiate purchase
            let result = try await storeProduct.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()

                let status = await refreshSubscriptionStatus()
                statusContinuation?.yield(status)

                #if DEBUG
                print("[Subscription] Purchase successful: \(product.id)")
                #endif

                return status

            case .userCancelled:
                throw SubscriptionError.purchaseCancelled

            case .pending:
                // Purchase requires approval (Ask to Buy, etc.)
                #if DEBUG
                print("[Subscription] Purchase pending approval")
                #endif
                return await currentStatus()

            @unknown default:
                throw SubscriptionError.unknown("Unexpected purchase result")
            }

        } catch let error as SubscriptionError {
            throw error
        } catch let error as StoreKitError {
            #if DEBUG
            print("[Subscription] StoreKit error: \(error)")
            #endif
            throw SubscriptionError.purchaseFailed(error.localizedDescription)
        } catch {
            #if DEBUG
            print("[Subscription] Purchase failed: \(error)")
            #endif
            throw SubscriptionError.purchaseFailed(error.localizedDescription)
        }
    }

    public func restorePurchases() async throws -> SubscriptionStatus {
        do {
            // Sync with App Store
            try await AppStore.sync()

            // Refresh status after sync
            let status = await refreshSubscriptionStatus()
            statusContinuation?.yield(status)

            #if DEBUG
            print("[Subscription] Restore completed, status: \(status)")
            #endif

            return status

        } catch {
            #if DEBUG
            print("[Subscription] Restore failed: \(error)")
            #endif
            throw SubscriptionError.networkError
        }
    }

    public func currentStatus() async -> SubscriptionStatus {
        // First try to get fresh status from App Store
        let freshStatus = await checkCurrentEntitlement()

        // If we have fresh data, persist and return it
        if case .premium = freshStatus {
            persistStatus(freshStatus)
            return freshStatus
        }

        // Check if fresh status shows expired
        if case .expired = freshStatus {
            persistStatus(freshStatus)
            return freshStatus
        }

        // If no entitlement found, return free
        persistStatus(.free)
        return .free
    }

    // MARK: - Private Helpers

    private func checkCurrentEntitlement() async -> SubscriptionStatus {
        // Check entitlements for all our products
        for productId in SubscriptionProductId.all {
            if let result = await Transaction.currentEntitlement(for: productId) {
                do {
                    let transaction = try checkVerified(result)

                    // Check if subscription is still valid
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            return .premium(expiryDate: expirationDate, productId: transaction.productID)
                        } else {
                            return .expired(expiryDate: expirationDate, productId: transaction.productID)
                        }
                    }
                } catch {
                    #if DEBUG
                    print("[Subscription] Verification failed for \(productId): \(error)")
                    #endif
                    continue
                }
            }
        }
        return .free
    }

    private func refreshSubscriptionStatus() async -> SubscriptionStatus {
        let status = await checkCurrentEntitlement()
        persistStatus(status)
        return status
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            #if DEBUG
            print("[Subscription] Verification error: \(error)")
            #endif
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Persistence

    private func persistStatus(_ status: SubscriptionStatus) {
        do {
            let data = try JSONEncoder().encode(status)
            defaults.set(data, forKey: statusKey)
            #if DEBUG
            print("[Subscription] Persisted status: \(status)")
            #endif
        } catch {
            #if DEBUG
            print("[Subscription] Failed to persist status: \(error)")
            #endif
        }
    }

    private func loadPersistedStatus() -> SubscriptionStatus? {
        guard let data = defaults.data(forKey: statusKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(SubscriptionStatus.self, from: data)
        } catch {
            #if DEBUG
            print("[Subscription] Failed to load persisted status: \(error)")
            #endif
            return nil
        }
    }
}
