// DailyQuestionFeedView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main feed view for the Today tab
/// Shows the daily question, recording CTA, friend answers (locked/unlocked), and question history
public struct DailyQuestionFeedView: View {
    @State private var viewModel: DailyQuestionFeedViewModel
    @State private var recordButtonScale: CGFloat = 1.0

    /// Audio playback service used for friend answer cards and recording preview
    private let playbackService: AudioPlaybackServiceProtocol

    /// Voice recording service used for the recording screen
    private let recordingService: VoiceRecordingServiceProtocol

    /// Voice answer repository for saving answers from the recording screen
    private let voiceAnswerRepository: VoiceAnswerRepositoryProtocol

    /// Streak repository for recording streaks from the recording screen
    private let streakRepository: StreakRepositoryProtocol

    /// Reaction repository for the reveal experience
    private let reactionRepository: ReactionRepositoryProtocol

    public init(
        viewModel: DailyQuestionFeedViewModel,
        playbackService: AudioPlaybackServiceProtocol,
        recordingService: VoiceRecordingServiceProtocol,
        voiceAnswerRepository: VoiceAnswerRepositoryProtocol,
        streakRepository: StreakRepositoryProtocol,
        reactionRepository: ReactionRepositoryProtocol
    ) {
        _viewModel = State(initialValue: viewModel)
        self.playbackService = playbackService
        self.recordingService = recordingService
        self.voiceAnswerRepository = voiceAnswerRepository
        self.streakRepository = streakRepository
        self.reactionRepository = reactionRepository
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Today")
                .toolbar { streakToolbarItem }
                .fullScreenCover(isPresented: $viewModel.showRecordingSheet) {
                    if let question = viewModel.todaysQuestion {
                        VoiceRecordingView(
                            viewModel: VoiceRecordingViewModel(
                                question: question,
                                recordingService: recordingService,
                                voiceAnswerRepository: voiceAnswerRepository,
                                streakRepository: streakRepository,
                                playbackService: playbackService,
                                onAnswerSubmitted: { [viewModel] in
                                    Task {
                                        await viewModel.onAnswerSubmitted()
                                    }
                                }
                            ),
                            playbackService: playbackService
                        )
                    }
                }
                .sheet(isPresented: $viewModel.showRevealSheet) {
                    if let question = viewModel.todaysQuestion {
                        AnswerRevealView(
                            viewModel: AnswerRevealViewModel(
                                questionId: question.id,
                                voiceAnswerRepository: voiceAnswerRepository,
                                reactionRepository: reactionRepository,
                                playbackService: playbackService,
                                onDismiss: {
                                    viewModel.showRevealSheet = false
                                }
                            ),
                            playbackService: playbackService
                        )
                    }
                }
                .refreshable {
                    await viewModel.refreshFeed()
                }
                .task {
                    await viewModel.loadTodaysQuestion()
                }
        }
    }

    // MARK: - Content Router

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.todaysQuestion == nil {
            loadingView
        } else if let question = viewModel.todaysQuestion {
            ScrollView {
                LazyVStack(spacing: 24) {
                    if viewModel.hasAnsweredToday {
                        answeredContent(question: question)
                    } else {
                        lockedContent(question: question)
                    }

                    // Question history section
                    if !viewModel.questionHistory.isEmpty {
                        questionHistorySection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        } else if let error = viewModel.error {
            errorView(error: error)
        } else {
            emptyView
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Loading today's question...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(error: Error) -> some View {
        ContentUnavailableView(
            "Unable to Load",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }

    // MARK: - Empty View

    private var emptyView: some View {
        ContentUnavailableView(
            "No Question Today",
            systemImage: "questionmark.circle",
            description: Text("Check back later for today's question.")
        )
    }

    // MARK: - Locked Content (Before Answering)

    private func lockedContent(question: DailyQuestion) -> some View {
        VStack(spacing: 24) {
            // Question card
            QuestionCardView(question: question, hasAnswered: false)

            // Friend avatar row (locked)
            if !viewModel.friendAnswers.isEmpty {
                FriendAvatarRow(
                    friendAnswers: viewModel.friendAnswers,
                    isUnlocked: false
                )
            } else {
                emptyFriendsHint
            }

            // Record CTA button
            recordButton
        }
    }

    // MARK: - Answered Content (Unlocked)

    private func answeredContent(question: DailyQuestion) -> some View {
        VStack(spacing: 24) {
            // Question card with answered badge
            QuestionCardView(question: question, hasAnswered: true)

            // Your Answer card
            if let myAnswer = viewModel.myAnswer {
                yourAnswerCard(answer: myAnswer)
            }

            // Friend Answers section
            if !viewModel.friendAnswers.isEmpty {
                friendAnswersSection
            } else {
                emptyFriendsHint
            }
        }
    }

    // MARK: - Your Answer Card

    private func yourAnswerCard(answer: VoiceAnswer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Answer")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.accentColor)

                if let audioURL = answer.audioFileURL {
                    MiniAudioPlayerView(
                        playbackService: playbackService,
                        url: audioURL,
                        duration: answer.duration
                    )
                } else {
                    // No audio file; show duration label
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.caption)
                        Text(formatDuration(answer.duration))
                            .font(.caption2)
                            .fontDesign(.monospaced)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Friend Answers Section

    private var friendAnswersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friend Answers")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(viewModel.friendAnswers) { friendAnswer in
                FriendAnswerCard(
                    friendAnswer: friendAnswer,
                    playbackService: playbackService
                )
            }
        }
    }

    // MARK: - Question History Section

    private var questionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Previous Questions")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 8)

            ForEach(viewModel.questionHistory.prefix(5)) { question in
                questionHistoryRow(question: question)
            }
        }
    }

    private func questionHistoryRow(question: DailyQuestion) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(question.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(question.text)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            Spacer()
            categoryPill(for: question.category)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func categoryPill(for category: QuestionCategory) -> some View {
        Text(category.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(colorForHint(category.colorHint))
            )
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button {
            viewModel.onRecordButtonTapped()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "mic.fill")
                    .font(.title3)
                Text("Record Your Answer")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor)
            )
        }
        .scaleEffect(recordButtonScale)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                recordButtonScale = 1.03
            }
        }
    }

    // MARK: - Empty Friends Hint

    private var emptyFriendsHint: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Add friends to see their answers!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Streak Toolbar Item

    @ToolbarContentBuilder
    private var streakToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(viewModel.currentStreak?.currentStreak ?? 0)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func colorForHint(_ hint: String) -> Color {
        switch hint {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .accentColor
        }
    }
}

// MARK: - Preview

#Preview {
    DailyQuestionFeedView(
        viewModel: DailyQuestionFeedViewModel(
            questionRepository: MockQuestionRepository(),
            voiceAnswerRepository: MockVoiceAnswerRepository(),
            friendshipRepository: MockFriendshipRepository(),
            streakRepository: MockStreakRepository()
        ),
        playbackService: MockAudioPlaybackService(),
        recordingService: MockVoiceRecordingService(),
        voiceAnswerRepository: MockVoiceAnswerRepository(),
        streakRepository: MockStreakRepository(),
        reactionRepository: MockReactionRepository()
    )
}
#endif
