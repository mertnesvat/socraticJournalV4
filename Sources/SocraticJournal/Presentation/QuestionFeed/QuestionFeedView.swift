// QuestionFeedView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen editorial daily question feed -- the main home experience
/// Displays today's question with streak, disagreement meter, and countdown
/// Clean cream background with bold coral accent and left-aligned typography
public struct QuestionFeedView: View {
    @State private var viewModel: QuestionFeedViewModel
    @State private var showRecording: Bool = false

    public init(viewModel: QuestionFeedViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Clean cream background
            AppColors.background
                .ignoresSafeArea()

            // Main content
            content
        }
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: $showRecording) {
            // Placeholder for recording flow (Feature 4)
            Text("Recording flow coming soon")
                .font(.headline)
                .foregroundStyle(.secondary)
                .presentationDetents([.large])
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.todaysQuestion == nil {
            loadingView
        } else if let errorMsg = viewModel.errorMessage, viewModel.todaysQuestion == nil {
            errorView(errorMsg)
        } else if let question = viewModel.todaysQuestion {
            questionContent(question)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(AppColors.accent)
                .scaleEffect(1.2)
            Text("Loading today's question...")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textTertiary)

            Text("Something went wrong")
                .font(AppTypography.headlineMedium)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            AccentPillButton("Try Again", icon: "arrow.clockwise") {
                Task { await viewModel.loadData() }
            }
            .padding(.horizontal, AppSpacing.sectionGap)
        }
    }

    private func questionContent(_ question: DailyQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: AppSpacing.heroTopPadding)

                // Streak badge — left-aligned at top
                if let streak = viewModel.streak, streak.currentStreak > 0 {
                    StreakBadge(streak: streak)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.bottom, AppSpacing.sectionGap)
                }

                // MASSIVE hero question card
                QuestionCard(question: question)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sectionGap)

                // Disagreement meter — giant donut ring
                DisagreementMeter(
                    disagreementRatio: question.disagreementRatio,
                    responseCount: question.globalResponseCount
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sectionGap)

                // Primary CTA button using AccentPillButton
                AccentPillButton(
                    viewModel.hasAnsweredToday ? "See What Friends Said" : "Record Your Take",
                    icon: viewModel.hasAnsweredToday ? "person.2.fill" : "mic.fill"
                ) {
                    showRecording = true
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.lg)

                // Countdown timer — right-aligned at bottom
                CountdownTimer(timeUntilNext: viewModel.timeUntilNextQuestion)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sectionGap)
            }
            .frame(minHeight: UIScreen.main.bounds.height - 120)
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
}

#Preview {
    QuestionFeedView(
        viewModel: QuestionFeedViewModel(
            questionFeedService: MockQuestionFeedService(),
            userProfileService: MockUserProfileService()
        )
    )
}
#endif
