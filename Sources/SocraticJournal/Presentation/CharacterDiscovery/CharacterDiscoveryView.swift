// CharacterDiscoveryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main view for the Character Discovery (Personality Analysis) feature
public struct CharacterDiscoveryView: View {
    @State private var viewModel: CharacterDiscoveryViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: CharacterDiscoveryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Character Discovery")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
                .sheet(isPresented: $viewModel.showingTraitDetail) {
                    if let trait = viewModel.selectedTrait {
                        TraitCardView(
                            trait: trait,
                            onDismiss: { viewModel.dismissTraitDetail() }
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.error {
            errorView(error)
        } else {
            mainContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing your journey...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Unable to Load",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress/Unlock Section
                ProgressUnlockView(
                    unlockState: viewModel.unlockState,
                    totalEntries: viewModel.totalEntries
                )
                .padding(.horizontal)

                // Profile content based on unlock state
                switch viewModel.unlockState {
                case .locked:
                    lockedContent
                        .padding(.horizontal)

                case .sample, .available:
                    if let profile = viewModel.profile {
                        profileContent(profile)
                    }
                }

                // Bottom spacing
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var lockedContent: some View {
        VStack(spacing: 24) {
            // Preview of what's coming
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.secondary)
                    Text("Coming Soon")
                        .font(.headline)
                }

                Text("Character Discovery uses AI to analyze your journal entries and build a comprehensive personality profile based on the Big Five (OCEAN) model.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)

                // Trait previews
                VStack(alignment: .leading, spacing: 12) {
                    Text("You'll discover:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ForEach(TraitType.allCases, id: \.self) { trait in
                        HStack(spacing: 8) {
                            Text(trait.emoji)
                            Text(trait.displayName)
                                .font(.subheadline)
                            Spacer()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Encouragement
            VStack(spacing: 12) {
                Image(systemName: "pencil.and.outline")
                    .font(.largeTitle)
                    .foregroundStyle(.accentColor)

                Text("Start a new journal session to unlock your personality insights")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func profileContent(_ profile: BigFiveProfile) -> some View {
        VStack(spacing: 20) {
            // Sample disclaimer banner
            if viewModel.showSampleDisclaimer {
                sampleBanner
                    .padding(.horizontal)
            }

            // Trait Chart
            TraitChartView(
                profile: profile,
                onTraitTap: { trait in
                    viewModel.selectTrait(trait)
                }
            )
            .padding(.horizontal)

            // Summary Narrative
            SummaryNarrativeView(
                summary: profile.summary,
                analyzedAt: profile.analyzedAt,
                isSample: viewModel.showSampleDisclaimer,
                canRefresh: viewModel.canRefresh,
                isRefreshing: viewModel.isRefreshing,
                onRefresh: {
                    Task {
                        await viewModel.refreshAnalysis()
                    }
                }
            )
            .padding(.horizontal)

            // Individual Trait Cards (quick access)
            VStack(alignment: .leading, spacing: 12) {
                Text("Explore Your Traits")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(profile.allTraits, id: \.type) { trait in
                            traitQuickCard(trait)
                                .onTapGesture {
                                    viewModel.selectTrait(trait)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var sampleBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "eye.fill")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Preview Mode")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("This is sample data. Keep journaling for personalized insights.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func traitQuickCard(_ trait: PersonalityTrait) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trait.emoji)
                    .font(.title2)
                Spacer()
                Text("\(trait.score)")
                    .font(.headline)
                    .foregroundStyle(scoreColor(for: trait.score))
            }

            Text(trait.type.shortName)
                .font(.caption)
                .fontWeight(.medium)

            Text(trait.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 100)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 0..<40: return .red.opacity(0.8)
        case 40..<60: return .orange
        default: return .green
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.canRefresh && !viewModel.isRefreshing {
                Button {
                    Task {
                        await viewModel.refreshAnalysis()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

#Preview {
    CharacterDiscoveryView(
        viewModel: CharacterDiscoveryViewModel(
            repository: InMemoryJournalRepository(),
            analysisService: MockPersonalityAnalysisService()
        )
    )
}
#endif
