// SessionCompleteView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Post-session results screen displaying clarity score and insights
public struct SessionCompleteView: View {
    @State private var viewModel: SessionCompleteViewModel
    @State private var showingComposeLetter: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    private let repository: JournalRepositoryProtocol

    public init(viewModel: SessionCompleteViewModel, repository: JournalRepositoryProtocol? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.repository = repository ?? InMemoryJournalRepository()
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else {
                    resultsContent
                }
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                viewModel.onBackToHome = {
                    dismiss()
                }
                viewModel.onWriteLetter = { _ in
                    showingComposeLetter = true
                }
                await viewModel.loadResults()
            }
            .fullScreenCover(isPresented: $showingComposeLetter) {
                // Dismiss session complete after letter is saved
                dismiss()
            } content: {
                ComposeLetterView(
                    viewModel: ComposeLetterViewModel(
                        sessionId: viewModel.session.id,
                        repository: repository
                    )
                )
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Calculating your clarity score...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Results Content

    private var resultsContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Congratulations header
                congratulationsHeader
                    .padding(.top, 16)

                // Clarity score display
                ClarityScoreDisplay(
                    score: viewModel.displayScore,
                    label: viewModel.scoreLabel,
                    quality: viewModel.scoreQuality,
                    animate: viewModel.showScoreAnimation
                )
                .padding(.vertical, 8)

                // Personalized message
                personalizedMessageCard

                // Score breakdown
                ScoreBreakdownView(
                    completion: viewModel.completionScore,
                    depth: viewModel.depthScore,
                    emotional: viewModel.emotionalScore,
                    animate: viewModel.showScoreAnimation
                )
                .padding(.horizontal)

                // Wisdom quote
                WisdomQuoteView(quote: viewModel.wisdomQuote)
                    .padding(.horizontal)

                // Action buttons
                ActionButtonsView(
                    onWriteLetter: { viewModel.writeLetter() },
                    onBackToHome: { viewModel.backToHome() }
                )
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Subviews

    private var congratulationsHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)

            Text("Reflection Complete")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            Text("Well done on completing your Socratic dialogue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }

    private var personalizedMessageCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.personalizedMessage)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.backToHome()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
    }
}

#Preview {
    let session = JournalSession(
        id: UUID().uuidString,
        createdAt: Date(),
        exchanges: [
            Exchange(
                question: "What's on your mind today?",
                answer: "I've been thinking about my career path and whether I'm truly following my passion or just doing what's expected of me.",
                socratesReaction: "Socrates nods slowly...",
                clarityMirror: "Your words reveal a search for meaning.",
                insightCard: "Seeking authenticity"
            ),
            Exchange(
                question: "What makes this important to you?",
                answer: "Because I feel like life is short and I don't want to spend it doing something that doesn't fulfill me deeply.",
                socratesReaction: "A knowing smile crosses Socrates' face...",
                clarityMirror: "I sense a desire for authenticity.",
                insightCard: "Living with purpose"
            ),
            Exchange(
                question: "What insight emerges?",
                answer: "I realize that I've been afraid to make changes because of what others might think, but ultimately this is my life to live.",
                socratesReaction: "Socrates leans forward with interest...",
                clarityMirror: "The vulnerability in your words is strength.",
                insightCard: "Courage to change"
            )
        ],
        isComplete: true
    )

    return SessionCompleteView(
        viewModel: SessionCompleteViewModel(
            session: session,
            clarityScoreService: MockClarityScoreService(),
            repository: InMemoryJournalRepository()
        )
    )
}
#endif
