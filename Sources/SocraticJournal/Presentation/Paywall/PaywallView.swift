// PaywallView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Custom paywall screen for subscription options
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel: PaywallViewModel

    public init(viewModel: PaywallViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Unlock Premium")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task { await viewModel.loadProducts() }
                .onChange(of: viewModel.purchaseSucceeded) { _, succeeded in
                    if succeeded {
                        dismiss()
                    }
                }
                .alert("Error", isPresented: .init(
                    get: { viewModel.error?.shouldShowToUser ?? false },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("OK") { viewModel.clearError() }
                } message: {
                    Text(viewModel.errorMessage ?? "Something went wrong")
                }
                .preferredColorScheme(themeManager.colorScheme)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingProducts {
            loadingView
        } else if viewModel.hasProducts {
            mainContent
        } else {
            errorView
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading options...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Unable to Load")
                .font(.title2.weight(.semibold))

            Text("We couldn't load subscription options. Please check your connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Try Again") {
                Task { await viewModel.loadProducts() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Features list
                featuresSection

                // Product cards
                productsSection

                // Subscribe button
                subscribeButton

                // Restore purchases
                restoreButton

                // Legal links
                legalSection

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Socratic Premium")
                .font(.title.weight(.bold))

            Text("Unlock your full journaling potential")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "infinity", title: "Unlimited Sessions", description: "Journal as much as you want")
            Divider().padding(.horizontal)
            featureRow(icon: "brain.head.profile", title: "Deep Insights", description: "AI-powered personality analysis")
            Divider().padding(.horizontal)
            featureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "Track your growth over time")
            Divider().padding(.horizontal)
            featureRow(icon: "bell.badge", title: "Smart Reminders", description: "Never miss a journaling moment")
        }
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Products Section

    private var productsSection: some View {
        VStack(spacing: 12) {
            if let yearly = viewModel.yearlyProduct {
                ProductCard(
                    product: yearly,
                    isSelected: viewModel.selectedProduct?.id == yearly.id,
                    savingsPercent: viewModel.yearlySavingsPercent,
                    onSelect: { viewModel.selectProduct(yearly) }
                )
            }

            if let monthly = viewModel.monthlyProduct {
                ProductCard(
                    product: monthly,
                    isSelected: viewModel.selectedProduct?.id == monthly.id,
                    savingsPercent: nil,
                    onSelect: { viewModel.selectProduct(monthly) }
                )
            }
        }
    }

    // MARK: - Subscribe Button

    private var subscribeButton: some View {
        Button {
            Task { await viewModel.purchase() }
        } label: {
            Group {
                if viewModel.isPurchasing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Processing...")
                    }
                } else {
                    Text("Subscribe Now")
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.accentColor, .accentColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)
        .accessibilityLabel("Subscribe to \(viewModel.selectedProduct?.displayName ?? "Premium")")
    }

    // MARK: - Restore Button

    private var restoreButton: some View {
        Button {
            Task { await viewModel.restorePurchases() }
        } label: {
            Group {
                if viewModel.isRestoring {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Restoring...")
                    }
                } else {
                    Text("Restore Purchases")
                }
            }
            .font(.subheadline)
            .foregroundStyle(Color.accentColor)
        }
        .disabled(viewModel.isRestoring)
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Terms of Service") {
                    openURL("https://studionext.co.uk/socratic-terms.html")
                }
                .font(.caption2)

                Button("Privacy Policy") {
                    openURL("https://studionext.co.uk/socratic-privacy.html")
                }
                .font(.caption2)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
    }

    // MARK: - Helpers

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Product Card

private struct ProductCard: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let savingsPercent: Int?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.period.displayName)
                            .font(.headline)

                        if let savings = savingsPercent, savings > 0 {
                            Text("Save \(savings)%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }

                    Text(billingDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3.weight(.semibold))

                    Text(pricePerMonth)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentColor : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.period.displayName), \(product.displayPrice)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var billingDescription: String {
        switch product.period {
        case .monthly:
            return "Billed monthly"
        case .yearly:
            return "Billed annually"
        }
    }

    private var pricePerMonth: String {
        switch product.period {
        case .monthly:
            return "/month"
        case .yearly:
            if let monthly = product.monthlyEquivalent {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = Locale.current
                if let formatted = formatter.string(from: monthly as NSDecimalNumber) {
                    return "\(formatted)/month"
                }
            }
            return "/year"
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallView(
        viewModel: PaywallViewModel(
            subscriptionService: MockSubscriptionService()
        )
    )
    .environment(ThemeManager.shared)
}

// MARK: - Mock Service for Preview

private final class MockSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream { _ in }
    }

    func fetchProducts() async throws -> [SubscriptionProduct] {
        [
            SubscriptionProduct(
                id: "com.StudioNext.socraticJournal.yearly",
                displayName: "Premium Yearly",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            ),
            SubscriptionProduct(
                id: "com.StudioNext.socraticJournal.monthly",
                displayName: "Premium Monthly",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            )
        ]
    }

    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        .premium(expiryDate: Date().addingTimeInterval(365 * 24 * 60 * 60), productId: product.id)
    }

    func restorePurchases() async throws -> SubscriptionStatus {
        .free
    }

    func currentStatus() async -> SubscriptionStatus {
        .free
    }
}
#endif
