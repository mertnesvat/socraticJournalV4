// CharacterQuizView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main container view for the Character Quiz feature
/// Manages state transitions between universe selection, analysis, results, and history
public struct CharacterQuizView: View {
    // MARK: - Properties

    @State private var viewModel: CharacterQuizViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    // MARK: - Init

    public init(viewModel: CharacterQuizViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            loadingView(message: "Loading...")

        case .selectingUniverse:
            universeSelectionWithHistory

        case .analyzing(let universe):
            analyzingView(universe: universe)

        case .results(let result, let universe):
            CharacterResultsView(
                result: result,
                universe: universe,
                onTryAgain: {
                    viewModel.tryDifferentUniverse()
                }
            )

        case .viewingHistory:
            CharacterQuizHistoryView(
                entries: viewModel.historyEntries,
                onSelectEntry: { entry in
                    viewModel.viewHistoryEntry(entry)
                },
                onToggleFavorite: { entry in
                    Task {
                        await viewModel.toggleFavorite(entry)
                    }
                },
                onDelete: { entry in
                    Task {
                        await viewModel.deleteHistoryEntry(entry)
                    }
                },
                onReanalyze: { universeId in
                    Task {
                        await viewModel.reanalyze(universeId: universeId)
                    }
                }
            )

        case .viewingHistoryDetail(let entry):
            if let universe = FictionalUniverse.allUniverses.first(where: { $0.id == entry.universeId }) {
                HistoryDetailView(
                    entry: entry,
                    universe: universe,
                    onToggleFavorite: {
                        Task {
                            await viewModel.toggleFavorite(entry)
                        }
                    },
                    onReanalyze: {
                        Task {
                            await viewModel.reanalyze(universeId: entry.universeId)
                        }
                    },
                    onBack: {
                        viewModel.backToHistory()
                    }
                )
            } else {
                errorView(message: "Unable to load universe data")
            }

        case .error(let message):
            errorView(message: message)

        case .insufficientEntries(let current, let required):
            insufficientEntriesView(current: current, required: required)
        }
    }

    // MARK: - Universe Selection with History

    private var universeSelectionWithHistory: some View {
        VStack(spacing: 0) {
            // History access bar (only show if there's history)
            if viewModel.historyCount > 0 {
                historyAccessBar
            }

            // Universe selection
            UniverseSelectionView { universe in
                Task {
                    await viewModel.selectUniverse(universe)
                }
            }
        }
    }

    private var historyAccessBar: some View {
        Button {
            viewModel.showHistory()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.body)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("My Results")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text("\(viewModel.historyCount) \(viewModel.historyCount == 1 ? "result" : "results")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.favoritesCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.favoritesCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Navigation Title

    private var navigationTitle: String {
        switch viewModel.state {
        case .selectingUniverse:
            return "Character Quiz"
        case .analyzing:
            return "Analyzing..."
        case .results:
            return "Your Match"
        case .viewingHistory:
            return "My Results"
        case .viewingHistoryDetail:
            return "Result Details"
        case .insufficientEntries:
            return "Character Quiz"
        default:
            return "Character Quiz"
        }
    }

    // MARK: - Loading View

    private func loadingView(message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Analyzing View

    private func analyzingView(universe: FictionalUniverse) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Universe icon with pulsing animation
            UniverseIcon(universe: universe, size: .extraLarge, style: .filled)
                .modifier(PulseAnimation())

            // Progress text
            VStack(spacing: 8) {
                Text("Analyzing Your Journal")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Finding your \(universe.name) character...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Activity indicator
            ProgressView()
                .scaleEffect(1.2)
                .padding(.top, 8)

            // Fun facts while waiting
            VStack(spacing: 12) {
                Text("Did you know?")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text("\(universe.name) has \(universe.characterCount) iconic characters to match with.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Something Went Wrong")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task {
                    await viewModel.retry()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Insufficient Entries View

    private func insufficientEntriesView(current: Int, required: Int) -> some View {
        VStack(spacing: 24) {
            // Lock icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
            }

            // Title and description
            VStack(spacing: 8) {
                Text("Keep Journaling!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Complete \(required - current) more journal \(required - current == 1 ? "entry" : "entries") to unlock character matching.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Progress indicator
            VStack(spacing: 8) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .tertiarySystemFill))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: geometry.size.width * (Double(current) / Double(required)))
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)

                // Progress text
                Text("\(current) of \(required) entries")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Explanation
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Why we need entries")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text("The character quiz analyzes patterns in your writing to find meaningful matches. With more journal entries, we can better understand your personality and values.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                switch viewModel.state {
                case .viewingHistory:
                    viewModel.backToQuiz()
                case .viewingHistoryDetail:
                    viewModel.backToHistory()
                default:
                    dismiss()
                }
            } label: {
                switch viewModel.state {
                case .viewingHistory, .viewingHistoryDetail:
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                default:
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                }
            }
        }

        // Favorite button when viewing history detail
        if case .viewingHistoryDetail(let entry) = viewModel.state {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.toggleFavorite(entry)
                    }
                } label: {
                    Image(systemName: entry.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(entry.isFavorite ? .yellow : .primary)
                }
            }
        }
    }
}

// MARK: - History Detail View

private struct HistoryDetailView: View {
    let entry: CharacterQuizHistoryEntry
    let universe: FictionalUniverse
    let onToggleFavorite: () -> Void
    let onReanalyze: () -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with metadata
                headerSection

                // Result view (reusing CharacterResultsView logic)
                resultContent

                // Actions
                actionsSection

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            // Favorite indicator
            if entry.isFavorite {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Favorite")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.15))
                .clipShape(Capsule())
            }

            // Date and entry count
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(entry.formattedDate)
                        .font(.caption)
                }

                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                    Text("\(entry.entryCountAtAnalysis) entries analyzed")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var resultContent: some View {
        VStack(spacing: 24) {
            // Universe badge
            UniverseBadge(universe: universe)

            // Top match card
            if let topMatch = entry.result.topMatch {
                topMatchCard(topMatch)
                    .padding(.horizontal)
            }

            // Other matches
            if entry.result.matches.count > 1 {
                otherMatchesSection
                    .padding(.horizontal)
            }

            // Analysis summary
            analysisSummarySection
                .padding(.horizontal)
        }
    }

    private func topMatchCard(_ match: CharacterMatch) -> some View {
        let character = findCharacter(for: match)

        return VStack(spacing: 16) {
            // Character avatar
            if let character = character {
                CharacterAvatar(character: character, size: .hero, style: .gradient)
            } else {
                PlaceholderAvatar(size: .hero)
            }

            // Character name
            Text(match.characterName)
                .font(.title)
                .fontWeight(.bold)

            // Confidence
            Text(match.confidencePercentage)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(confidenceColor(match.confidence))

            Text(match.confidenceLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Character description
            if let character = character {
                Text(character.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal)
            }

            // Reasoning
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundStyle(.secondary)
                    Text("Why this match?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }

                Text(match.reasoning)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .padding()
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var otherMatchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Other Matches")
                .font(.headline)

            ForEach(Array(entry.result.matches.dropFirst().prefix(2))) { match in
                otherMatchRow(match)
            }
        }
    }

    private func otherMatchRow(_ match: CharacterMatch) -> some View {
        let character = findCharacter(for: match)

        return HStack(spacing: 12) {
            if let character = character {
                CharacterAvatar(character: character, size: .medium, style: .gradient)
            } else {
                PlaceholderAvatar(size: .medium)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(match.characterName)
                    .font(.headline)

                Text(match.confidenceLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(match.confidencePercentage)
                .font(.headline)
                .foregroundStyle(confidenceColor(match.confidence))
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var analysisSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.purple)
                Text("Analysis Summary")
                    .font(.headline)
            }

            Text(entry.result.analysisSummary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Re-analyze button
            Button(action: onReanalyze) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Re-analyze with Current Entries")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Favorite button
            Button(action: onToggleFavorite) {
                HStack {
                    Image(systemName: entry.isFavorite ? "star.slash" : "star.fill")
                    Text(entry.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(entry.isFavorite ? .red : .yellow)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .gray
        }
    }

    private func findCharacter(for match: CharacterMatch) -> FictionalCharacter? {
        universe.characters.first { $0.id == match.characterId }
    }
}

// MARK: - Pulse Animation

private struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Previews

#Preview("Universe Selection") {
    CharacterQuizView(
        viewModel: CharacterQuizViewModel(
            repository: InMemoryJournalRepository(),
            quizService: MockCharacterQuizService()
        )
    )
    .environment(ThemeManager.shared)
}

#Preview("Insufficient Entries") {
    // Create a view showing insufficient entries state
    NavigationStack {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 8) {
                Text("Keep Journaling!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Complete 2 more journal entries to unlock character matching.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Character Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Analyzing") {
    NavigationStack {
        VStack(spacing: 32) {
            Spacer()

            UniverseIcon(universe: .starWars, size: .extraLarge, style: .filled)

            VStack(spacing: 8) {
                Text("Analyzing Your Journal")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Finding your Star Wars character...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView()
                .scaleEffect(1.2)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Analyzing...")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
