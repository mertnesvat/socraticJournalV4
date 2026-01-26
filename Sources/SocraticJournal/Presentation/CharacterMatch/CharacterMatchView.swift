// CharacterMatchView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// View for the "Which Character Are You?" feature
public struct CharacterMatchView: View {
    @State private var viewModel: CharacterMatchViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    public init(viewModel: CharacterMatchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Character Match")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if !viewModel.isUnlocked {
            lockedView
        } else {
            mainContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Analyzing your journal entries...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Finding your character match")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var lockedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Unlock Character Matching")
                .font(.title2)
                .fontWeight(.bold)

            Text("Complete \(5 - viewModel.totalEntries) more journal sessions to discover which fictional character you're most like.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Progress indicator
            VStack(spacing: 8) {
                ProgressView(value: viewModel.unlockProgress)
                    .tint(.orange)

                Text("\(viewModel.totalEntries)/5 sessions completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 48)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Franchise selector
                franchiseSelector
                    .padding(.horizontal)

                // Results or analyze prompt
                if let result = viewModel.currentResult {
                    resultsView(result)
                } else {
                    analyzePrompt
                        .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var franchiseSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Universe")
                .font(.headline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CharacterFranchise.allCases, id: \.self) { franchise in
                        FranchiseChip(
                            franchise: franchise,
                            isSelected: viewModel.selectedFranchise == franchise,
                            onTap: {
                                viewModel.selectFranchise(franchise)
                            }
                        )
                    }
                }
            }
        }
    }

    private var analyzePrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(franchiseColor)

            Text("Ready to find your match?")
                .font(.title3)
                .fontWeight(.semibold)

            Text("We'll analyze your journal entries to find which \(viewModel.selectedFranchise.displayName) character you're most like.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.analyzeCharacterMatch()
                }
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Discover My Character")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(franchiseColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isAnalyzing)

            if viewModel.isAnalyzing {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Analyzing...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func resultsView(_ result: CharacterMatchResult) -> some View {
        VStack(spacing: 20) {
            // Primary match card
            if let primary = result.primaryMatch {
                PrimaryMatchCard(match: primary, franchiseColor: franchiseColor)
                    .padding(.horizontal)
            }

            // Other matches
            if result.matches.count > 1 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Other Matches")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ForEach(Array(result.matches.dropFirst()), id: \.character) { match in
                        SecondaryMatchCard(match: match)
                            .padding(.horizontal)
                    }
                }
            }

            // Refresh button
            Button {
                Task {
                    await viewModel.analyzeCharacterMatch()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Analyze Again")
                }
                .font(.subheadline)
                .foregroundStyle(franchiseColor)
            }
            .padding(.top, 8)
            .disabled(viewModel.isAnalyzing)
        }
    }

    private var franchiseColor: Color {
        switch viewModel.selectedFranchise {
        case .lordOfTheRings: return .brown
        case .harryPotter: return .purple
        case .starWars: return .yellow.opacity(0.8)
        }
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

// MARK: - Supporting Views

struct FranchiseChip: View {
    let franchise: CharacterFranchise
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: franchise.icon)
                Text(franchise.displayName)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? chipColor : Color(uiColor: .systemBackground))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var chipColor: Color {
        switch franchise {
        case .lordOfTheRings: return .brown
        case .harryPotter: return .purple
        case .starWars: return .orange
        }
    }
}

struct PrimaryMatchCard: View {
    let match: CharacterMatch
    let franchiseColor: Color

    @State private var showFullReasoning: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // Character name and confidence
            VStack(spacing: 8) {
                Text("You are most like...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(match.character)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Confidence bar
                VStack(spacing: 4) {
                    ProgressView(value: Double(match.confidence) / 100)
                        .tint(franchiseColor)

                    Text("\(match.confidence)% match")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(franchiseColor)
                }
                .padding(.horizontal, 40)
            }

            Divider()

            // Reasoning
            VStack(alignment: .leading, spacing: 8) {
                Text("Why this match?")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(match.reasoning)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(showFullReasoning ? nil : 3)

                if match.reasoning.count > 150 {
                    Button {
                        withAnimation {
                            showFullReasoning.toggle()
                        }
                    } label: {
                        Text(showFullReasoning ? "Show less" : "Read more")
                            .font(.caption)
                            .foregroundStyle(franchiseColor)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

struct SecondaryMatchCard: View {
    let match: CharacterMatch

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(match.character)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(match.confidence)%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(match.reasoning)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CharacterMatchView(
        viewModel: CharacterMatchViewModel(
            repository: InMemoryJournalRepository(),
            functionsService: FirebaseFunctionsService.shared
        )
    )
    .environment(ThemeManager.shared)
}
#endif
