// ServiceContainer.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Dependency injection container holding all service protocol references.
/// All services use local implementations. To swap to Firebase or any backend,
/// change the initialization here — no UI changes needed.
@Observable
@MainActor
public final class ServiceContainer {
    public let settingsRepository: SettingsRepositoryProtocol
    public let subscriptionService: SubscriptionServiceProtocol
    public let analyticsService: AnalyticsServiceProtocol
    public let notificationService: NotificationServiceProtocol

    public init(
        settingsRepository: SettingsRepositoryProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository ?? UserDefaultsSettingsRepository()
        self.subscriptionService = subscriptionService ?? StoreKitSubscriptionService()
        self.analyticsService = analyticsService ?? ConsoleAnalyticsService()
        self.notificationService = notificationService ?? LocalNotificationService()
    }
}

// MARK: - Environment Key

private struct ServiceContainerKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = ServiceContainer()
}

extension EnvironmentValues {
    public var services: ServiceContainer {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}
#endif
