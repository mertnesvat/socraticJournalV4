// QuestionHistoryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen displaying the user's question history with filter chips and navigation to answer reveals
public struct QuestionHistoryView: View {
    @State private var viewModel: QuestionHistoryViewModel

    // Services for building AnswerRevealViewModel on navigation
    private let answerRevealService: AnswerRevealServiceProtocol
    private let friendService: FriendServiceProtocol
    private let voiceService: VoiceRecordingServiceProtocol

    public init(
        viewModel: QuestionHistoryViewModel,
        answerRevealService: AnswerRevealServiceProtocol,
        friendService: FriendServiceProtocol,
        voiceService: VoiceRecordingServiceProtocol
    ) {
        _viewModel = State(initialValue: viewModel)
        self.answerRevealService = answerRevealService
        self.friendService = friendService
        self.voiceService = voiceService
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.large)
                .task { await viewModel.loadData() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.questions.isEmpty {
            loadingView
        } else if let error = viewModel.errorMessage, viewModel.questions.isEmpty {
            errorView(error)
        } else if viewModel.filteredQuestions.isEmpty && viewModel.questions.isEmpty {
            emptyStateView
        } else {
            historyList
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading history...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Unable to Load",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Questions Yet", systemImage: "clock.arrow.circlepath")
        } description: {
            Text("Your history starts today! Answer your first question to see it here.")
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - History List

    private var historyList: some View {
        VStack(spacing: 0) {
            // Filter chips
            filterPicker
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

            if viewModel.filteredQuestions.isEmpty {
                // Filtered empty state
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: filterEmptyIcon)
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text(filterEmptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                // Scrollable list
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.filteredQuestions) { question in
                            NavigationLink {
                                AnswerRevealView(
                                    viewModel: AnswerRevealViewModel(
                                        questionId: question.id,
                                        revealService: answerRevealService,
                                        friendService: friendService,
                                        voiceService: voiceService
                                    )
                                )
                            } label: {
                                QuestionHistoryCard(
                                    question: question,
                                    isAnswered: viewModel.isAnswered(question),
                                    friendCount: viewModel.friendCount(for: question)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await viewModel.loadData()
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        HStack(spacing: 8) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                filterChip(filter)
            }
            Spacer()
        }
    }

    private func filterChip(_ filter: HistoryFilter) -> some View {
        let isSelected = viewModel.selectedFilter == filter

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedFilter = filter
            }
        } label: {
            Text(filter.rawValue)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected
                            ? Color.accentColor
                            : Color(uiColor: .tertiarySystemFill)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filter Empty State Helpers

    private var filterEmptyIcon: String {
        switch viewModel.selectedFilter {
        case .all:
            return "clock.arrow.circlepath"
        case .answered:
            return "checkmark.circle"
        case .skipped:
            return "forward.fill"
        }
    }

    private var filterEmptyMessage: String {
        switch viewModel.selectedFilter {
        case .all:
            return "No questions in your history"
        case .answered:
            return "No answered questions yet"
        case .skipped:
            return "No skipped questions -- nice streak!"
        }
    }
}

// MARK: - Preview

#Preview("With History") {
    QuestionHistoryView(
        viewModel: QuestionHistoryViewModel(
            questionFeedService: MockQuestionFeedService()
        ),
        answerRevealService: MockAnswerRevealService(),
        friendService: MockFriendService(),
        voiceService: VoiceRecordingService()
    )
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    NavigationStack {
        ContentUnavailableView {
            Label("No Questions Yet", systemImage: "clock.arrow.circlepath")
        } description: {
            Text("Your history starts today! Answer your first question to see it here.")
        }
        .navigationTitle("History")
    }
    .preferredColorScheme(.dark)
}
#endif
