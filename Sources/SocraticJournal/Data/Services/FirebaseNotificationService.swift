// FirebaseNotificationService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import UIKit
import FirebaseMessaging

/// Firebase Cloud Messaging notification service
/// This service handles FCM token management and remote notification registration.
/// Currently serves as a foundation for future server-side push notifications.
public final class FirebaseNotificationService: NSObject, @unchecked Sendable {
    /// Shared instance for FCM operations
    public static let shared = FirebaseNotificationService()

    /// Current FCM token (if available)
    private(set) var fcmToken: String?

    /// Callback for when FCM token is refreshed
    public var onTokenRefresh: ((String) -> Void)?

    private override init() {
        super.init()
    }

    // MARK: - Setup

    /// Configure Firebase Messaging
    /// Call this from AppDelegate or App initialization
    public func configure() {
        Messaging.messaging().delegate = self

        // Request current token
        Task {
            await refreshToken()
        }
    }

    // MARK: - Token Management

    /// Refresh the FCM token
    @MainActor
    public func refreshToken() async {
        do {
            let token = try await Messaging.messaging().token()
            self.fcmToken = token
            print("[FCM] Token: \(token)")
            onTokenRefresh?(token)
        } catch {
            print("[FCM] Error fetching token: \(error)")
        }
    }

    /// Delete the FCM token (e.g., on logout)
    public func deleteToken() async {
        do {
            try await Messaging.messaging().deleteToken()
            fcmToken = nil
            print("[FCM] Token deleted")
        } catch {
            print("[FCM] Error deleting token: \(error)")
        }
    }

    // MARK: - Topic Subscription

    /// Subscribe to a topic for targeted notifications
    /// - Parameter topic: Topic name to subscribe to
    public func subscribe(to topic: String) async {
        do {
            try await Messaging.messaging().subscribe(toTopic: topic)
            print("[FCM] Subscribed to topic: \(topic)")
        } catch {
            print("[FCM] Failed to subscribe to topic \(topic): \(error)")
        }
    }

    /// Unsubscribe from a topic
    /// - Parameter topic: Topic name to unsubscribe from
    public func unsubscribe(from topic: String) async {
        do {
            try await Messaging.messaging().unsubscribe(fromTopic: topic)
            print("[FCM] Unsubscribed from topic: \(topic)")
        } catch {
            print("[FCM] Failed to unsubscribe from topic \(topic): \(error)")
        }
    }

    // MARK: - Remote Notification Registration

    /// Register for remote notifications with APNs
    /// Call this after getting notification permission
    @MainActor
    public func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    /// Handle APNs token registration
    /// Call this from AppDelegate's didRegisterForRemoteNotificationsWithDeviceToken
    public func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
        print("[FCM] APNs token set")
    }
}

// MARK: - MessagingDelegate

extension FirebaseNotificationService: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        self.fcmToken = token
        print("[FCM] Token refreshed: \(token)")
        onTokenRefresh?(token)

        // Post notification for other parts of the app that need the token
        NotificationCenter.default.post(
            name: .fcmTokenRefreshed,
            object: nil,
            userInfo: ["token": token]
        )
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    /// Posted when FCM token is refreshed
    static let fcmTokenRefreshed = Notification.Name("com.socraticjournal.fcmTokenRefreshed")
}

// MARK: - Notification Topics

/// Predefined FCM topics for the app
public enum FCMTopic {
    /// Topic for app-wide announcements
    public static let announcements = "announcements"

    /// Topic for daily wisdom quotes
    public static let dailyWisdom = "daily_wisdom"

    /// Topic for feature updates
    public static let updates = "updates"
}
#endif
