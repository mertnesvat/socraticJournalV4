// SelfDiscoveryTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Self-Discovery tab containing personality analysis and character matching features
public struct SelfDiscoveryTabView: View {
    @State private var viewModel: SelfDiscoveryViewModel

    public init(viewModel: SelfDiscoveryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Self-Discovery")
                .navigationBarTitleDisplayMode(.large)
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
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

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Placeholder content - will be populated in Feature #2
                ContentUnavailableView(
                    "Coming Soon",
                    systemImage: "sparkles",
                    description: Text("Personality insights and character matching will appear here.")
                )

                // Extra bottom spacing for tab bar
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    SelfDiscoveryTabView(
        viewModel: SelfDiscoveryViewModel(repository: InMemoryJournalRepository())
    )
}
#endif
