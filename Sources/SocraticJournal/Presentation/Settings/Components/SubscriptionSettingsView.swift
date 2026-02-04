// SubscriptionSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings component for managing subscription status
public struct SubscriptionSettingsView: View {
    let subscriptionStatus: SubscriptionStatus
    let expiryDate: String?
    let isRestoring: Bool
    let onUpgradeTapped: () -> Void
    let onRestoreTapped: () -> Void
    let onManageSubscriptionTapped: () -> Void

    public init(
        subscriptionStatus: SubscriptionStatus,
        expiryDate: String?,
        isRestoring: Bool,
        onUpgradeTapped: @escaping () -> Void,
        onRestoreTapped: @escaping () -> Void,
        onManageSubscriptionTapped: @escaping () -> Void
    ) {
        self.subscriptionStatus = subscriptionStatus
        self.expiryDate = expiryDate
        self.isRestoring = isRestoring
        self.onUpgradeTapped = onUpgradeTapped
        self.onRestoreTapped = onRestoreTapped
        self.onManageSubscriptionTapped = onManageSubscriptionTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
                Text("Subscription")
                    .font(.headline)
            }

            // Status Card
            statusCard

            // Action Buttons
            actionButtons
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Status Card

    @ViewBuilder
    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Status")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    statusBadge
                }

                if subscriptionStatus.isPremium, let expiryDate = expiryDate {
                    Text("Renews \(expiryDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if case .expired = subscriptionStatus, let expiryDate = expiryDate {
                    Text("Expired \(expiryDate)")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            if subscriptionStatus.isPremium {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(subscriptionStatus.displayName)
            .font(.caption.bold())
            .foregroundStyle(badgeTextColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeBackgroundColor)
            .clipShape(Capsule())
    }

    private var badgeTextColor: Color {
        switch subscriptionStatus {
        case .free:
            return .secondary
        case .premium:
            return .white
        case .expired:
            return .white
        }
    }

    private var badgeBackgroundColor: Color {
        switch subscriptionStatus {
        case .free:
            return Color(uiColor: .tertiarySystemFill)
        case .premium:
            return .green
        case .expired:
            return .red
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !subscriptionStatus.isPremium {
                // Upgrade Button
                Button(action: onUpgradeTapped) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Upgrade to Premium")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Manage Subscription Button (for premium users)
                Button(action: onManageSubscriptionTapped) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Manage Subscription")
                    }
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(Color.accentColor)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Restore Purchases (always available)
            Button(action: onRestoreTapped) {
                HStack {
                    if isRestoring {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Restore Purchases")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .disabled(isRestoring)
        }
    }
}

// MARK: - Preview

#Preview("Free User") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .free,
            expiryDate: nil,
            isRestoring: false,
            onUpgradeTapped: {},
            onRestoreTapped: {},
            onManageSubscriptionTapped: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Premium User") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .premium(
                expiryDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
                productId: "com.StudioNext.socraticJournal.monthly"
            ),
            expiryDate: "Feb 28, 2025",
            isRestoring: false,
            onUpgradeTapped: {},
            onRestoreTapped: {},
            onManageSubscriptionTapped: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Expired User") {
    VStack {
        SubscriptionSettingsView(
            subscriptionStatus: .expired(
                lastExpiryDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                lastProductId: "com.StudioNext.socraticJournal.monthly"
            ),
            expiryDate: "Jan 21, 2025",
            isRestoring: false,
            onUpgradeTapped: {},
            onRestoreTapped: {},
            onManageSubscriptionTapped: {}
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
