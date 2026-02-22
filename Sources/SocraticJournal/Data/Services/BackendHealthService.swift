// BackendHealthService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Backend health status representing Firebase Functions availability
public enum BackendStatus: Sendable, Equatable {
    case healthy
    case degraded
    case unavailable
    case unknown
}

/// Service for monitoring Firebase Functions backend health.
/// Provides periodic health checks and status callbacks for UI updates.
public final class BackendHealthService: @unchecked Sendable {
    /// Shared singleton instance
    public static let shared = BackendHealthService()

    /// The Firebase Functions service for health checks
    private let functionsService: FirebaseFunctionsService

    /// Interval between automatic health checks (5 minutes)
    private let refreshInterval: TimeInterval = 300

    /// Current backend status
    public private(set) var status: BackendStatus = .unknown

    /// Last successful health check response
    public private(set) var lastHealthCheck: HealthCheckResponse?

    /// Last check timestamp
    public private(set) var lastCheckTime: Date?

    /// Callback for status changes - called on main thread when status changes
    public var onStatusChanged: ((BackendStatus) -> Void)?

    /// Task handle for periodic refresh
    private var refreshTask: Task<Void, Never>?

    /// Lock for thread-safe status updates
    private let statusLock = NSLock()

    /// Private initializer for singleton pattern
    private init(functionsService: FirebaseFunctionsService = .shared) {
        self.functionsService = functionsService
    }

    // MARK: - Public API

    /// Check backend health immediately.
    /// Updates status and notifies observers if status changes.
    @MainActor
    public func checkHealth() async {
        do {
            let response = try await functionsService.healthCheck()

            statusLock.lock()
            lastHealthCheck = response
            lastCheckTime = Date()
            statusLock.unlock()

            let newStatus: BackendStatus = response.status == "ok" ? .healthy : .degraded
            updateStatus(newStatus)

            #if DEBUG
            print("[BackendHealth] Status: \(response.status), Version: \(response.version), Timestamp: \(response.timestamp)")
            #endif
        } catch {
            #if DEBUG
            print("[BackendHealth] Health check failed: \(error.localizedDescription)")
            #endif

            updateStatus(.unavailable)
        }
    }

    /// Start periodic health monitoring.
    /// Performs an immediate check followed by periodic checks at refreshInterval.
    public func startMonitoring() {
        #if DEBUG
        print("[BackendHealth] Starting health monitoring with \(refreshInterval)s interval")
        #endif

        // Cancel any existing monitoring task
        stopMonitoring()

        // Initial check
        Task { @MainActor in
            await checkHealth()
        }

        // Periodic refresh
        refreshTask = Task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: UInt64(refreshInterval * 1_000_000_000))
                } catch {
                    break
                }

                if !Task.isCancelled {
                    await MainActor.run {
                        Task {
                            await checkHealth()
                        }
                    }
                }
            }
        }
    }

    /// Stop periodic health monitoring
    public func stopMonitoring() {
        #if DEBUG
        print("[BackendHealth] Stopping health monitoring")
        #endif

        refreshTask?.cancel()
        refreshTask = nil
    }

    /// Whether AI features should use local fallback instead of backend.
    /// Returns true when backend is unavailable or status is unknown.
    public var shouldUseFallback: Bool {
        statusLock.lock()
        let currentStatus = status
        statusLock.unlock()
        return currentStatus == .unavailable || currentStatus == .unknown
    }

    /// Force a manual refresh of backend health.
    /// Useful for retry buttons in UI.
    @MainActor
    public func forceRefresh() async {
        #if DEBUG
        print("[BackendHealth] Force refresh requested")
        #endif
        await checkHealth()
    }

    /// Get a human-readable description of the current status
    public var statusDescription: String {
        statusLock.lock()
        let currentStatus = status
        statusLock.unlock()

        switch currentStatus {
        case .healthy:
            return "AI features are available"
        case .degraded:
            return "AI features may be slow or limited"
        case .unavailable:
            return "AI features are temporarily unavailable"
        case .unknown:
            return "Checking AI availability..."
        }
    }

    // MARK: - Private Helpers

    /// Update status and notify observers if changed
    private func updateStatus(_ newStatus: BackendStatus) {
        statusLock.lock()
        let oldStatus = status
        let didChange = oldStatus != newStatus
        if didChange {
            status = newStatus
        }
        statusLock.unlock()

        if didChange {
            #if DEBUG
            print("[BackendHealth] Status changed: \(oldStatus) -> \(newStatus)")
            #endif

            Task { @MainActor in
                onStatusChanged?(newStatus)
            }
        }
    }
}

// MARK: - BackendStatus Extensions

extension BackendStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .healthy:
            return "healthy"
        case .degraded:
            return "degraded"
        case .unavailable:
            return "unavailable"
        case .unknown:
            return "unknown"
        }
    }
}
#endif
