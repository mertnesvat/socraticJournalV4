// OfflineSyncHandler.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Handles syncing offline-queued requests when connectivity is restored.
/// Stub implementation for the new social voice platform.
public final class OfflineSyncHandler: @unchecked Sendable {
    /// Shared instance
    public static let shared = OfflineSyncHandler()

    /// Callback to notify UI when sync completes
    public var onSyncCompleted: (() -> Void)?

    private init() {}

    /// Configure the handler (no-op for current platform)
    public func configure() {
        #if DEBUG
        print("[OfflineSyncHandler] Configured (stub)")
        #endif
    }
}
#endif
