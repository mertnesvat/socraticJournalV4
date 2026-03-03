// NetworkMonitor.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import Network

/// Monitors network connectivity status using NWPathMonitor
/// Thread-safe singleton that broadcasts connectivity changes
public final class NetworkMonitor: @unchecked Sendable {
    /// Shared instance for network monitoring
    public static let shared = NetworkMonitor()

    /// The underlying Network framework path monitor
    private let monitor: NWPathMonitor

    /// Dedicated queue for network monitoring callbacks
    private let queue: DispatchQueue

    /// Lock for thread-safe access to isConnected
    private let lock = NSLock()

    /// Internal storage for connection status
    private var _isConnected: Bool = true

    /// Current connectivity status (thread-safe read)
    public var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isConnected
    }

    /// Callback triggered when connectivity status changes
    /// Called on main thread for UI safety
    public var onConnectivityChanged: ((Bool) -> Void)?

    private init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "com.breathe.networkmonitor", qos: .utility)

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let isConnected = path.status == .satisfied

            // Thread-safe update
            self.lock.lock()
            let previousStatus = self._isConnected
            self._isConnected = isConnected
            self.lock.unlock()

            // Only notify if status actually changed
            if previousStatus != isConnected {
                DispatchQueue.main.async {
                    self.onConnectivityChanged?(isConnected)
                }

                #if DEBUG
                print("[NetworkMonitor] Connection status changed: \(isConnected ? "connected" : "disconnected")")
                #endif
            }
        }
    }

    /// Start monitoring network connectivity
    /// Should be called once at app launch
    public func startMonitoring() {
        monitor.start(queue: queue)

        #if DEBUG
        print("[NetworkMonitor] Started monitoring network connectivity")
        #endif
    }

    /// Stop monitoring network connectivity
    /// Call when monitoring is no longer needed
    public func stopMonitoring() {
        monitor.cancel()

        #if DEBUG
        print("[NetworkMonitor] Stopped monitoring network connectivity")
        #endif
    }

    /// Check current connectivity status synchronously
    /// Useful for quick checks before network operations
    public func checkConnection() -> Bool {
        return isConnected
    }
}
#endif
