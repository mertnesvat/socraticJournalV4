// SelfDiscoveryTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Self-Discovery tab showing feature cards for personal exploration
public struct SelfDiscoveryTabView: View {
    @State private var viewModel: SelfDiscoveryViewModel

    public init(viewModel: SelfDiscoveryViewModel = SelfDiscoveryViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.features.isEmpty {
            emptyStateView
        } else {
            mainContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading discoveries...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "Coming Soon",
            systemImage: "sparkles",
            description: Text("Self-discovery features are being prepared for you.")
        )
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header section
                headerSection
                    .padding(.horizontal)

                // Feature cards grid
                featureCardsGrid
                    .padding(.horizontal)

                // Extra bottom spacing to account for tab bar
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explore Yourself")
                .font(.title2)
                .fontWeight(.bold)

            Text("Dive deeper into self-understanding through guided introspection and AI-powered insights.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var featureCardsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible())],
            spacing: 16
        ) {
            ForEach(viewModel.features) { feature in
                DiscoveryFeatureCard(feature: feature) {
                    viewModel.selectFeature(feature)
                }
            }
        }
    }
}

/// Card view for a self-discovery feature
private struct DiscoveryFeatureCard: View {
    let feature: SelfDiscoveryFeature
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: feature.icon)
                    .font(.title)
                    .foregroundStyle(feature.color)
                    .frame(width: 56, height: 56)
                    .background(feature.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(feature.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Status indicator
                if feature.isAvailable {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Soon")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .opacity(feature.isAvailable ? 1.0 : 0.8)
        .disabled(!feature.isAvailable)
        .accessibilityLabel(feature.title)
        .accessibilityHint(feature.isAvailable ? "Tap to explore" : "Coming soon")
    }
}

#Preview {
    SelfDiscoveryTabView()
}
#endif
