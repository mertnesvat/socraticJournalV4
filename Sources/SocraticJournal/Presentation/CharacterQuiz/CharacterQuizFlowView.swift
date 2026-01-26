// CharacterQuizFlowView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Container view that manages the Character Quiz flow
/// Handles navigation between franchise selection and quiz results
public struct CharacterQuizFlowView: View {
    private let repository: JournalRepositoryProtocol
    private let quizService: CharacterQuizServiceProtocol
    private let onDismiss: (CharacterQuizResult?) -> Void

    @State private var selectedFranchise: Franchise?
    @State private var showingResults: Bool = false
    @State private var quizResult: CharacterQuizResult?
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    public init(
        repository: JournalRepositoryProtocol,
        quizService: CharacterQuizServiceProtocol,
        onDismiss: @escaping (CharacterQuizResult?) -> Void
    ) {
        self.repository = repository
        self.quizService = quizService
        self.onDismiss = onDismiss
    }

    public var body: some View {
        CharacterQuizFranchiseSelectionWrapper(
            repository: repository,
            quizService: quizService,
            onDismiss: {
                onDismiss(nil)
            },
            onFranchiseSelected: { franchise in
                selectedFranchise = franchise
                showingResults = true
            }
        )
        .fullScreenCover(isPresented: $showingResults) {
            if let franchise = selectedFranchise {
                CharacterQuizResultsWrapper(
                    franchise: franchise,
                    repository: repository,
                    quizService: quizService,
                    onDismiss: { result in
                        quizResult = result
                        showingResults = false
                        // Dismiss the entire flow
                        onDismiss(result)
                    },
                    onTryAnotherFranchise: {
                        showingResults = false
                        selectedFranchise = nil
                    }
                )
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }
}

/// Wrapper to add navigation callbacks to FranchiseSelectionView
struct CharacterQuizFranchiseSelectionWrapper: View {
    let repository: JournalRepositoryProtocol
    let quizService: CharacterQuizServiceProtocol
    let onDismiss: () -> Void
    let onFranchiseSelected: (Franchise) -> Void

    @State private var viewModel: FranchiseSelectionViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        repository: JournalRepositoryProtocol,
        quizService: CharacterQuizServiceProtocol,
        onDismiss: @escaping () -> Void,
        onFranchiseSelected: @escaping (Franchise) -> Void
    ) {
        self.repository = repository
        self.quizService = quizService
        self.onDismiss = onDismiss
        self.onFranchiseSelected = onFranchiseSelected
        _viewModel = State(initialValue: FranchiseSelectionViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    headerSection
                        .padding(.horizontal)

                    // Franchise cards
                    VStack(spacing: 12) {
                        ForEach(Franchise.allCases, id: \.self) { franchise in
                            FranchiseCardView(
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
            .navigationTitle("Which Character Are You?")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                    }
                }
            }
            .task { await viewModel.loadData() }
        }
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
            if let franchise = viewModel.selectedFranchise {
                onFranchiseSelected(franchise)
            }
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
}

/// Franchise card for selection
struct FranchiseCardView: View {
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

/// Wrapper to add callbacks to CharacterQuizResultView
struct CharacterQuizResultsWrapper: View {
    let franchise: Franchise
    let repository: JournalRepositoryProtocol
    let quizService: CharacterQuizServiceProtocol
    let onDismiss: (CharacterQuizResult?) -> Void
    let onTryAnotherFranchise: () -> Void

    @State private var viewModel: CharacterQuizResultViewModel

    init(
        franchise: Franchise,
        repository: JournalRepositoryProtocol,
        quizService: CharacterQuizServiceProtocol,
        onDismiss: @escaping (CharacterQuizResult?) -> Void,
        onTryAnotherFranchise: @escaping () -> Void
    ) {
        self.franchise = franchise
        self.repository = repository
        self.quizService = quizService
        self.onDismiss = onDismiss
        self.onTryAnotherFranchise = onTryAnotherFranchise
        _viewModel = State(initialValue: CharacterQuizResultViewModel(
            franchise: franchise,
            repository: repository,
            quizService: quizService
        ))
    }

    var body: some View {
        CharacterQuizResultView(viewModel: viewModel)
            .onAppear {
                viewModel.onDismiss = { onDismiss(viewModel.result) }
                viewModel.onTryAnotherFranchise = onTryAnotherFranchise
            }
    }
}

#Preview {
    CharacterQuizFlowView(
        repository: InMemoryJournalRepository(),
        quizService: MockCharacterQuizService(),
        onDismiss: { result in
            print("Dismissed with result: \(String(describing: result))")
        }
    )
    .environment(ThemeManager.shared)
}
#endif
