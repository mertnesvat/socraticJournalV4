// SelfDiscoveryTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Self-discovery view for personality insights and character analysis
/// Provides a dedicated space for users to explore their inner selves
public struct SelfDiscoveryTabView: View {
    private let repository: JournalRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol?
    private let characterQuizService: CharacterQuizServiceProtocol
    @State private var characterDiscoveryViewModel: CharacterDiscoveryViewModel
    @State private var readyLettersCount: Int = 0
    @State private var showingLettersList: Bool = false
    @State private var showingCharacterQuiz: Bool = false
    @State private var lastCharacterQuizResult: CharacterQuizResult?
    @State private var isInitialLoading: Bool = true
    @State private var totalJournalEntries: Int = 0
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Layout Constants
    private enum Layout {
        static let sectionSpacing: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let bottomSafeArea: CGFloat = 100
    }

    public init(
        repository: JournalRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil,
        characterQuizService: CharacterQuizServiceProtocol = FirebaseCharacterQuizService.shared
    ) {
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.characterQuizService = characterQuizService
        _characterDiscoveryViewModel = State(initialValue: CharacterDiscoveryViewModel(
            repository: repository,
            analysisService: FirebasePersonalityAnalysisService.shared
        ))
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .task {
                    await loadInitialData()
                }
                .fullScreenCover(isPresented: $showingLettersList) {
                    // Reload ready letters count when letters list is dismissed
                    Task {
                        await loadReadyLettersCount()
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
                .fullScreenCover(isPresented: $showingCharacterQuiz) {
                    // Reload last quiz result when quiz is dismissed
                    Task {
                        await loadLastCharacterQuizResult()
                    }
                } content: {
                    CharacterQuizFlowView(
                        repository: repository,
                        quizService: characterQuizService,
                        onDismiss: { result in
                            if let result = result {
                                lastCharacterQuizResult = result
                            }
                            showingCharacterQuiz = false
                        }
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
        }
    }

    // MARK: - Data Loading

    private func loadInitialData() async {
        isInitialLoading = true

        // Load all data in parallel
        async let lettersTask: () = loadReadyLettersCount()
        async let quizTask: () = loadLastCharacterQuizResult()
        async let entriesTask: () = loadTotalEntries()

        _ = await (lettersTask, quizTask, entriesTask)

        isInitialLoading = false
    }

    private func loadReadyLettersCount() async {
        do {
            readyLettersCount = try await repository.getReadyLettersCount()
        } catch {
            // Silently fail - just show 0 count
            readyLettersCount = 0
        }
    }

    private func loadLastCharacterQuizResult() async {
        // TODO: Load from repository when quiz history feature is implemented
        // For now, result is only stored in memory during session
    }

    private func loadTotalEntries() async {
        do {
            let stats = try await repository.getStats()
            totalJournalEntries = stats.totalEntries
        } catch {
            totalJournalEntries = 0
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var content: some View {
        if isInitialLoading {
            loadingView
        } else if totalJournalEntries == 0 {
            emptyStateView
        } else {
            mainScrollContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your discoveries...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                // Empty state illustration
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 120, height: 120)

                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentColor)
                    }

                    VStack(spacing: 12) {
                        Text("Begin Your Journey")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Start journaling to unlock personality insights, character quizzes, and more.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 32)

                // Feature previews
                VStack(spacing: 16) {
                    featurePreviewCard(
                        icon: "brain.head.profile",
                        iconColor: .blue,
                        title: "Personality Insights",
                        description: "Discover your Big Five personality traits through AI analysis"
                    )

                    featurePreviewCard(
                        icon: "theatermasks.fill",
                        iconColor: .indigo,
                        title: "Character Quiz",
                        description: "Find out which fictional character matches your personality"
                    )

                    featurePreviewCard(
                        icon: "envelope.fill",
                        iconColor: .purple,
                        title: "Future Letters",
                        description: "Write letters to your future self as time capsules"
                    )
                }
                .padding(.horizontal, Layout.horizontalPadding)

                Spacer(minLength: Layout.bottomSafeArea)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func featurePreviewCard(
        icon: String,
        iconColor: Color,
        title: String,
        description: String
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
    }

    private var mainScrollContent: some View {
        ScrollView {
            VStack(spacing: Layout.sectionSpacing) {
                // Section 1: Personality Insights
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        icon: "brain.head.profile",
                        title: "Personality Insights",
                        subtitle: "AI-powered analysis of your character traits",
                        iconColor: .blue
                    )

                    CharacterDiscoveryContentView(viewModel: characterDiscoveryViewModel)
                }

                // Section 2: Character Quiz
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        icon: "theatermasks.fill",
                        title: "Character Quiz",
                        subtitle: "Discover your fictional counterpart",
                        iconColor: .indigo
                    )

                    CharacterQuizSection(lastResult: lastCharacterQuizResult) {
                        showingCharacterQuiz = true
                    }
                }

                // Section 3: Future Letters
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        icon: "envelope.fill",
                        title: "Future Letters",
                        subtitle: "Messages to your future self",
                        iconColor: .purple
                    )

                    FutureLettersSection(readyCount: readyLettersCount) {
                        showingLettersList = true
                    }
                }

                // Bottom safe area padding
                Spacer(minLength: Layout.bottomSafeArea)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable {
            await characterDiscoveryViewModel.loadData()
            await loadReadyLettersCount()
            await loadLastCharacterQuizResult()
            await loadTotalEntries()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if characterDiscoveryViewModel.canRefresh && !characterDiscoveryViewModel.isRefreshing {
                Button {
                    Task {
                        await characterDiscoveryViewModel.refreshAnalysis()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            } else if characterDiscoveryViewModel.isRefreshing {
                ProgressView()
            }
        }
    }
}

#Preview {
    SelfDiscoveryTabView(
        repository: InMemoryJournalRepository(),
        settingsRepository: UserDefaultsSettingsRepository()
    )
    .environment(ThemeManager.shared)
}
#endif
