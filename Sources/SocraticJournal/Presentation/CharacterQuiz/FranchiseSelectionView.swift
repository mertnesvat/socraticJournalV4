// FranchiseSelectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - ViewModel

/// ViewModel for franchise selection in the character quiz
@Observable
@MainActor
public final class FranchiseSelectionViewModel {
    // MARK: - State

    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var recentExchangesCount: Int = 0
    var selectedFranchise: Franchise?

    /// Minimum number of journal exchanges required to take the quiz
    let minimumEntriesRequired: Int = 3

    /// Whether the user has enough journal entries to take the quiz
    var hasEnoughEntries: Bool {
        recentExchangesCount >= minimumEntriesRequired
    }

    /// Whether the Start Quiz button should be enabled
    var canStartQuiz: Bool {
        selectedFranchise != nil && hasEnoughEntries
    }

    /// Description of entry requirement status
    var entryStatusDescription: String {
        if recentExchangesCount == 0 {
            return "Complete at least \(minimumEntriesRequired) journal sessions to take the quiz"
        } else if recentExchangesCount < minimumEntriesRequired {
            let remaining = minimumEntriesRequired - recentExchangesCount
            return "Complete \(remaining) more session\(remaining == 1 ? "" : "s") to unlock the quiz"
        } else {
            return "\(recentExchangesCount) journal session\(recentExchangesCount == 1 ? "" : "s") will be analyzed"
        }
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    public init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    /// Loads the count of recent journal exchanges
    public func loadData() async {
        isLoading = true
        error = nil

        do {
            let stats = try await repository.getStats()
            recentExchangesCount = stats.totalEntries
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Selects a franchise for the quiz
    public func selectFranchise(_ franchise: Franchise) {
        if selectedFranchise == franchise {
            selectedFranchise = nil
        } else {
            selectedFranchise = franchise
        }
    }

    /// Returns the character count for a franchise
    public func characterCount(for franchise: Franchise) -> Int {
        FictionalCharacter.characters(for: franchise).count
    }
}

// MARK: - View

/// View for selecting a franchise before taking the character quiz
public struct FranchiseSelectionView: View {
    @State private var viewModel: FranchiseSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    public init(viewModel: FranchiseSelectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Which Character Are You?")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
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
            Text("Loading...")
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
            VStack(spacing: 24) {
                // Header section
                headerSection
                    .padding(.horizontal)

                // Franchise cards
                VStack(spacing: 12) {
                    ForEach(Franchise.allCases, id: \.self) { franchise in
                        FranchiseCard(
                            franchise: franchise,
                            characterCount: viewModel.characterCount(for: franchise),
                            isSelected: viewModel.selectedFranchise == franchise,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectFranchise(franchise)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)

                // Entry count info
                entryInfoSection
                    .padding(.horizontal)

                // Start Quiz button
                startQuizButton
                    .padding(.horizontal)

                // Bottom spacing
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Your Universe")
                .font(.headline)

            Text("Select a franchise to discover which character matches your personality based on your journal reflections.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var entryInfoSection: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.hasEnoughEntries ? "checkmark.circle.fill" : "info.circle.fill")
                .foregroundStyle(viewModel.hasEnoughEntries ? .green : .orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.entryStatusDescription)
                    .font(.subheadline)
                    .foregroundStyle(viewModel.hasEnoughEntries ? .primary : .secondary)

                if !viewModel.hasEnoughEntries {
                    Text("The more you journal, the better your character match will be.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var startQuizButton: some View {
        Button {
            // Navigation to results view will be implemented
            // when CharacterQuizResultsView is created
        } label: {
            HStack {
                Text("Start Quiz")
                    .fontWeight(.semibold)
                if viewModel.canStartQuiz {
                    Image(systemName: "arrow.right")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canStartQuiz ? Color.accentColor : Color.gray.opacity(0.3))
            .foregroundStyle(viewModel.canStartQuiz ? .white : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canStartQuiz)
    }

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
    }
}

// MARK: - Franchise Card Component

private struct FranchiseCard: View {
    let franchise: Franchise
    let characterCount: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Franchise icon
                Image(systemName: franchise.iconName)
                    .font(.title)
                    .foregroundStyle(isSelected ? .white : .accentColor)
                    .frame(width: 50, height: 50)
                    .background(
                        isSelected
                            ? Color.accentColor
                            : Color.accentColor.opacity(0.15)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Franchise info
                VStack(alignment: .leading, spacing: 4) {
                    Text(franchise.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(characterCount) characters")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.5))
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    FranchiseSelectionView(
        viewModel: FranchiseSelectionViewModel(
            repository: InMemoryJournalRepository()
        )
    )
    .environment(ThemeManager.shared)
}
#endif
