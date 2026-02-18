// OfflineSyncHandler.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Handles syncing locally-created data when connectivity is restored
/// Currently a stub — will be expanded when Firebase backends are added
public final class OfflineSyncHandler: @unchecked Sendable {
    public static let shared = OfflineSyncHandler()

    private init() {}

    /// Configure the handler
    /// Call at app launch after services are available
    public func configure() {
        OfflineSyncQueue.shared.onSyncRequested = { [weak self] in
            Task {
                await self?.processSync()
            }
        }

        #if DEBUG
        print("[OfflineSyncHandler] Configured (local-first mode)")
        #endif
    }

    /// Process pending sync operations
    @MainActor
    private func processSync() async {
        // No-op in local-first mode
        // When Firebase is added, this will upload pending voice notes,
        // sync circle changes, etc.
        #if DEBUG
        print("[OfflineSyncHandler] No remote sync needed in local-first mode")
        #endif
    }
}
#endif
