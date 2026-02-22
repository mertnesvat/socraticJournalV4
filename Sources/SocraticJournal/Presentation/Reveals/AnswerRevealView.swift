// AnswerRevealView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen showing friends' answer cards that can be unlocked after recording your own answer
public struct AnswerRevealView: View {
    @State private var viewModel: AnswerRevealViewModel
    @State private var showShareSheet: Bool = false

    public init(viewModel: AnswerRevealViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Friends' Takes")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.loadData() }
                .sheet(isPresented: $showShareSheet) {
                    shareActivityView
                }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.reveals.isEmpty {
            loadingView
        } else if let error = viewModel.errorMessage, viewModel.reveals.isEmpty {
            errorView(error)
        } else if viewModel.reveals.isEmpty {
            emptyStateView
        } else if !viewModel.hasAnswered {
            lockedStateView
        } else {
            revealsList
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading friends' answers...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Unable to Load",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Friends Answered Yet", systemImage: "person.2.slash")
        } description: {
            Text("Share the question with your friends so you can hear their takes!")
        } actions: {
            Button {
                showShareSheet = true
            } label: {
                Label("Share Question", systemImage: "square.and.arrow.up")
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }

    // MARK: - Locked State (User hasn't answered)

    private var lockedStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Record Yours to Unlock")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("\(viewModel.totalFriendCount) friends have answered.\nRecord your take first to hear theirs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Preview of locked cards (blurred)
            VStack(spacing: 12) {
                ForEach(viewModel.reveals.prefix(3)) { reveal in
                    lockedPreviewCard(reveal)
                }
            }
            .padding(.horizontal, 16)
            .allowsHitTesting(false)

            Spacer()
        }
        .padding()
    }

    private func lockedPreviewCard(_ reveal: AnswerReveal) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color(.systemGray2))
                )

            VStack(alignment: .leading, spacing: 2) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: 100, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 10)
            }

            Spacer()

            Image(systemName: "lock.fill")
                .font(.body)
                .foregroundStyle(Color(.systemGray3))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.6))
        )
        .blur(radius: 2)
    }

    // MARK: - Reveals List

    private var revealsList: some View {
        ScrollView {
            VStack(spacing: 4) {
                // Header summary
                headerView
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Friend answer cards
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.reveals) { reveal in
                        FriendAnswerCard(
                            reveal: reveal,
                            friend: viewModel.friendForRevealFallback(reveal),
                            answer: viewModel.answerForReveal(reveal),
                            isPlaying: viewModel.currentlyPlayingId == reveal.id,
                            reaction: viewModel.reactions[reveal.id],
                            onTap: {
                                Task { await viewModel.playFriendAnswer(revealId: reveal.id) }
                            },
                            onReaction: { emoji in
                                viewModel.addReaction(revealId: reveal.id, emoji: emoji)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(viewModel.answeredCount) unlocked")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }

            Spacer()

            // Unlock all remaining hint
            if viewModel.answeredCount < viewModel.totalFriendCount {
                Text("Tap to unlock")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }

    // MARK: - Share Sheet

    private var shareActivityView: some View {
        // Simple share sheet placeholder
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text("Share this question")
                .font(.headline)

            Text("Let your friends answer so you can hear their takes!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Done") {
                showShareSheet = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

#Preview("With Answers") {
    AnswerRevealView(
        viewModel: AnswerRevealViewModel(
            questionId: "q_dt_4",
            revealService: MockAnswerRevealService(),
            friendService: MockFriendService(),
            voiceService: VoiceRecordingService()
        )
    )
}

#Preview("Empty State") {
    AnswerRevealView(
        viewModel: AnswerRevealViewModel(
            questionId: "q_nonexistent",
            revealService: MockAnswerRevealService(),
            friendService: MockFriendService(),
            voiceService: VoiceRecordingService()
        )
    )
}

#endif
