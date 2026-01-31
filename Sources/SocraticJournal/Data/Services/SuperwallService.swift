// SuperwallService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SuperwallKit

/// Superwall implementation of SubscriptionServiceProtocol
/// Handles paywall presentation and subscription status tracking
@Observable
public final class SuperwallService: SubscriptionServiceProtocol, @unchecked Sendable {
    /// Shared instance for subscription operations
    public static let shared = SuperwallService()

    // MARK: - Observable State

    /// Current subscription status
    public private(set) var subscriptionStatus: SubscriptionStatus = .unknown

    // MARK: - Private Properties

    /// Superwall API key from Superwall dashboard
    private let apiKey: String = "pk_-9N4-ap0hGI3amNXMFqVd"

    /// Delegate handler for Superwall callbacks
    private var delegateHandler: SuperwallDelegateHandler?

    // MARK: - Init

    private init() {
        delegateHandler = SuperwallDelegateHandler(service: self)
    }

    // MARK: - SubscriptionServiceProtocol

    public var isPro: Bool {
        subscriptionStatus.isPro
    }

    public func configure() {
        // Configure Superwall with options
        let options = SuperwallOptions()

        // Customize paywall presentation behavior
        options.paywalls.shouldShowPurchaseFailureAlert = true

        // Enable logging in debug mode
        #if DEBUG
        options.logging.level = .debug
        #else
        options.logging.level = .warn
        #endif

        // Configure Superwall
        Superwall.configure(
            apiKey: apiKey,
            options: options
        )

        // Set delegate for subscription status updates
        Superwall.shared.delegate = delegateHandler

        // Sync initial subscription status
        syncSubscriptionStatus()

        #if DEBUG
        print("[Superwall] Configured with API key")
        #endif
    }

    @MainActor
    public func register(trigger: PaywallTrigger) {
        Superwall.shared.register(placement: trigger.rawValue)

        #if DEBUG
        print("[Superwall] Registered trigger: \(trigger.rawValue)")
        #endif
    }

    @MainActor
    public func register(trigger: PaywallTrigger, handler: @escaping @Sendable () -> Void) {
        Superwall.shared.register(placement: trigger.rawValue) {
            // This handler is called when the feature should be accessed
            // (user is subscribed, paywall dismissed with purchase, or no paywall configured)
            handler()
        }

        #if DEBUG
        print("[Superwall] Registered trigger with handler: \(trigger.rawValue)")
        #endif
    }

    @MainActor
    public func restorePurchases() async -> Bool {
        do {
            let result = try await Superwall.shared.restorePurchases()

            // Update status after restore
            syncSubscriptionStatus()

            #if DEBUG
            print("[Superwall] Restore result: \(result)")
            #endif

            switch result {
            case .restored:
                return true
            case .failed:
                return false
            }
        } catch {
            #if DEBUG
            print("[Superwall] Restore error: \(error)")
            #endif
            return false
        }
    }

    public func identify(userId: String?) {
        if let userId = userId {
            Superwall.shared.identify(userId: userId)
            #if DEBUG
            print("[Superwall] Identified user: \(userId)")
            #endif
        } else {
            Superwall.shared.reset()
            #if DEBUG
            print("[Superwall] Reset to anonymous user")
            #endif
        }
    }

    public func setUserAttributes(_ attributes: [String: Any]) {
        Superwall.shared.setUserAttributes(attributes)

        #if DEBUG
        print("[Superwall] Set user attributes: \(attributes)")
        #endif
    }

    // MARK: - Internal Methods

    /// Sync subscription status from Superwall SDK
    internal func syncSubscriptionStatus() {
        let status = Superwall.shared.subscriptionStatus

        switch status {
        case .unknown:
            subscriptionStatus = .unknown
        case .inactive:
            subscriptionStatus = .inactive
        case .active(let entitlements):
            // Map entitlements to subscription tier
            let tier = mapEntitlementsToTier(entitlements)
            subscriptionStatus = .active(tier: tier)
        }

        #if DEBUG
        print("[Superwall] Synced subscription status: \(subscriptionStatus)")
        #endif
    }

    /// Map Superwall entitlements to our subscription tier
    /// Configure entitlement names in Superwall dashboard to match these
    private func mapEntitlementsToTier(_ entitlements: Set<Entitlement>) -> SubscriptionTier {
        let entitlementNames = entitlements.map { $0.id }

        // Check for lifetime first (highest priority)
        if entitlementNames.contains(where: { $0.lowercased().contains("lifetime") }) {
            return .lifetime
        }

        // Check for yearly
        if entitlementNames.contains(where: { $0.lowercased().contains("yearly") || $0.lowercased().contains("annual") }) {
            return .yearly
        }

        // Default to monthly for any other active subscription
        return .monthly
    }

    // MARK: - Convenience Methods

    /// Set user's journal session count for targeting
    /// - Parameter count: Total completed sessions
    public func setSessionCount(_ count: Int) {
        setUserAttributes(["session_count": count])
    }

    /// Set user's streak for targeting
    /// - Parameter days: Current streak in days
    public func setStreakDays(_ days: Int) {
        setUserAttributes(["streak_days": days])
    }

    /// Set whether user has completed onboarding
    /// - Parameter completed: Onboarding completion status
    public func setOnboardingCompleted(_ completed: Bool) {
        setUserAttributes(["onboarding_completed": completed])
    }
}

// MARK: - Superwall Delegate Handler

/// Separate class to handle Superwall delegate callbacks
/// This avoids making SuperwallService inherit from NSObject
private final class SuperwallDelegateHandler: SuperwallDelegate {
    weak var service: SuperwallService?

    init(service: SuperwallService) {
        self.service = service
    }

    func subscriptionStatusDidChange(
        from oldValue: SuperwallKit.SubscriptionStatus,
        to newValue: SuperwallKit.SubscriptionStatus
    ) {
        // Update our service's status when Superwall's status changes
        service?.syncSubscriptionStatus()

        #if DEBUG
        print("[Superwall] Subscription status changed: \(oldValue) -> \(newValue)")
        #endif
    }

    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        // Log events for analytics if needed
        #if DEBUG
        print("[Superwall] Event: \(eventInfo.event.description)")
        #endif

        // Track purchase events with AppsFlyer
        switch eventInfo.event {
        case .transactionComplete(_, let product, _, _):
            // Log purchase to AppsFlyer for attribution
            let priceDouble = NSDecimalNumber(decimal: product.price).doubleValue
            AppsFlyerService.shared.logPurchase(
                productId: product.productIdentifier,
                price: priceDouble,
                currency: product.currencyCode ?? "USD"
            )

            // Log subscription event to Firebase Analytics
            FirebaseAnalyticsService.shared.logEvent(.sessionCompleted, parameters: [
                "purchase_product": product.productIdentifier,
                "purchase_price": priceDouble
            ])

        case .subscriptionStart(let product, _):
            #if DEBUG
            print("[Superwall] Subscription started: \(product.productIdentifier)")
            #endif

        case .freeTrialStart(let product, _):
            #if DEBUG
            print("[Superwall] Free trial started: \(product.productIdentifier)")
            #endif

        case .transactionRestore(_, _):
            #if DEBUG
            print("[Superwall] Transaction restored")
            #endif
            service?.syncSubscriptionStatus()

        default:
            break
        }
    }
}
#endif
