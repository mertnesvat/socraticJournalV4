// SelfDiscoveryTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Self-Discovery tab showing feature cards for personal exploration
public struct SelfDiscoveryTabView: View {
    @State private var viewModel: SelfDiscoveryViewModel
    @State private var showingCharacterDiscovery = false
    @Environment(ThemeManager.self) private var themeManager

    private let repository: JournalRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol?
    private let notificationService: NotificationServiceProtocol?

    public init(
        viewModel: SelfDiscoveryViewModel? = nil,
        repository: JournalRepositoryProtocol? = nil,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil
    ) {
        let repo = repository ?? FirestoreJournalRepository.shared
        self.repository = repo
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        _viewModel = State(initialValue: viewModel ?? SelfDiscoveryViewModel(repository: repo))
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.large)
                .task {
                    await viewModel.loadAllData()
                }
                .fullScreenCover(isPresented: $showingCharacterDiscovery) {
                    // Reload personality state when returning
                    Task {
                        await viewModel.loadAllData()
                    }
                } content: {
                    CharacterDiscoveryView(
                        viewModel: CharacterDiscoveryViewModel(
                            repository: repository,
                            analysisService: FirebasePersonalityAnalysisService.shared
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .fullScreenCover(isPresented: $viewModel.showingLetters) {
                    // Reload letters count when returning
                    Task {
                        await viewModel.loadLettersCount()
                    }
                } content: {
                    LettersListView(
                        viewModel: LettersListViewModel(
                            repository: repository,
                            notificationService: notificationService
                        ),
                        repository: repository,
                        notificationService: notificationService,
                        settingsRepository: settingsRepository
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

                // Feature cards
                featureCardsSection
                    .padding(.horizontal)

                // Extra bottom spacing to account for tab bar
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable {
            await viewModel.loadAllData()
        }
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

    private var featureCardsSection: some View {
        VStack(spacing: 16) {
            // Personality Card - Uses DiscoveryCard component
            personalityCard

            // Letters Card - Uses DiscoveryCard component
            lettersCard

            // Other features (coming soon)
            ForEach(viewModel.features.filter { $0.id != "personality" && $0.id != "letters" }) { feature in
                DiscoveryFeatureCard(feature: feature) {
                    viewModel.selectFeature(feature)
                }
            }
        }
    }

    private var lettersCard: some View {
        DiscoveryCard(
            icon: "envelope.badge.fill",
            title: "Letters to Future Me",
            subtitle: "Write meaningful letters to your future self",
            badge: viewModel.readyLettersCount > 0 ? .count(viewModel.readyLettersCount) : nil,
            accentColor: .blue
        ) {
            viewModel.showingLetters = true
        }
    }

    private var personalityCard: some View {
        DiscoveryCard(
            icon: "brain.head.profile",
            title: "My Personality",
            subtitle: personalitySubtitle,
            badge: personalityBadge,
            accentColor: .purple,
            isLocked: viewModel.isPersonalityLocked,
            unlockProgress: viewModel.isPersonalityLocked ? viewModel.personalityProgress : nil,
            entriesRequired: viewModel.isPersonalityLocked ? viewModel.personalityEntriesRequired : nil,
            currentEntries: viewModel.isPersonalityLocked ? viewModel.totalEntries : nil
        ) {
            showingCharacterDiscovery = true
        }
    }

    private var personalitySubtitle: String {
        switch viewModel.personalityUnlockState {
        case .locked:
            return "Journal more to unlock your Big Five personality analysis"
        case .sample:
            return "Preview your personality traits - keep journaling for full insights"
        case .available:
            return "Explore your Big Five personality traits based on your reflections"
        }
    }

    private var personalityBadge: DiscoveryBadge? {
        switch viewModel.personalityUnlockState {
        case .locked:
            return nil
        case .sample:
            return .custom("Preview")
        case .available:
            return nil
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
