// ServiceContainer.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftData
import SwiftUI

/// Dependency injection container holding all service protocol references.
/// All services use local implementations. To swap to Firebase or any backend,
/// change the initialization here -- no UI changes needed.
@Observable
@MainActor
public final class ServiceContainer {
    public let settingsRepository: SettingsRepositoryProtocol
    public let subscriptionService: SubscriptionServiceProtocol
    public let analyticsService: AnalyticsServiceProtocol
    public let notificationService: NotificationServiceProtocol
    public let authService: AuthServiceProtocol
    public let voiceRecordingService: VoiceRecordingServiceProtocol
    public let circleService: CircleServiceProtocol

    /// The SwiftData model container shared across the app.
    public let modelContainer: ModelContainer

    public init(
        settingsRepository: SettingsRepositoryProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        authService: AuthServiceProtocol? = nil,
        voiceRecordingService: VoiceRecordingServiceProtocol? = nil,
        circleService: CircleServiceProtocol? = nil,
        modelContainer: ModelContainer? = nil
    ) {
        let container: ModelContainer
        if let modelContainer {
            container = modelContainer
        } else {
            do {
                container = try ModelContainer(
                    for: User.self, VoiceNote.self, Circle.self, CircleMember.self
                )
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
        self.modelContainer = container

        self.settingsRepository = settingsRepository ?? UserDefaultsSettingsRepository()
        self.subscriptionService = subscriptionService ?? StoreKitSubscriptionService()
        self.analyticsService = analyticsService ?? ConsoleAnalyticsService()
        self.notificationService = notificationService ?? LocalNotificationService()

        let auth = authService ?? LocalAuthService(modelContainer: container)
        self.authService = auth
        self.voiceRecordingService = voiceRecordingService ?? LocalVoiceRecordingService(modelContainer: container)
        self.circleService = circleService ?? LocalCircleService(modelContainer: container, authService: auth)
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
