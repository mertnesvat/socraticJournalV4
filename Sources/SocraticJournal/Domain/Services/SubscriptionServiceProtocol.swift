// SubscriptionServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining subscription management capabilities
/// This abstraction allows swapping payment providers without changing app logic
public protocol SubscriptionServiceProtocol: AnyObject, Sendable {
    /// Current subscription status
    var subscriptionStatus: SubscriptionStatus { get }

    /// Whether the user currently has an active Pro subscription
    var isPro: Bool { get }

    /// Configure the subscription service (call once at app startup)
    func configure()

    /// Register a paywall trigger event
    /// The paywall will only be shown if configured in the Superwall dashboard
    /// - Parameter trigger: The trigger event identifier
    @MainActor
    func register(trigger: PaywallTrigger)

    /// Register a paywall trigger with a feature gate handler
    /// - Parameters:
    ///   - trigger: The trigger event identifier
    ///   - handler: Closure called when feature should be accessed (paywall dismissed with access granted)
    @MainActor
    func register(trigger: PaywallTrigger, handler: @escaping @Sendable () -> Void)

    /// Restore previous purchases
    /// - Returns: Whether restoration was successful
    @MainActor
    func restorePurchases() async -> Bool

    /// Identify user for analytics and targeting
    /// - Parameter userId: Optional user identifier (anonymous if nil)
    func identify(userId: String?)

    /// Set user attributes for paywall targeting
    /// - Parameter attributes: Dictionary of attribute key-value pairs
    func setUserAttributes(_ attributes: [String: Any])
}

/// Extension providing default implementations and convenience methods
public extension SubscriptionServiceProtocol {
    /// Convenience computed property for checking Pro status
    var isPro: Bool {
        subscriptionStatus.isPro
    }
}
