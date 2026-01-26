// CharacterQuizResultView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

// MARK: - ViewModel

/// ViewModel for the Character Quiz Results screen
/// Handles loading journal entries, analyzing character matches, and managing UI states
@Observable
@MainActor
final class CharacterQuizResultViewModel {
    // MARK: - State

    enum ViewState: Equatable {
        case loading
        case loaded(CharacterQuizResult)
        case error(String)

        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded(let lhsResult), .loaded(let rhsResult)):
                return lhsResult.id == rhsResult.id
            case (.error(let lhsMsg), .error(let rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }

    private(set) var viewState: ViewState = .loading
    private(set) var animateResults: Bool = false

    // MARK: - Dependencies

    let franchise: Franchise
    private let repository: JournalRepositoryProtocol
    private let quizService: CharacterQuizServiceProtocol

    // MARK: - Callbacks

    var onDismiss: (() -> Void)?
    var onTryAnotherFranchise: (() -> Void)?

    // MARK: - Init

    init(
        franchise: Franchise,
        repository: JournalRepositoryProtocol,
        quizService: CharacterQuizServiceProtocol
    ) {
        self.franchise = franchise
        self.repository = repository
        self.quizService = quizService
    }

    // MARK: - Computed Properties

    var result: CharacterQuizResult? {
        if case .loaded(let result) = viewState {
            return result
        }
        return nil
    }

    var isLoading: Bool {
        if case .loading = viewState {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = viewState {
            return message
        }
        return nil
    }

    // MARK: - Actions

    /// Loads journal entries and performs character analysis
    func loadAndAnalyze() async {
        viewState = .loading
        animateResults = false

        do {
            // Fetch all sessions
            let sessions = try await repository.getAllSessions()

            // Extract exchanges from completed sessions (last 10 sessions max)
            let recentSessions = sessions
                .filter { $0.isComplete && !$0.exchanges.isEmpty }
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(10)

            // Flatten exchanges from sessions
            let exchanges = recentSessions.flatMap { $0.exchanges }
                .filter { !$0.skipped && !$0.answer.isEmpty }

            // Analyze character match
            let result = try await quizService.analyzeCharacterMatch(
                entries: Array(exchanges),
                franchise: franchise
            )

            // Save the result to history
            try? await quizService.saveQuizResult(result)

            viewState = .loaded(result)

            // Trigger animation after brief delay
            try? await Task.sleep(nanoseconds: 200_000_000)
            animateResults = true

        } catch let error as CharacterQuizError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("Something went wrong. Please try again.")
        }
    }

    /// Retry the analysis
    func retry() async {
        await loadAndAnalyze()
    }

    /// Dismiss the results view
    func dismiss() {
        onDismiss?()
    }

    /// Go back to franchise selection
    func tryAnotherFranchise() {
        onTryAnotherFranchise?()
    }
}

// MARK: - Main View

/// Displays the character quiz results with top matches and explanations
struct CharacterQuizResultView: View {
    @State private var viewModel: CharacterQuizResultViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    init(viewModel: CharacterQuizResultViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Franchise-themed background
                franchiseBackground
                    .ignoresSafeArea()

                content
            }
            .navigationTitle(viewModel.franchise.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                viewModel.onDismiss = { dismiss() }
                viewModel.onTryAnotherFranchise = { dismiss() }
                await viewModel.loadAndAnalyze()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            loadingView
        case .loaded(let result):
            resultsContent(result)
        case .error(let message):
            errorView(message)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 24) {
            // Animated icon for the franchise
            Image(systemName: viewModel.franchise.iconName)
                .font(.system(size: 60))
                .foregroundStyle(franchiseAccentColor)
                .symbolEffect(.pulse.byLayer, options: .repeating)

            VStack(spacing: 8) {
                Text("Analyzing your journal entries...")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Discovering which \(viewModel.franchise.displayName) character you are")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ProgressView()
                .scaleEffect(1.2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Unable to Complete Analysis")
                    .font(.title3.weight(.semibold))

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    Task { await viewModel.retry() }
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(franchiseAccentColor)

                Button {
                    viewModel.tryAnotherFranchise()
                } label: {
                    Text("Choose Different Franchise")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Results Content

    private func resultsContent(_ result: CharacterQuizResult) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                resultsHeader

                // Top Match (Prominent)
                if let topMatch = result.topMatch {
                    TopMatchCard(
                        match: topMatch,
                        franchise: result.franchise,
                        animate: viewModel.animateResults
                    )
                    .padding(.horizontal)
                }

                // Secondary Matches
                if result.matches.count > 1 {
                    secondaryMatchesSection(Array(result.matches.dropFirst().prefix(2)))
                }

                // Footer
                footerSection(result)

                // Action Buttons
                actionButtons
                    .padding(.bottom, 32)
            }
            .padding(.top, 16)
        }
    }

    private var resultsHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(franchiseAccentColor)

            Text("Your Character Match")
                .font(.title2.weight(.bold))

            Text("Based on your journal reflections")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func secondaryMatchesSection(_ matches: [CharacterMatchEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Also Similar To")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            HStack(spacing: 12) {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                    SecondaryMatchCard(
                        match: match,
                        rank: index + 2, // 2nd and 3rd place
                        franchise: viewModel.franchise,
                        animate: viewModel.animateResults
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private func footerSection(_ result: CharacterQuizResult) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "doc.text")
                .font(.caption)
            Text(result.entriesDescription)
            Text("*")
            Text(result.formattedAnalyzedAt)
        }
        .font(.caption)
        .foregroundStyle(.tertiary)
        .padding(.top, 8)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Share button (placeholder functionality)
            Button {
                // Share functionality - placeholder
            } label: {
                Label("Share Results", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(franchiseAccentColor)

            // Try Another Franchise
            Button {
                viewModel.tryAnotherFranchise()
            } label: {
                Label("Try Another Franchise", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(franchiseAccentColor)

            // Done
            Button {
                viewModel.dismiss()
            } label: {
                Text("Done")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Franchise Theming

    private var franchiseBackground: some View {
        LinearGradient(
            colors: franchiseGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.08)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var franchiseGradientColors: [Color] {
        switch viewModel.franchise {
        case .lordOfTheRings:
            return [.green, .brown]
        case .harryPotter:
            return [.purple, .orange]
        case .starWars:
            return [.blue, .black]
        }
    }

    private var franchiseAccentColor: Color {
        switch viewModel.franchise {
        case .lordOfTheRings:
            return .green
        case .harryPotter:
            return .purple
        case .starWars:
            return .blue
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
    }
}

// MARK: - Top Match Card

/// Prominent card for the top character match
struct TopMatchCard: View {
    let match: CharacterMatchEntry
    let franchise: Franchise
    let animate: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Rank Badge
            RankBadge(rank: 1)

            // Character Name
            Text(match.character.name)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            // Confidence Circle
            ConfidenceCircle(
                percentage: match.confidencePercentage,
                size: 140,
                accentColor: franchiseColor,
                animate: animate
            )

            // Confidence Level Label
            Text(match.confidenceLevel.displayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(franchiseColor)

            // Explanation
            Text(match.explanation)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            // Character Traits
            characterTraits
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(franchiseColor.opacity(0.3), lineWidth: 2)
        )
    }

    private var characterTraits: some View {
        FlowLayout(spacing: 8) {
            ForEach(match.character.personalityTraits.prefix(4), id: \.self) { trait in
                Text(trait.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(franchiseColor.opacity(0.15))
                    .foregroundStyle(franchiseColor)
                    .clipShape(Capsule())
            }
        }
    }

    private var franchiseColor: Color {
        switch franchise {
        case .lordOfTheRings: return .green
        case .harryPotter: return .purple
        case .starWars: return .blue
        }
    }
}

// MARK: - Secondary Match Card

/// Smaller card for 2nd and 3rd place matches
struct SecondaryMatchCard: View {
    let match: CharacterMatchEntry
    let rank: Int
    let franchise: Franchise
    let animate: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Rank Badge
            RankBadge(rank: rank)
                .scaleEffect(0.8)

            // Character Name
            Text(match.character.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)

            // Confidence Circle (smaller)
            ConfidenceCircle(
                percentage: match.confidencePercentage,
                size: 80,
                accentColor: franchiseColor,
                animate: animate
            )

            // Brief explanation
            Text(match.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    private var franchiseColor: Color {
        switch franchise {
        case .lordOfTheRings: return .green
        case .harryPotter: return .purple
        case .starWars: return .blue
        }
    }
}

// MARK: - Confidence Circle

/// Circular progress indicator showing match confidence percentage
struct ConfidenceCircle: View {
    let percentage: Int
    let size: CGFloat
    let accentColor: Color
    let animate: Bool

    @State private var animatedPercentage: Int = 0

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: strokeWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Percentage text
            VStack(spacing: 2) {
                Text("\(animatedPercentage)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)

                Text("%")
                    .font(.system(size: fontSize * 0.4, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            if animate {
                startAnimation()
            } else {
                animatedPercentage = percentage
            }
        }
        .onChange(of: animate) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }

    private var progressValue: CGFloat {
        CGFloat(animatedPercentage) / 100.0
    }

    private var strokeWidth: CGFloat {
        size * 0.08
    }

    private var fontSize: CGFloat {
        size * 0.28
    }

    private func startAnimation() {
        animatedPercentage = 0

        let duration: Double = 1.2
        let steps = min(percentage, 50)
        let interval = duration / Double(steps)

        for i in 0...steps {
            let targetValue = (percentage * i) / steps
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                withAnimation(.easeOut(duration: 0.08)) {
                    animatedPercentage = targetValue
                }
            }
        }
    }
}

// MARK: - Rank Badge

/// Medal-style badge for character ranking
struct RankBadge: View {
    let rank: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(badgeColor)
                .frame(width: 36, height: 36)

            if rank == 1 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .shadow(color: badgeColor.opacity(0.4), radius: 4, y: 2)
    }

    private var badgeColor: Color {
        switch rank {
        case 1:
            return Color(red: 0.85, green: 0.65, blue: 0.13) // Gold
        case 2:
            return Color(red: 0.75, green: 0.75, blue: 0.78) // Silver
        case 3:
            return Color(red: 0.80, green: 0.50, blue: 0.20) // Bronze
        default:
            return .gray
        }
    }
}

// MARK: - Flow Layout

/// Simple flow layout for tags/traits that wraps to next line
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            ), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)

                if currentX + viewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, viewSize.height)
                currentX += viewSize.width + spacing
                size.width = max(size.width, currentX)
            }

            size.height = currentY + lineHeight
        }
    }
}

// MARK: - Preview

#Preview("Loading") {
    CharacterQuizResultView(
        viewModel: CharacterQuizResultViewModel(
            franchise: .lordOfTheRings,
            repository: InMemoryJournalRepository(),
            quizService: MockCharacterQuizService()
        )
    )
    .environment(ThemeManager.shared)
}

#Preview("Lord of the Rings") {
    let viewModel = CharacterQuizResultViewModel(
        franchise: .lordOfTheRings,
        repository: InMemoryJournalRepository(),
        quizService: MockCharacterQuizService()
    )
    return CharacterQuizResultView(viewModel: viewModel)
        .environment(ThemeManager.shared)
}

#Preview("Harry Potter") {
    let viewModel = CharacterQuizResultViewModel(
        franchise: .harryPotter,
        repository: InMemoryJournalRepository(),
        quizService: MockCharacterQuizService()
    )
    return CharacterQuizResultView(viewModel: viewModel)
        .environment(ThemeManager.shared)
}

#Preview("Star Wars") {
    let viewModel = CharacterQuizResultViewModel(
        franchise: .starWars,
        repository: InMemoryJournalRepository(),
        quizService: MockCharacterQuizService()
    )
    return CharacterQuizResultView(viewModel: viewModel)
        .environment(ThemeManager.shared)
}
#endif
