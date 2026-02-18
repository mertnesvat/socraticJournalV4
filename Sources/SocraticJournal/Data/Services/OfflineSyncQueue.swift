// OfflineSyncQueue.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Manages offline queue for data that needs to sync when connectivity returns
/// Currently minimal — will be expanded when Firebase backends are added
public final class OfflineSyncQueue: @unchecked Sendable {
    public static let shared = OfflineSyncQueue()

    /// Callback when sync should be attempted (connectivity restored)
    public var onSyncRequested: (() -> Void)?

    private init() {}

    /// Configure the queue to listen for connectivity changes
    public func configure() {
        NetworkMonitor.shared.onConnectivityChanged = { [weak self] isConnected in
            if isConnected {
                self?.onSyncRequested?()
            }
        }

        #if DEBUG
        print("[OfflineSyncQueue] Configured (local-first mode)")
        #endif
    }

    /// Process any pending sync operations
    @MainActor
    public func processQueue() async {
        // No-op in local-first mode
        #if DEBUG
        print("[OfflineSyncQueue] No pending sync operations in local-first mode")
        #endif
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    /// Posted when the offline queue is updated
    static let offlineQueueUpdated = Notification.Name("com.circle.offlineQueueUpdated")

    /// Posted when offline sync completes
    static let offlineSyncCompleted = Notification.Name("com.circle.offlineSyncCompleted")
}
#endif
