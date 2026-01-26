// CharacterQuizView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main container view for the Character Quiz feature
/// Manages state transitions between universe selection, analysis, and results
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
            UniverseSelectionView { universe in
                Task {
                    await viewModel.selectUniverse(universe)
                }
            }

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

        case .error(let message):
            errorView(message: message)

        case .insufficientEntries(let current, let required):
            insufficientEntriesView(current: current, required: required)
        }
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
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
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
    .environment(ThemeManager())
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
