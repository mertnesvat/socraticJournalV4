// SubscriptionSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings section for subscription management
public struct SubscriptionSettingsView: View {
    let subscriptionStatus: SubscriptionStatus
    let expiryDate: String?
    let isRestoring: Bool
    let onUpgrade: () -> Void
    let onManage: () -> Void
    let onRestore: () -> Void

    public init(
        subscriptionStatus: SubscriptionStatus,
        expiryDate: String? = nil,
        isRestoring: Bool = false,
        onUpgrade: @escaping () -> Void,
        onManage: @escaping () -> Void,
        onRestore: @escaping () -> Void
    ) {
        self.subscriptionStatus = subscriptionStatus
        self.expiryDate = expiryDate
        self.isRestoring = isRestoring
        self.onUpgrade = onUpgrade
        self.onManage = onManage
        self.onRestore = onRestore
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Text("Subscription")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                // Status row
                statusRow

                Divider()
                    .padding(.horizontal)

                // Action row
                actionRow

                Divider()
                    .padding(.horizontal)

                // Restore row
                restoreRow
            }
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Status Row

    private var statusRow: some View {
        HStack {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Status")
                        .font(.subheadline)

                    statusBadge
                }

                if let expiry = expiryDate, subscriptionStatus.isPremium {
                    Text("Renews \(expiry)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Subscription status: \(subscriptionStatus.displayName)")
    }

    private var statusIcon: String {
        switch subscriptionStatus {
        case .free:
            return "person.crop.circle"
        case .premium:
            return "star.circle.fill"
        case .expired:
            return "exclamationmark.circle"
        }
    }

    private var statusColor: Color {
        switch subscriptionStatus {
        case .free:
            return .secondary
        case .premium:
            return .accentColor
        case .expired:
            return .orange
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(subscriptionStatus.displayName)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch subscriptionStatus {
        case .free:
            return .gray
        case .premium:
            return .accentColor
        case .expired:
            return .orange
        }
    }

    // MARK: - Action Row

    @ViewBuilder
    private var actionRow: some View {
        if subscriptionStatus.isPremium {
            // Manage subscription button
            Button(action: onManage) {
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 32)

                    Text("Manage Subscription")
                        .font(.subheadline)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Manage subscription in App Store")
        } else {
            // Upgrade button
            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to Premium")
                            .font(.subheadline.weight(.medium))

                        Text("Unlock all features")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Upgrade to Premium")
        }
    }

    // MARK: - Restore Row

    private var restoreRow: some View {
        Button(action: onRestore) {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 32)

                Text("Restore Purchases")
                    .font(.subheadline)

                Spacer()

                if isRestoring {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .disabled(isRestoring)
        .accessibilityLabel("Restore previous purchases")
    }
}

// MARK: - Preview

#Preview("Free User") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .free,
            onUpgrade: {},
            onManage: {},
            onRestore: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Premium User") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .premium(expiryDate: Date().addingTimeInterval(30 * 24 * 60 * 60), productId: "yearly"),
            expiryDate: "March 4, 2026",
            onUpgrade: {},
            onManage: {},
            onRestore: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Expired") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .expired,
            onUpgrade: {},
            onManage: {},
            onRestore: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Restoring") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .free,
            isRestoring: true,
            onUpgrade: {},
            onManage: {},
            onRestore: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
