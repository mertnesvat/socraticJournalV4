// DialogueSessionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main view for the Socratic Dialogue Session
public struct DialogueSessionView: View {
    @State private var viewModel: DialogueSessionViewModel
    @State private var showingExitConfirmation: Bool = false
    @Environment(\.dismiss) private var dismiss

    private let repository: JournalRepositoryProtocol

    public init(viewModel: DialogueSessionViewModel, repository: JournalRepositoryProtocol? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.repository = repository ?? InMemoryJournalRepository()
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    ProgressIndicator(
                        currentQuestion: viewModel.currentQuestionIndex + 1,
                        totalQuestions: DialogueSessionViewModel.totalQuestions,
                        progress: viewModel.progress
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Main content area
                    ScrollView {
                        VStack(spacing: 24) {
                            contentForPhase
                        }
                        .padding()
                    }

                    // Bottom action area
                    bottomActionArea
                }
            }
            .navigationTitle("Dialogue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .confirmationDialog(
                "Exit Session?",
                isPresented: $showingExitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard & Exit", role: .destructive) {
                    viewModel.discardAndExit()
                    dismiss()
                }
                Button("Continue Session", role: .cancel) {}
            } message: {
                Text("Your progress will be lost if you exit now.")
            }
            .fullScreenCover(isPresented: $viewModel.showSessionComplete) {
                SessionCompleteView(
                    viewModel: SessionCompleteViewModel(
                        session: viewModel.getCompletedSession(),
                        clarityScoreService: MockClarityScoreService(),
                        repository: repository
                    ),
                    repository: repository
                )
            }
            .task {
                viewModel.onExit = {
                    dismiss()
                }
                viewModel.onSessionComplete = { _ in
                    // Now handled by fullScreenCover
                }
                await viewModel.startSession()
            }
            .onChange(of: viewModel.showSessionComplete) { _, isShowing in
                if !isShowing {
                    // Session complete screen was dismissed, go back to home
                    dismiss()
                }
            }
        }
    }

    // MARK: - Content for Phase

    @ViewBuilder
    private var contentForPhase: some View {
        switch viewModel.phase {
        case .showingQuestion, .awaitingAnswer:
            questionAndAnswerContent

        case .processingAnswer:
            processingContent

        case .showingReaction:
            reactionContent

        case .showingClarityMirror:
            clarityMirrorContent

        case .showingInsightCard, .readyForNext:
            insightCardContent

        case .sessionComplete:
            // Show loading while transitioning
            VStack(spacing: 16) {
                ProgressView()
                Text("Preparing your results...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
        }
    }

    private var questionAndAnswerContent: some View {
        VStack(spacing: 24) {
            QuestionView(question: viewModel.currentQuestion)

            if viewModel.phase == .awaitingAnswer {
                AnswerInputView(
                    text: $viewModel.answerText,
                    placeholder: "Share your thoughts..."
                )
            }
        }
    }

    private var processingContent: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Socrates is reflecting...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private var reactionContent: some View {
        VStack(spacing: 24) {
            QuestionView(question: viewModel.currentQuestion)

            if !viewModel.answerText.isEmpty {
                UserAnswerCard(answer: viewModel.answerText)
            }

            SocratesReactionView(reaction: viewModel.currentReaction)
        }
    }

    private var clarityMirrorContent: some View {
        VStack(spacing: 24) {
            QuestionView(question: viewModel.currentQuestion)

            if !viewModel.answerText.isEmpty {
                UserAnswerCard(answer: viewModel.answerText)
            }

            SocratesReactionView(reaction: viewModel.currentReaction)

            ClarityMirrorCard(reflection: viewModel.currentClarityMirror)
        }
    }

    private var insightCardContent: some View {
        VStack(spacing: 24) {
            QuestionView(question: viewModel.currentQuestion)

            if !viewModel.answerText.isEmpty {
                UserAnswerCard(answer: viewModel.answerText)
            }

            SocratesReactionView(reaction: viewModel.currentReaction)

            ClarityMirrorCard(reflection: viewModel.currentClarityMirror)

            InsightCardView(insight: viewModel.currentInsightCard)
        }
    }

    // MARK: - Bottom Action Area

    @ViewBuilder
    private var bottomActionArea: some View {
        VStack(spacing: 12) {
            Divider()

            switch viewModel.phase {
            case .awaitingAnswer:
                HStack(spacing: 16) {
                    // Skip button
                    Button {
                        Task {
                            viewModel.answerText = ""
                            await viewModel.submitAnswer()
                        }
                    } label: {
                        Text("Skip")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Submit button
                    Button {
                        Task {
                            await viewModel.submitAnswer()
                        }
                    } label: {
                        Text("Submit")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(viewModel.answerText.isEmpty ? Color.gray : Color.accentColor)
                            .clipShape(Capsule())
                    }
                    .disabled(viewModel.answerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

            case .readyForNext:
                Button {
                    Task {
                        await viewModel.continueToNext()
                    }
                } label: {
                    Text(viewModel.currentQuestionIndex < DialogueSessionViewModel.totalQuestions - 1 ? "Continue" : "Complete Session")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

            default:
                EmptyView()
            }
        }
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                if viewModel.hasUnsavedProgress {
                    showingExitConfirmation = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
    }
}

// MARK: - User Answer Card

struct UserAnswerCard: View {
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your reflection:")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(answer)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let repository = InMemoryJournalRepository()
    return DialogueSessionView(
        viewModel: DialogueSessionViewModel(
            questionService: MockQuestionService(),
            repository: repository
        ),
        repository: repository
    )
}
#endif
