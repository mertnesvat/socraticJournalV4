// PaywallView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Custom paywall view for subscription purchases
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
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task {
                    viewModel.logPaywallViewed()
                    await viewModel.loadProducts()
                }
                .alert("Error", isPresented: .init(
                    get: { viewModel.hasDisplayableError },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("OK") {
                        viewModel.clearError()
                    }
                } message: {
                    Text(viewModel.errorMessage)
                }
                .onChange(of: viewModel.purchaseSucceeded) { _, succeeded in
                    if succeeded {
                        // Dismiss after a brief delay to show success state
                        Task {
                            try? await Task.sleep(for: .milliseconds(800))
                            dismiss()
                        }
                    }
                }
                .preferredColorScheme(themeManager.colorScheme)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingProducts && viewModel.products.isEmpty {
            loadingView
        } else if viewModel.products.isEmpty && viewModel.error != nil {
            errorView
        } else if viewModel.purchaseSucceeded {
            successView
        } else {
            mainContent
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Features
                featuresSection

                // Product Cards
                productCardsSection

                // Subscribe Button
                subscribeButton

                // Restore & Legal
                footerSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // App icon or branding
            ZStack {
                SwiftUI.Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }
            .shadow(color: .accentColor.opacity(0.3), radius: 12, x: 0, y: 6)

            Text("Unlock Premium")
                .font(.title.bold())
                .foregroundStyle(.primary)

            Text("Deepen your closest relationships")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(
                icon: "person.3.fill",
                title: "Unlimited Circles",
                description: "Create as many circles as you need"
            )

            FeatureRow(
                icon: "waveform",
                title: "Extended Voice Notes",
                description: "Record up to 60 seconds per response"
            )

            FeatureRow(
                icon: "sparkles",
                title: "Smart Prompts",
                description: "AI prompts that deepen over time"
            )

            FeatureRow(
                icon: "widget.small",
                title: "Home Screen Widget",
                description: "Hear your people without opening the app"
            )
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Product Cards Section

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
                    savingsPercentage: 0,
                    isBestValue: false
                ) {
                    viewModel.selectProduct(monthly)
                }
            }
        }
    }

    // MARK: - Subscribe Button

    private var subscribeButton: some View {
        Button {
            Task {
                await viewModel.purchase()
            }
        } label: {
            HStack {
                if viewModel.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Subscribe Now")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(.white)
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
        .opacity(viewModel.selectedProduct == nil ? 0.6 : 1.0)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 16) {
            // Restore Purchases
            Button {
                Task {
                    await viewModel.restorePurchases()
                }
            } label: {
                HStack {
                    if viewModel.isRestoring {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Restore Purchases")
                        .font(.subheadline)
                }
            }
            .disabled(viewModel.isRestoring)
            .foregroundStyle(.secondary)

            // Legal Links
            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://studionext.co.uk/socratic-terms.html")!)
                    .font(.caption)

                Text("•")
                    .foregroundStyle(.tertiary)

                Link("Privacy Policy", destination: URL(string: "https://studionext.co.uk/socratic-privacy.html")!)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            // Subscription Info
            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage your subscription in Settings.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
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
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Unable to Load")
                    .font(.headline)

                Text(viewModel.errorMessage)
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
                    .frame(width: 160, height: 44)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 24) {
            ZStack {
                SwiftUI.Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 8) {
                Text("Welcome to Premium!")
                    .font(.title2.bold())

                Text("You now have full access to all features")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.logPaywallDismissed()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
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
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

// MARK: - Product Card Component

private struct ProductCard: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let savingsPercentage: Int
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Best Value Badge
                if isBestValue && savingsPercentage > 0 {
                    HStack {
                        Spacer()
                        Text("SAVE \(savingsPercentage)%")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, -4)
                }

                HStack {
                    // Radio button indicator
                    ZStack {
                        SwiftUI.Circle()
                            .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isSelected {
                            SwiftUI.Circle()
                                .fill(Color.accentColor)
                                .frame(width: 14, height: 14)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(product.displayName)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            if isBestValue {
                                Text("Best Value")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color.accentColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }

                        Text(product.description ?? "Full access to premium features")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(product.displayPrice)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text("per \(product.period.shortName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentColor : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: .black.opacity(isSelected ? 0.08 : 0.03), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.displayName), \(product.displayPrice) per \(product.period.displayName)")
        .accessibilityHint(isBestValue ? "Best value option, save \(savingsPercentage) percent" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview("Paywall") {
    PaywallView(
        viewModel: PaywallViewModel(
            subscriptionService: PreviewSubscriptionService()
        )
    )
    .environment(ThemeManager.shared)
}
#endif
