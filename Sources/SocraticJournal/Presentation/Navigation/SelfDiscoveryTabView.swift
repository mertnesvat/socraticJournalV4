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
                if viewModel.totalEntries == 0 {
                    emptyStateView
                } else if !viewModel.isUnlocked {
                    // Progress state (1-4 entries)
                    progressHeaderView
                        .padding(.horizontal)

                    // Show cards with locked state
                    personalityCard
                        .padding(.horizontal)

                    characterMatchCard
                        .padding(.horizontal)
                } else {
                    // Unlocked state
                    Text("Explore who you are through your journal entries")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    personalityCard
                        .padding(.horizontal)

                    characterMatchCard
                        .padding(.horizontal)
                }

                // Extra bottom spacing for tab bar
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Sparkles icon
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Discover Yourself")
                .font(.title)
                .fontWeight(.bold)

            Text("Start journaling to unlock powerful insights about your personality and find your fictional character match.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Feature previews
            VStack(spacing: 16) {
                FeaturePreviewRow(
                    icon: "brain.head.profile",
                    color: .purple,
                    title: "Personality Profile",
                    description: "Big Five analysis from your entries"
                )

                FeaturePreviewRow(
                    icon: "theatermasks.fill",
                    color: .blue,
                    title: "Character Match",
                    description: "Find your LOTR, HP, or Star Wars match"
                )
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Call to action
            VStack(spacing: 8) {
                Text("Complete 5 journal sessions to unlock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { _ in
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var progressHeaderView: some View {
        VStack(spacing: 16) {
            // Progress circles
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.totalEntries ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Group {
                                if index < viewModel.totalEntries {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        )
                }
            }

            // Progress text
            VStack(spacing: 4) {
                Text("\(5 - viewModel.totalEntries) more session\(5 - viewModel.totalEntries == 1 ? "" : "s") to unlock")
                    .font(.headline)

                Text("Keep journaling to discover your personality insights")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

/// Preview row for locked features in the empty state
struct FeaturePreviewRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
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

            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
