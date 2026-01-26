// SubscriptionSectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Subscription status and upgrade section for Settings
struct SubscriptionSectionView: View {
    @Environment(SuperwallService.self) private var subscriptionService
    @State private var isRestoring: Bool = false
    @State private var showRestoreSuccess: Bool = false
    @State private var showRestoreError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header with status badge
            HStack {
                Text("Subscription")
                    .font(.headline)

                Spacer()

                StatusBadge(status: subscriptionService.subscriptionStatus)
            }

            // Content based on subscription status
            if subscriptionService.isPro {
                proUserContent
            } else {
                freeUserContent
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert("Restore Successful", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your purchases have been restored successfully.")
        }
        .alert("Restore Failed", isPresented: $showRestoreError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Could not restore purchases. Please try again later.")
        }
    }

    // MARK: - Pro User Content

    private var proUserContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Pro status message
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)

                VStack(alignment: .leading, spacing: 2) {
                    Text("You're a Pro member!")
                        .font(.subheadline.weight(.medium))
                    Text("Thank you for supporting Socratic Journal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Subscription tier info
            if let tier = subscriptionService.subscriptionStatus.tier {
                HStack {
                    Text("Plan:")
                        .foregroundStyle(.secondary)
                    Text(tier.displayName)
                        .fontWeight(.medium)
                }
                .font(.caption)
            }

            // Manage subscription button
            Button {
                openSubscriptionManagement()
            } label: {
                Text("Manage Subscription")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    // MARK: - Free User Content

    private var freeUserContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Feature highlights
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "sparkles", text: "Unlimited journal sessions")
                FeatureRow(icon: "brain.head.profile", text: "Advanced character insights")
                FeatureRow(icon: "quote.opening", text: "Daily wisdom quotes")
                FeatureRow(icon: "square.and.arrow.up", text: "Export your journey")
            }

            // Upgrade button
            Button {
                subscriptionService.register(trigger: .settingsUpgrade)
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Pro")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Restore purchases
            Button {
                restorePurchases()
            } label: {
                if isRestoring {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Restoring...")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                } else {
                    Text("Restore Purchases")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(isRestoring)
        }
    }

    // MARK: - Actions

    private func restorePurchases() {
        isRestoring = true
        Task {
            let success = await subscriptionService.restorePurchases()
            isRestoring = false
            if success {
                showRestoreSuccess = true
            } else {
                showRestoreError = true
            }
        }
    }

    private func openSubscriptionManagement() {
        // Open App Store subscription management
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

/// Status badge showing current subscription status
private struct StatusBadge: View {
    let status: SubscriptionStatus

    var body: some View {
        Text(badgeText)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var badgeText: String {
        switch status {
        case .unknown:
            return "..."
        case .inactive:
            return "FREE"
        case .active(let tier):
            return tier.badgeText
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .unknown:
            return .secondary
        case .inactive:
            return .secondary
        case .active:
            return .white
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .unknown:
            return Color(uiColor: .tertiarySystemFill)
        case .inactive:
            return Color(uiColor: .tertiarySystemFill)
        case .active:
            return .purple
        }
    }
}

/// Feature highlight row for free user section
private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.purple)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview("Free User") {
    SubscriptionSectionView()
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .environment(SuperwallService.shared)
}
#endif
