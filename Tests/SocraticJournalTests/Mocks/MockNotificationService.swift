// MockNotificationService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock notification service for testing
public final class MockNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    // MARK: - Configuration

    public var permissionStatus: NotificationPermissionStatus = .notDetermined
    public var permissionGranted: Bool = true
    public var shouldFail: Bool = false
    public var failError: Error = NSError(domain: "MockError", code: -1)

    // MARK: - Call Tracking

    public private(set) var requestPermissionCalled: Bool = false
    public private(set) var getPermissionStatusCalled: Bool = false
    public private(set) var scheduleDailyReminderCalled: Bool = false
    public private(set) var scheduledHour: Int?
    public private(set) var scheduledMinute: Int?
    public private(set) var cancelDailyReminderCalled: Bool = false
    public private(set) var removeAllPendingCalled: Bool = false

    // MARK: - Init

    public init() {}

    // MARK: - Protocol Methods

    public func requestPermission() async -> Bool {
        requestPermissionCalled = true
        return permissionGranted
    }

    public func getPermissionStatus() async -> NotificationPermissionStatus {
        getPermissionStatusCalled = true
        return permissionStatus
    }

    public func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        scheduleDailyReminderCalled = true
        scheduledHour = hour
        scheduledMinute = minute

        if shouldFail { throw failError }
    }

    public func cancelDailyReminder() async {
        cancelDailyReminderCalled = true
    }

    public func removeAllPendingNotifications() async {
        removeAllPendingCalled = true
    }

    // MARK: - Test Helpers

    public func reset() {
        permissionStatus = .notDetermined
        permissionGranted = true
        shouldFail = false
        requestPermissionCalled = false
        getPermissionStatusCalled = false
        scheduleDailyReminderCalled = false
        scheduledHour = nil
        scheduledMinute = nil
        cancelDailyReminderCalled = false
        removeAllPendingCalled = false
    }
}
