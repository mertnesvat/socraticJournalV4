// OfflineSyncQueue.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

// MARK: - Offline Sync Queue

/// Manages offline queue for network requests.
/// Automatically syncs pending requests when connectivity is restored.
/// Stub implementation for the new social voice platform.
public final class OfflineSyncQueue: @unchecked Sendable {
    /// Shared instance for offline sync operations
    public static let shared = OfflineSyncQueue()

    /// Flag to prevent concurrent queue processing
    private var isProcessing = false

    /// Callback when queue processing starts
    public var onSyncStarted: (() -> Void)?

    /// Callback when queue processing completes
    public var onSyncCompleted: ((Int) -> Void)?

    private init() {}

    /// Configure the queue and start listening for connectivity changes.
    /// Should be called once at app launch after NetworkMonitor.startMonitoring().
    public func configure() {
        NetworkMonitor.shared.onConnectivityChanged = { [weak self] isConnected in
            if isConnected {
                Task { @MainActor in
                    await self?.processQueue()
                }
            }
        }

        #if DEBUG
        print("[OfflineSyncQueue] Configured (stub)")
        #endif
    }

    /// Check if there are pending requests
    public var hasPendingRequests: Bool {
        false
    }

    /// Get count of pending requests
    public var pendingCount: Int {
        0
    }

    // MARK: - Queue Processing

    /// Process the queue when online (no-op for current platform)
    @MainActor
    public func processQueue() async {
        guard !isProcessing else { return }
        guard NetworkMonitor.shared.isConnected else { return }

        isProcessing = true
        onSyncStarted?()

        // No-op: future implementation will sync voice answers, etc.

        isProcessing = false
        onSyncCompleted?(0)
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    /// Posted when the offline queue is updated (items added/removed)
    static let offlineQueueUpdated = Notification.Name("com.socraticjournal.offlineQueueUpdated")

    /// Posted when offline sync completes successfully
    /// userInfo contains "count" key with number of synced items
    static let offlineSyncCompleted = Notification.Name("com.socraticjournal.offlineSyncCompleted")
}
#endif
