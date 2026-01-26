// HomeTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Home view adapted for tab navigation
/// Session start is handled by the floating plus button in MainTabView
/// Statistics is now a separate tab - stats card tap switches to Statistics tab
public struct HomeTabView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var showingLettersList: Bool = false
    @State private var showingCharacterDiscovery: Bool = false
    @State private var showingWisdomQuotes: Bool = false
    @State private var showingSettings: Bool = false
    @State private var selectedSession: JournalSession?
    @Environment(ThemeManager.self) private var themeManager
    private let repository: JournalRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol?
    private let onStatsCardTapped: (() -> Void)?

    public init(
        viewModel: HomeViewModel,
        repository: JournalRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil,
        onStatsCardTapped: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.onStatsCardTapped = onStatsCardTapped
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Socratic")
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.refreshData() }
                .fullScreenCover(isPresented: $showingLettersList) {
                    // Reload ready letters count when letters list is dismissed
                    Task {
                        await viewModel.loadData()
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
                .fullScreenCover(isPresented: $showingCharacterDiscovery) {
                    CharacterDiscoveryView(
                        viewModel: CharacterDiscoveryViewModel(
                            repository: repository,
                            analysisService: FirebasePersonalityAnalysisService.shared
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .sheet(item: $selectedSession) { session in
                    SessionDetailView(
                        viewModel: SessionDetailViewModel(
                            session: session,
                            repository: repository
                        )
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .fullScreenCover(isPresented: $showingWisdomQuotes) {
                    WisdomQuotesView(
                        viewModel: WisdomQuotesViewModel(
                            quoteService: LocalWisdomQuoteService()
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .fullScreenCover(isPresented: $showingSettings) {
                    SettingsView(
                        viewModel: SettingsViewModel(
                            settingsRepository: settingsRepository,
                            journalRepository: repository,
                            notificationService: notificationService
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.sessions.isEmpty {
            loadingView
        } else if let error = viewModel.error, viewModel.sessions.isEmpty {
            errorView(error)
        } else {
            mainContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your journey...")
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
                // Stats Card - Tappable to switch to Statistics tab
                Button {
                    onStatsCardTapped?()
                } label: {
                    StatsCardView(stats: viewModel.stats)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Tap to view full statistics")
                .padding(.horizontal)

                // Prompt to start session when no sessions exist
                if viewModel.hasNoSessions {
                    emptyStatePrompt
                        .padding(.horizontal)
                }

                // Calendar
                CalendarView(
                    stats: viewModel.stats,
                    selectedDate: viewModel.selectedDate,
                    onDateSelected: { date in
                        viewModel.selectDate(date)
                    }
                )
                .padding(.horizontal)

                // Letters Card
                LettersCard(
                    sealedCount: viewModel.sealedLettersCount,
                    readyCount: viewModel.readyLettersCount,
                    onTap: {
                        showingLettersList = true
                    }
                )
                .padding(.horizontal)

                // Selected date indicator
                if let selectedDate = viewModel.selectedDate {
                    selectedDateHeader(selectedDate)
                }

                // Session List
                SessionListView(
                    sessions: viewModel.filteredSessions,
                    onDelete: { session in
                        Task {
                            await viewModel.deleteSession(session)
                        }
                    },
                    onSelect: { session in
                        selectedSession = session
                    }
                )

                // Empty state for selected date
                if viewModel.selectedDate != nil && viewModel.filteredSessions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("No sessions on this date")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Clear Filter") {
                            viewModel.selectDate(nil)
                        }
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }

                // Extra bottom spacing to account for tab bar
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var emptyStatePrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(Color.accentColor)

            Text("Ready to begin?")
                .font(.headline)

            Text("Tap the + button below to start your first Socratic dialogue session.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func selectedDateHeader(_ date: Date) -> some View {
        HStack {
            let formatter = DateFormatter()
            let _ = formatter.dateStyle = .medium

            Text("Sessions on \(formatter.string(from: date))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                viewModel.selectDate(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showingCharacterDiscovery = true
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title3)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                Button {
                    showingWisdomQuotes = true
                } label: {
                    Image(systemName: "quote.bubble")
                        .font(.title3)
                }

                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                }
            }
        }
    }
}

#Preview {
    let repository = InMemoryJournalRepository()
    let settingsRepository = UserDefaultsSettingsRepository()
    return HomeTabView(
        viewModel: HomeViewModel(repository: repository),
        repository: repository,
        settingsRepository: settingsRepository,
        onStatsCardTapped: { print("Stats tapped") }
    )
    .environment(ThemeManager.shared)
}
#endif
