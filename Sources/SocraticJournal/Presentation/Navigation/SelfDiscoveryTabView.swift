// SelfDiscoveryTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Self-Discovery tab containing personality analysis and character matching features
public struct SelfDiscoveryTabView: View {
    @Bindable var viewModel: SelfDiscoveryViewModel
    @State private var showingPersonalityAnalysis: Bool = false
    @State private var showingCharacterMatch: Bool = false
    @Environment(ThemeManager.self) private var themeManager

    private let repository: JournalRepositoryProtocol

    public init(
        viewModel: SelfDiscoveryViewModel,
        repository: JournalRepositoryProtocol
    ) {
        self.viewModel = viewModel
        self.repository = repository
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Self-Discovery")
                .navigationBarTitleDisplayMode(.large)
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.loadData() }
                .fullScreenCover(isPresented: $showingPersonalityAnalysis) {
                    CharacterDiscoveryView(
                        viewModel: CharacterDiscoveryViewModel(
                            repository: repository,
                            analysisService: FirebasePersonalityAnalysisService.shared
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .fullScreenCover(isPresented: $showingCharacterMatch) {
                    CharacterMatchView(
                        viewModel: CharacterMatchViewModel(
                            repository: repository,
                            functionsService: FirebaseFunctionsService.shared
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
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
                // Header
                headerSection
                    .padding(.horizontal)

                // Personality Profile Card
                personalityCard
                    .padding(.horizontal)

                // Character Match Card
                characterMatchCard
                    .padding(.horizontal)

                // Extra bottom spacing for tab bar
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explore who you are through your journal entries")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !viewModel.isUnlocked {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)

                    Text("\(viewModel.totalEntries)/5 sessions to unlock insights")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * viewModel.unlockProgress, height: 4)
                        }
                    }
                    .frame(width: 60, height: 4)
                }
                .padding(.top, 4)
            }
        }
    }

    private var personalityCard: some View {
        Button {
            showingPersonalityAnalysis = true
        } label: {
            DiscoveryFeatureCard(
                icon: "brain.head.profile",
                iconColor: .purple,
                title: "Your Personality Profile",
                subtitle: "Big Five (OCEAN) analysis based on your journal entries",
                isLocked: !viewModel.isUnlocked,
                preview: viewModel.isUnlocked ? "Tap to explore your traits" : nil
            )
        }
        .buttonStyle(.plain)
    }

    private var characterMatchCard: some View {
        Button {
            showingCharacterMatch = true
        } label: {
            DiscoveryFeatureCard(
                icon: "theatermasks.fill",
                iconColor: .blue,
                title: "Which Character Are You?",
                subtitle: "Match with characters from LOTR, Harry Potter, Star Wars",
                isLocked: !viewModel.isUnlocked,
                preview: viewModel.isUnlocked ? "Discover your fictional match" : nil
            )
        }
        .buttonStyle(.plain)
    }
}

/// Reusable card component for Self-Discovery features
struct DiscoveryFeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isLocked: Bool
    let preview: String?
    var comingSoon: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(isLocked ? 0.1 : 0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isLocked ? .secondary : iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(isLocked ? .secondary : .primary)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if comingSoon {
                        Text("Soon")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let preview = preview, !isLocked {
                    Text(preview)
                        .font(.caption)
                        .foregroundStyle(iconColor)
                        .padding(.top, 2)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    SelfDiscoveryTabView(
        viewModel: SelfDiscoveryViewModel(repository: InMemoryJournalRepository()),
        repository: InMemoryJournalRepository()
    )
    .environment(ThemeManager.shared)
}
#endif
