// NotificationSettingsViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel for the notification settings screen.
/// Manages notification permission state and per-circle mute toggles.
@Observable
@MainActor
public final class NotificationSettingsViewModel {
    // MARK: - State

    private(set) var permissionStatus: NotificationPermissionStatus = .notDetermined
    private(set) var circles: [CircleGroup] = []
    private(set) var mutedCircleIds: Set<UUID> = []
    private(set) var isLoading = false
    private(set) var error: Error?

    /// Convenience: true when the user has granted notification permission
    var notificationsEnabled: Bool {
        permissionStatus == .authorized || permissionStatus == .provisional
    }

    // MARK: - Dependencies

    private let repository: CircleRepositoryProtocol
    private let scheduler: CircleNotificationScheduler
    private let notificationService: NotificationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    private let currentUserId: UUID

    // MARK: - Init

    public init(
        repository: CircleRepositoryProtocol,
        scheduler: CircleNotificationScheduler,
        notificationService: NotificationServiceProtocol = LocalNotificationService(),
        currentUserId: UUID,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.repository = repository
        self.scheduler = scheduler
        self.notificationService = notificationService
        self.currentUserId = currentUserId
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    /// Load circles and current permission/mute state
    func load() async {
        isLoading = true
        error = nil

        do {
            circles = try await repository.fetchAll(userId: currentUserId)
        } catch {
            self.error = error
        }

        await checkPermission()

        // Populate muted set from scheduler
        mutedCircleIds = Set(circles.filter { scheduler.isCircleMuted($0.id) }.map(\.id))

        isLoading = false
    }

    /// Query the current notification authorization status
    func checkPermission() async {
        permissionStatus = await notificationService.getPermissionStatus()
    }

    /// Request notification permission from the system
    func requestPermission() async {
        let granted = await notificationService.requestPermission()
        if granted {
            permissionStatus = .authorized
            analyticsService?.logEvent(.notificationPermissionGranted)
            // Schedule for all non-muted circles now that we have permission
            await scheduler.rescheduleAll(circles: circles)
        } else {
            analyticsService?.logEvent(.notificationPermissionDenied)
            await checkPermission()
        }
    }

    /// Toggle mute state for a specific circle and reschedule notifications
    func toggleCircleMute(circleId: UUID) async {
        let nowMuted = scheduler.toggleMute(circleId: circleId)

        if nowMuted {
            mutedCircleIds.insert(circleId)
            await scheduler.cancelForCircle(circleId: circleId)
        } else {
            mutedCircleIds.remove(circleId)
            if let circle = circles.first(where: { $0.id == circleId }) {
                await scheduler.scheduleForCircle(circle)
            }
        }
    }

    func clearError() {
        error = nil
    }
}
#endif
