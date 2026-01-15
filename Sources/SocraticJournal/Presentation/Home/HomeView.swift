// HomeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main home screen for the Socratic Journal app
public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showingNewSession: Bool = false
    @State private var showingLettersList: Bool = false
    @State private var showingCharacterDiscovery: Bool = false
    @State private var showingStatistics: Bool = false
    @State private var showingWisdomQuotes: Bool = false
    @State private var showingSettings: Bool = false
    @State private var selectedSession: JournalSession?
    private let repository: JournalRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let notificationService: NotificationServiceProtocol?

    public init(
        viewModel: HomeViewModel,
        repository: JournalRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.repository = repository
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Socratic Journal")
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.refreshData() }
                .fullScreenCover(isPresented: $showingNewSession) {
                    // Reload data when session is dismissed
                    Task {
                        await viewModel.loadData()
                    }
                } content: {
                    DialogueSessionView(
                        viewModel: DialogueSessionViewModel(
                            questionService: MockQuestionService(),
                            repository: repository
                        ),
                        repository: repository
                    )
                }
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
                }
                .fullScreenCover(isPresented: $showingCharacterDiscovery) {
                    CharacterDiscoveryView(
                        viewModel: CharacterDiscoveryViewModel(
                            repository: repository,
                            analysisService: MockPersonalityAnalysisService()
                        )
                    )
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
                }
                .fullScreenCover(isPresented: $showingStatistics) {
                    StatisticsView(
                        viewModel: StatisticsViewModel(repository: repository)
                    )
                }
                .fullScreenCover(isPresented: $showingWisdomQuotes) {
                    WisdomQuotesView(
                        viewModel: WisdomQuotesViewModel(
                            quoteService: LocalWisdomQuoteService()
                        )
                    )
                }
                .fullScreenCover(isPresented: $showingSettings) {
                    SettingsView(
                        viewModel: SettingsViewModel(
                            settingsRepository: settingsRepository,
                            journalRepository: repository,
                            notificationService: notificationService
                        )
                    )
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
                // Stats Card - Tappable to show full statistics
                Button {
                    showingStatistics = true
                } label: {
                    StatsCardView(stats: viewModel.stats)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                // Start Session Button
                StartSessionButton {
                    showingNewSession = true
                }
                .padding(.horizontal)

                // Calendar
                CalendarView(
                    stats: viewModel.stats,
                    selectedDate: viewModel.selectedDate,
                    onDateSelected: { date in
                        viewModel.selectDate(date)
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

                // Bottom spacing
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
                    showingLettersList = true
                } label: {
                    LettersBadge(count: viewModel.readyLettersCount)
                }

                Button {
                    showingStatistics = true
                } label: {
                    Image(systemName: "chart.bar.fill")
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
    return HomeView(
        viewModel: HomeViewModel(repository: repository),
        repository: repository,
        settingsRepository: settingsRepository
    )
}
#endif
