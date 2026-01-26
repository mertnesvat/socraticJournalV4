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
    @Environment(ThemeManager.self) private var themeManager

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
                    await loadReadyLettersCount()
                    await loadLastCharacterQuizResult()
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

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Section 1: Character Discovery (personality analysis)
                sectionHeader

                // Character Discovery Content (embedded, not modal)
                CharacterDiscoveryContentView(viewModel: characterDiscoveryViewModel)

                // Section 2: Character Quiz (NEW)
                CharacterQuizSection(lastResult: lastCharacterQuizResult) {
                    showingCharacterQuiz = true
                }

                // Section 3: Future Letters
                FutureLettersSection(readyCount: readyLettersCount) {
                    showingLettersList = true
                }

                // Extra bottom padding to account for tab bar
                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable {
            await characterDiscoveryViewModel.loadData()
            await loadReadyLettersCount()
            await loadLastCharacterQuizResult()
        }
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)

                Text("Character Discovery")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            Text("Understand your personality through AI-powered analysis of your journal entries.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
