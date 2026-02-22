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
            VStack(spacing: 0) {
                // Header
                headerSection

                // Feature Grid
                featureGrid
                    .padding(.top, AppSpacing.sectionGap)

                // Product Cards
                productCardsSection
                    .padding(.top, AppSpacing.sectionGap)

                // Subscribe Button
                subscribeButton
                    .padding(.top, AppSpacing.lg)

                // Footer
                footerSection
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.sectionGap)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .background(AppColors.background)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Go Premium")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)

            Text("Unlock everything. Journal without limits.")
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Feature Grid (2x2)

    private var featureGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: AppSpacing.gridGutter),
            GridItem(.flexible(), spacing: AppSpacing.gridGutter)
        ]

        return LazyVGrid(columns: columns, spacing: AppSpacing.gridGutter) {
            GridCell(isAccented: false) {
                featureCellContent(icon: "infinity", label: "Unlimited\nSessions")
            }
            .frame(height: 100)

            GridCell(isAccented: true) {
                featureCellContent(
                    icon: "brain.head.profile",
                    label: "Deep\nInsights",
                    isAccented: true
                )
            }
            .frame(height: 100)

            GridCell(isAccented: false) {
                featureCellContent(icon: "chart.line.uptrend.xyaxis", label: "Progress\nTracking")
            }
            .frame(height: 100)

            GridCell(isAccented: false) {
                featureCellContent(icon: "person.fill.questionmark", label: "Character\nQuiz")
            }
            .frame(height: 100)
        }
    }

    private func featureCellContent(icon: String, label: String, isAccented: Bool = false) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
            Text(label)
                .font(AppTypography.caption)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(isAccented ? AppColors.textOnAccent : AppColors.textPrimary)
    }

    // MARK: - Product Cards Section

    private var productCardsSection: some View {
        VStack(spacing: AppSpacing.cardGap) {
            if let yearly = viewModel.yearlyProduct {
                productCard(
                    product: yearly,
                    isSelected: viewModel.selectedProduct?.id == yearly.id,
                    isBestValue: viewModel.yearlySavingsPercentage > 0
                ) {
                    viewModel.selectProduct(yearly)
                }
            }

            if let monthly = viewModel.monthlyProduct {
                productCard(
                    product: monthly,
                    isSelected: viewModel.selectedProduct?.id == monthly.id,
                    isBestValue: false
                ) {
                    viewModel.selectProduct(monthly)
                }
            }
        }
    }

    private func productCard(
        product: SubscriptionProduct,
        isSelected: Bool,
        isBestValue: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    HStack(spacing: AppSpacing.xs) {
                        Text(product.displayName)
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(AppColors.textPrimary)

                        if isBestValue {
                            Text("Best Value")
                                .font(AppTypography.badge)
                                .foregroundStyle(AppColors.textOnAccent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(AppColors.accent)
                                )
                        }
                    }

                    Text(product.description ?? "Full access to all features")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(AppTypography.headlineMedium)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("per \(product.period.shortName)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .padding(AppSpacing.cardPadding)
            .background(AppColors.surface)
            .overlay(
                Rectangle()
                    .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
            )
            .overlay(alignment: .leading) {
                if isSelected {
                    Rectangle()
                        .fill(AppColors.accent)
                        .frame(width: 4)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.displayName), \(product.displayPrice) per \(product.period.displayName)")
        .accessibilityHint(isBestValue ? "Best value option" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Subscribe Button

    private var subscribeButton: some View {
        Group {
            if viewModel.isPurchasing {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.textOnAccent)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule().fill(AppColors.accent.opacity(0.7))
                )
            } else {
                AccentPillButton("Subscribe Now") {
                    Task {
                        await viewModel.purchase()
                    }
                }
            }
        }
        .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)
        .opacity(viewModel.selectedProduct == nil ? 0.6 : 1.0)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Restore Purchases
            Button {
                Task {
                    await viewModel.restorePurchases()
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    if viewModel.isRestoring {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Restore Purchases")
                        .font(AppTypography.caption)
                }
            }
            .disabled(viewModel.isRestoring)
            .foregroundStyle(AppColors.textTertiary)

            // Legal Links
            HStack(spacing: AppSpacing.md) {
                Link("Terms of Service", destination: URL(string: "https://studionext.co.uk/socratic-terms.html")!)
                    .font(AppTypography.caption)

                Text("·")
                    .foregroundStyle(AppColors.textTertiary)

                Link("Privacy Policy", destination: URL(string: "https://studionext.co.uk/socratic-privacy.html")!)
                    .font(AppTypography.caption)
            }
            .foregroundStyle(AppColors.textTertiary)

            // Subscription Info
            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage your subscription in Settings.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading subscription options...")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary)

            VStack(spacing: AppSpacing.xs) {
                Text("Unable to Load")
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.errorMessage)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            AccentPillButton("Try Again") {
                Task {
                    await viewModel.loadProducts()
                }
            }
            .frame(width: 180)
        }
        .padding(AppSpacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppColors.success.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.success)
            }

            VStack(spacing: AppSpacing.xs) {
                Text("Welcome to Premium!")
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Text("You now have full access to all features")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
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
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Paywall") {
    PaywallView(
        viewModel: PaywallViewModel(
            subscriptionService: MockSubscriptionService()
        )
    )
    .environment(ThemeManager.shared)
}

#Preview("Paywall - Dark Mode") {
    PaywallView(
        viewModel: PaywallViewModel(
            subscriptionService: MockSubscriptionService()
        )
    )
    .environment(ThemeManager.shared)
    .preferredColorScheme(.dark)
}
#endif
#endif
