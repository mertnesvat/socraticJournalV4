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
        VStack(spacing: 0) {
            // Status row
            statusRow

            HairlineDivider()

            // Action rows
            actionRows
        }
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }

    // MARK: - Status Row

    private var statusRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Status")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                HStack(spacing: AppSpacing.xs) {
                    Text(subscriptionStatus.displayName)
                        .font(AppTypography.headlineMedium)
                        .foregroundStyle(AppColors.textPrimary)

                    statusBadge
                }

                if subscriptionStatus.isPremium, let expiryDate = expiryDate {
                    Text("Renews \(expiryDate)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                } else if case .expired = subscriptionStatus, let expiryDate = expiryDate {
                    Text("Expired \(expiryDate)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.error)
                }
            }

            Spacer()

            if subscriptionStatus.isPremium {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(AppColors.success)
            }
        }
        .padding(AppSpacing.cardPadding)
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(subscriptionStatus.displayName)
            .font(AppTypography.badge)
            .foregroundStyle(badgeTextColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeBackgroundColor)
            .clipShape(Capsule())
    }

    private var badgeTextColor: Color {
        switch subscriptionStatus {
        case .free:
            return AppColors.textSecondary
        case .premium:
            return AppColors.textOnAccent
        case .expired:
            return AppColors.textOnAccent
        }
    }

    private var badgeBackgroundColor: Color {
        switch subscriptionStatus {
        case .free:
            return AppColors.border
        case .premium:
            return AppColors.success
        case .expired:
            return AppColors.error
        }
    }

    // MARK: - Action Rows

    private var actionRows: some View {
        VStack(spacing: 0) {
            if !subscriptionStatus.isPremium {
                // Upgrade row
                Button(action: onUpgradeTapped) {
                    HStack {
                        Text("Upgrade to Premium")
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(AppColors.accent)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .padding(.horizontal, AppSpacing.cardPadding)
                    .padding(.vertical, AppSpacing.md)
                }
                .buttonStyle(.plain)

                HairlineDivider()
            } else {
                // Manage subscription row
                Button(action: onManageSubscriptionTapped) {
                    HStack {
                        Text("Manage Subscription")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.accent)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .padding(.horizontal, AppSpacing.cardPadding)
                    .padding(.vertical, AppSpacing.md)
                }
                .buttonStyle(.plain)

                HairlineDivider()
            }

            // Restore purchases row
            Button(action: onRestoreTapped) {
                HStack {
                    if isRestoring {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Restore Purchases")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.vertical, AppSpacing.md)
            }
            .buttonStyle(.plain)
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
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
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
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
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
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
