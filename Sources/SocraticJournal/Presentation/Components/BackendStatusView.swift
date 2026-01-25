// BackendStatusView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A compact indicator view showing the current AI backend status
/// Only visible when status is not healthy (degraded, unavailable, or unknown)
public struct BackendStatusView: View {
    /// The current backend status to display
    let status: BackendStatus

    /// Optional action to trigger a refresh
    var onRefresh: (() async -> Void)?

    /// Initialize with a backend status
    /// - Parameters:
    ///   - status: The backend status to display
    ///   - onRefresh: Optional callback for refresh action
    public init(status: BackendStatus, onRefresh: (() async -> Void)? = nil) {
        self.status = status
        self.onRefresh = onRefresh
    }

    public var body: some View {
        // Only show when not healthy
        if status != .healthy {
            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                    .font(.caption2)
                    .foregroundColor(statusColor)

                Text(statusText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)

                if status == .unavailable, onRefresh != nil {
                    Button {
                        Task {
                            await onRefresh?()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption2)
                            .foregroundColor(statusColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.12))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(statusColor.opacity(0.3), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Status Properties

    private var statusIcon: String {
        switch status {
        case .healthy:
            return "checkmark.circle.fill"
        case .degraded:
            return "exclamationmark.triangle.fill"
        case .unavailable:
            return "wifi.slash"
        case .unknown:
            return "questionmark.circle"
        }
    }

    private var statusText: String {
        switch status {
        case .healthy:
            return "AI Ready"
        case .degraded:
            return "AI Degraded"
        case .unavailable:
            return "AI Offline"
        case .unknown:
            return "Checking..."
        }
    }

    private var statusColor: Color {
        switch status {
        case .healthy:
            return .green
        case .degraded:
            return .orange
        case .unavailable:
            return .red
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Expanded Status Banner

/// A larger banner view for showing backend status with more detail
/// Useful for settings screens or prominent placement
public struct BackendStatusBanner: View {
    let status: BackendStatus
    let lastCheckTime: Date?
    var onRefresh: (() async -> Void)?

    @State private var isRefreshing = false

    public init(
        status: BackendStatus,
        lastCheckTime: Date? = nil,
        onRefresh: (() async -> Void)? = nil
    ) {
        self.status = status
        self.lastCheckTime = lastCheckTime
        self.onRefresh = onRefresh
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.title3)
                    .foregroundColor(statusColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(statusDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let onRefresh = onRefresh {
                    Button {
                        Task {
                            isRefreshing = true
                            await onRefresh()
                            isRefreshing = false
                        }
                    } label: {
                        if isRefreshing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(statusColor)
                    .disabled(isRefreshing)
                }
            }

            if let lastCheckTime = lastCheckTime {
                Text("Last checked \(lastCheckTime, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(statusColor.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var statusIcon: String {
        switch status {
        case .healthy:
            return "checkmark.shield.fill"
        case .degraded:
            return "exclamationmark.shield.fill"
        case .unavailable:
            return "xmark.shield.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }

    private var statusTitle: String {
        switch status {
        case .healthy:
            return "AI Services Online"
        case .degraded:
            return "AI Services Degraded"
        case .unavailable:
            return "AI Services Offline"
        case .unknown:
            return "Checking Status..."
        }
    }

    private var statusDescription: String {
        switch status {
        case .healthy:
            return "All AI features are working normally"
        case .degraded:
            return "Some features may be slow or limited"
        case .unavailable:
            return "Using local fallback features"
        case .unknown:
            return "Verifying connection to AI services"
        }
    }

    private var statusColor: Color {
        switch status {
        case .healthy:
            return .green
        case .degraded:
            return .orange
        case .unavailable:
            return .red
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Preview Provider

#if DEBUG
struct BackendStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Compact indicators
            Group {
                BackendStatusView(status: .healthy)
                BackendStatusView(status: .degraded)
                BackendStatusView(status: .unavailable)
                BackendStatusView(status: .unknown)
            }

            Divider()

            // Banners
            Group {
                BackendStatusBanner(status: .healthy, lastCheckTime: Date())
                BackendStatusBanner(status: .degraded, lastCheckTime: Date().addingTimeInterval(-300))
                BackendStatusBanner(status: .unavailable, lastCheckTime: Date().addingTimeInterval(-600)) {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
                BackendStatusBanner(status: .unknown)
            }
        }
        .padding()
    }
}
#endif
#endif
