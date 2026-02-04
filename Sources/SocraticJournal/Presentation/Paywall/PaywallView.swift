// PaywallView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Custom paywall view for subscription management
/// Presents subscription options with app-matching design
public struct PaywallView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - State

    @State private var viewModel: PaywallViewModel

    // MARK: - Initialization

    public init(
        subscriptionService: SubscriptionServiceProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        _viewModel = State(initialValue: PaywallViewModel(
            subscriptionService: subscriptionService,
            analyticsService: analyticsService
        ))
    }

    // For testing/preview
    init(viewModel: PaywallViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityLabel("Close")
                    }
                }
        }
        .task {
            await viewModel.loadProducts()
        }
        .onChange(of: viewModel.purchaseSucceeded) { _, succeeded in
            if succeeded {
                dismiss()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingProducts {
            loadingView
        } else if viewModel.error != nil && viewModel.products.isEmpty {
            errorView
        } else {
            paywallContent
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading subscription options...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Unable to Load")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(viewModel.errorMessage ?? "Please check your connection and try again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await viewModel.loadProducts()
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Paywall Content

    private var paywallContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Feature list
                featureListSection

                // Product cards
                productCardsSection

                // Subscribe button
                subscribeButtonSection

                // Restore purchases
                restorePurchasesSection

                // Legal links
                legalLinksSection

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // App icon representation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            .shadow(color: .accentColor.opacity(0.3), radius: 12, x: 0, y: 6)

            VStack(spacing: 4) {
                Text("Unlock Premium")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Deepen your self-reflection journey")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Feature List

    private var featureListSection: some View {
        VStack(spacing: 12) {
            FeatureRow(
                icon: "sparkles",
                title: "Unlimited Sessions",
                description: "Journal as often as you like"
            )
            FeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Advanced Insights",
                description: "Deep analysis of your patterns"
            )
            FeatureRow(
                icon: "person.fill.questionmark",
                title: "Character Discovery",
                description: "Discover your inner traits"
            )
            FeatureRow(
                icon: "envelope.fill",
                title: "Future Letters",
                description: "Write to your future self"
            )
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Product Cards

    private var productCardsSection: some View {
        VStack(spacing: 12) {
            if let yearly = viewModel.yearlyProduct {
                ProductCard(
                    product: yearly,
                    isSelected: viewModel.selectedProduct?.id == yearly.id,
                    savingsPercentage: viewModel.yearlySavingsPercentage,
                    isBestValue: true
                ) {
                    viewModel.selectProduct(yearly)
                }
            }

            if let monthly = viewModel.monthlyProduct {
                ProductCard(
                    product: monthly,
                    isSelected: viewModel.selectedProduct?.id == monthly.id,
                    savingsPercentage: nil,
                    isBestValue: false
                ) {
                    viewModel.selectProduct(monthly)
                }
            }
        }
    }

    // MARK: - Subscribe Button

    private var subscribeButtonSection: some View {
        Button {
            Task {
                await viewModel.purchase()
            }
        } label: {
            HStack(spacing: 12) {
                if viewModel.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Subscribe Now")
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)
        .opacity(viewModel.selectedProduct == nil ? 0.6 : 1.0)
        .accessibilityLabel("Subscribe to \(viewModel.selectedProduct?.displayName ?? "Premium")")
    }

    // MARK: - Restore Purchases

    private var restorePurchasesSection: some View {
        Button {
            Task {
                await viewModel.restorePurchases()
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isRestoring {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                Text("Restore Purchases")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
        }
        .disabled(viewModel.isRestoring)
        .accessibilityLabel("Restore previous purchases")
    }

    // MARK: - Legal Links

    private var legalLinksSection: some View {
        HStack(spacing: 16) {
            Link("Terms of Service", destination: URL(string: "https://socraticjournal.app/terms")!)
            Text("•")
                .foregroundStyle(.tertiary)
            Link("Privacy Policy", destination: URL(string: "https://socraticjournal.app/privacy")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Feature Row Component

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(description)")
    }
}

// MARK: - Product Card Component

private struct ProductCard: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let savingsPercentage: Int?
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 14, height: 14)
                    }
                }

                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if isBestValue {
                            Text("Best Value")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                    }

                    if let savings = savingsPercentage, savings > 0 {
                        Text("Save \(savings)%")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(product.period.shortName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentColor : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.displayName), \(product.displayPrice) \(product.period.shortName)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Previews

#Preview("Loading") {
    PaywallView(
        subscriptionService: PreviewSubscriptionService(loadingDelay: 10)
    )
}

#Preview("With Products") {
    PaywallView(
        subscriptionService: PreviewSubscriptionService()
    )
}

#Preview("Dark Mode") {
    PaywallView(
        subscriptionService: PreviewSubscriptionService()
    )
    .preferredColorScheme(.dark)
}

// MARK: - Preview Helper

private final class PreviewSubscriptionService: SubscriptionServiceProtocol, @unchecked Sendable {
    var statusStream: AsyncStream<SubscriptionStatus> {
        AsyncStream { continuation in
            continuation.yield(.free)
        }
    }

    private let loadingDelay: TimeInterval

    init(loadingDelay: TimeInterval = 0.5) {
        self.loadingDelay = loadingDelay
    }

    func fetchProducts() async throws -> [SubscriptionProduct] {
        try await Task.sleep(nanoseconds: UInt64(loadingDelay * 1_000_000_000))
        return [
            SubscriptionProduct(
                id: "monthly",
                displayName: "Monthly Premium",
                displayPrice: "$4.99",
                period: .monthly,
                priceValue: 4.99
            ),
            SubscriptionProduct(
                id: "yearly",
                displayName: "Yearly Premium",
                displayPrice: "$29.99",
                period: .yearly,
                priceValue: 29.99
            )
        ]
    }

    func purchase(_ product: SubscriptionProduct) async throws -> SubscriptionStatus {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        return .premium(expiryDate: Date().addingTimeInterval(31536000), productId: product.id)
    }

    func restorePurchases() async throws -> SubscriptionStatus {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return .free
    }

    func currentStatus() async -> SubscriptionStatus {
        .free
    }
}
#endif
