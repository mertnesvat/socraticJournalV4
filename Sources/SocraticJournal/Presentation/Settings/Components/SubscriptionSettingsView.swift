// SubscriptionSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings section for subscription management
/// Shows current status and allows upgrade/restore
struct SubscriptionSettingsView: View {
    // MARK: - State

    @State private var subscriptionStatus: SubscriptionStatus = .free
    @State private var isRestoring: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showRestoreSuccess: Bool = false
    @State private var showRestoreError: Bool = false

    // MARK: - Dependencies

    private let subscriptionService: SubscriptionServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?

    // MARK: - Initialization

    init(
        subscriptionService: SubscriptionServiceProtocol = StoreKitSubscriptionService.shared,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription")
                .font(.headline)

            // Status display
            statusSection

            // Action buttons
            actionSection
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await loadStatus()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                subscriptionService: subscriptionService,
                analyticsService: analyticsService
            )
        }
        .onChange(of: showPaywall) { _, isShowing in
            if !isShowing {
                // Refresh status when paywall closes
                Task {
                    await loadStatus()
                }
            }
        }
        .alert("Restore Successful", isPresented: $showRestoreSuccess) {
            Button("OK") {}
        } message: {
            Text("Your subscription has been restored.")
        }
        .alert("No Subscription Found", isPresented: $showRestoreError) {
            Button("OK") {}
        } message: {
            Text("We couldn't find an active subscription. If you believe this is an error, please contact support.")
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusBackgroundColor)
                    .frame(width: 44, height: 44)

                Image(systemName: statusIconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(statusIconColor)
            }

            // Status text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(subscriptionStatus.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if subscriptionStatus.isPremium {
                        Text("Active")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                }

                if let expiryDate = subscriptionStatus.expiryDate {
                    Text(expiryDateText(expiryDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Action Section

    private var actionSection: some View {
        VStack(spacing: 12) {
            if subscriptionStatus.isPremium {
                // Manage subscription button (opens App Store)
                Button {
                    openSubscriptionManagement()
                } label: {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Manage Subscription")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                }
            } else {
                // Upgrade button
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Upgrade to Premium")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            // Restore purchases button (always visible)
            Button {
                Task {
                    await restorePurchases()
                }
            } label: {
                HStack(spacing: 8) {
                    if isRestoring {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Restore Purchases")
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
            .disabled(isRestoring)
        }
    }

    // MARK: - Helpers

    private var statusBackgroundColor: Color {
        switch subscriptionStatus {
        case .premium:
            return Color.green.opacity(0.15)
        case .free:
            return Color.gray.opacity(0.15)
        case .expired:
            return Color.orange.opacity(0.15)
        }
    }

    private var statusIconName: String {
        switch subscriptionStatus {
        case .premium:
            return "crown.fill"
        case .free:
            return "person.fill"
        case .expired:
            return "clock.fill"
        }
    }

    private var statusIconColor: Color {
        switch subscriptionStatus {
        case .premium:
            return .green
        case .free:
            return .gray
        case .expired:
            return .orange
        }
    }

    private func expiryDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if subscriptionStatus.isPremium {
            return "Renews \(formatter.string(from: date))"
        } else {
            return "Expired \(formatter.string(from: date))"
        }
    }

    private func loadStatus() async {
        subscriptionStatus = await subscriptionService.currentStatus()
    }

    private func restorePurchases() async {
        isRestoring = true

        do {
            let status = try await subscriptionService.restorePurchases()
            subscriptionStatus = status

            if status.isPremium {
                showRestoreSuccess = true
            } else {
                showRestoreError = true
            }
        } catch {
            showRestoreError = true
        }

        isRestoring = false
    }

    private func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview("Free User") {
    ScrollView {
        VStack {
            SubscriptionSettingsView(
                subscriptionService: PreviewSubscriptionServiceFree()
            )
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Premium User") {
    ScrollView {
        VStack {
            SubscriptionSettingsView(
                subscriptionService: PreviewSubscriptionServicePremium()
            )
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

// MARK: - Preview Helpers

private final class PreviewSubscriptionServiceFree: SubscriptionServiceProtocol, @unchecked Sendable {
    var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream { $0.yield(.free) }
    }

    func fetchProducts() async throws -> [SubscriptionProduct] { [] }
    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus { .free }
    func restorePurchases() async throws -> SubscriptionStatus { .free }
    func currentStatus() async -> SubscriptionStatus { .free }
}

private final class PreviewSubscriptionServicePremium: SubscriptionServiceProtocol, @unchecked Sendable {
    var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream {
            $0.yield(.premium(expiryDate: Date().addingTimeInterval(86400 * 30), productId: "yearly"))
        }
    }

    func fetchProducts() async throws -> [SubscriptionProduct] { [] }
    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        .premium(expiryDate: Date().addingTimeInterval(86400 * 30), productId: "yearly")
    }
    func restorePurchases() async throws -> SubscriptionStatus {
        .premium(expiryDate: Date().addingTimeInterval(86400 * 30), productId: "yearly")
    }
    func currentStatus() async -> SubscriptionStatus {
        .premium(expiryDate: Date().addingTimeInterval(86400 * 30), productId: "yearly")
    }
}
#endif
