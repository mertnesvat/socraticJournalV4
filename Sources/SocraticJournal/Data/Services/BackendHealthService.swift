// BackendHealthService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// Backend health status
public enum BackendStatus: Sendable, Equatable {
    case healthy
    case degraded
    case unavailable
    case unknown
}

/// Service for monitoring backend health
/// Currently reports healthy since all features are local-first.
/// When Firebase backends are added, this will check cloud function availability.
public final class BackendHealthService: @unchecked Sendable {
    public static let shared = BackendHealthService()

    /// Current backend status
    public private(set) var status: BackendStatus = .healthy

    /// Callback for status changes
    public var onStatusChanged: ((BackendStatus) -> Void)?

    private init() {}

    /// Start periodic health monitoring
    public func startMonitoring() {
        // Local-first mode: always healthy
        status = .healthy
        #if DEBUG
        print("[BackendHealth] Local-first mode — reporting healthy")
        #endif
    }

    /// Stop health monitoring
    public func stopMonitoring() {}

    /// Whether features should use local fallback
    public var shouldUseFallback: Bool {
        status == .unavailable || status == .unknown
    }

    /// Force a health refresh
    @MainActor
    public func forceRefresh() async {
        status = .healthy
    }

    /// Human-readable status description
    public var statusDescription: String {
        switch status {
        case .healthy: return "All features available"
        case .degraded: return "Some features may be limited"
        case .unavailable: return "Features temporarily unavailable"
        case .unknown: return "Checking availability..."
        }
    }
}

extension BackendStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .healthy: return "healthy"
        case .degraded: return "degraded"
        case .unavailable: return "unavailable"
        case .unknown: return "unknown"
        }
    }
}
#endif
