// LettersListView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen displaying all letters to future self
public struct LettersListView: View {
    @State private var viewModel: LettersListViewModel
    @State private var selectedLetter: FutureLetter?
    @State private var showingCompose: Bool = false
    @Environment(\.dismiss) private var dismiss

    private let repository: JournalRepositoryProtocol
    private let notificationService: NotificationServiceProtocol?
    private let settingsRepository: SettingsRepositoryProtocol?

    public init(
        viewModel: LettersListViewModel,
        repository: JournalRepositoryProtocol,
        notificationService: NotificationServiceProtocol? = nil,
        settingsRepository: SettingsRepositoryProtocol? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.repository = repository
        self.notificationService = notificationService
        self.settingsRepository = settingsRepository
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("My Letters")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .task { await viewModel.loadLetters() }
            .refreshable { await viewModel.refreshLetters() }
            .sheet(item: $selectedLetter) { letter in
                LetterDetailView(
                    viewModel: LetterDetailViewModel(
                        letter: letter,
                        repository: repository
                    )
                )
            }
            .fullScreenCover(isPresented: $showingCompose) {
                Task {
                    await viewModel.loadLetters()
                }
            } content: {
                ComposeLetterView(
                    viewModel: ComposeLetterViewModel(
                        repository: repository,
                        notificationService: notificationService,
                        settingsRepository: settingsRepository
                    )
                )
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.letters.isEmpty {
            loadingView
        } else if let error = viewModel.error, viewModel.letters.isEmpty {
            errorView(error)
        } else if viewModel.hasNoLetters {
            emptyStateView
        } else {
            lettersList
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading letters...")
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

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Letters Yet", systemImage: "envelope.badge.person.crop")
        } description: {
            Text("Write a letter to your future self after completing a reflection session.")
        } actions: {
            Button {
                showingCompose = true
            } label: {
                Text("Write Your First Letter")
            }
            .buttonStyle(.bordered)
        }
    }

    private var lettersList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Filter picker
                filterPicker
                    .padding(.horizontal)

                // Ready letters banner (if any)
                if viewModel.readyCount > 0 && viewModel.selectedFilter == .all {
                    readyBanner
                        .padding(.horizontal)
                }

                // Letters list
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredLetters) { letter in
                        LetterRowView(letter: letter)
                            .onTapGesture {
                                handleLetterTap(letter)
                            }
                    }
                }
                .padding(.horizontal)

                // Empty filter state
                if viewModel.filteredLetters.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: viewModel.selectedFilter.iconName)
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("No \(viewModel.selectedFilter.rawValue.lowercased()) letters")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LetterFilter.allCases) { filter in
                    filterButton(filter)
                }
            }
        }
    }

    private func filterButton(_ filter: LetterFilter) -> some View {
        let count = viewModel.filterCounts[filter] ?? 0
        let isSelected = viewModel.selectedFilter == filter

        return Button {
            viewModel.selectedFilter = filter
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.iconName)
                    .font(.caption)

                Text(filter.rawValue)
                    .font(.subheadline.weight(.medium))

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemBackground))
            .clipShape(Capsule())
        }
    }

    // MARK: - Ready Banner

    private var readyBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope.open.badge.clock")
                .font(.title2)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.readyCount) letter\(viewModel.readyCount == 1 ? "" : "s") ready to open!")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Your past self has a message for you")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            viewModel.selectedFilter = .ready
        }
    }

    // MARK: - Actions

    private func handleLetterTap(_ letter: FutureLetter) {
        // Check if letter can be opened
        if letter.status == .sealed && !letter.isReadyToOpen {
            // Show locked state (just select to show detail which will show countdown)
            selectedLetter = letter
        } else if letter.status == .sealed && letter.isReadyToOpen || letter.status == .ready {
            // Open the letter
            Task {
                await viewModel.openLetter(letter)
            }
            selectedLetter = letter
        } else {
            // Already read or archived - just show
            selectedLetter = letter
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingCompose = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.body.weight(.medium))
            }
        }
    }
}

#Preview {
    let repository = InMemoryJournalRepository()
    return LettersListView(
        viewModel: LettersListViewModel(repository: repository),
        repository: repository
    )
}
#endif
