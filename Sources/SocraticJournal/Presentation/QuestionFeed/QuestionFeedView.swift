// QuestionFeedView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen immersive daily question feed -- the main home experience
/// Displays today's question with streak, disagreement meter, and countdown
public struct QuestionFeedView: View {
    @State private var viewModel: QuestionFeedViewModel
    @State private var showRecording: Bool = false
    @State private var gradientPhase: Double = 0.0

    public init(viewModel: QuestionFeedViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Animated gradient background
            animatedBackground
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
                .tint(.white)
                .scaleEffect(1.2)
            Text("Loading today's question...")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.6))
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.white.opacity(0.5))

            Text("Something went wrong")
                .font(.headline)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                Task { await viewModel.loadData() }
            } label: {
                Text("Try Again")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
            }
        }
    }

    private func questionContent(_ question: DailyQuestion) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)

                // Streak badge
                if let streak = viewModel.streak, streak.currentStreak > 0 {
                    StreakBadge(streak: streak)
                        .padding(.bottom, 32)
                }

                // Hero question card
                QuestionCard(question: question)
                    .padding(.bottom, 24)

                // Disagreement meter + response count
                DisagreementMeter(
                    disagreementRatio: question.disagreementRatio,
                    responseCount: question.globalResponseCount
                )
                .padding(.bottom, 36)

                // Primary CTA button
                ctaButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                // Countdown timer
                CountdownTimer(timeUntilNext: viewModel.timeUntilNextQuestion)
                    .padding(.bottom, 40)
            }
            .frame(minHeight: UIScreen.main.bounds.height - 120)
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            if viewModel.hasAnsweredToday {
                // Navigate to see friends' answers
                showRecording = true
            } else {
                // Navigate to recording flow
                showRecording = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: viewModel.hasAnsweredToday ? "person.2.fill" : "mic.fill")
                    .font(.system(size: 18, weight: .semibold))

                Text(viewModel.hasAnsweredToday ? "See What Friends Said" : "Record Your Take")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ctaGradient)
            )
            .shadow(color: ctaShadowColor, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var ctaGradient: LinearGradient {
        if viewModel.hasAnsweredToday {
            return LinearGradient(
                colors: [Color.purple, Color.blue],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.3, blue: 0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var ctaShadowColor: Color {
        viewModel.hasAnsweredToday
            ? Color.purple.opacity(0.4)
            : Color(red: 1.0, green: 0.42, blue: 0.42).opacity(0.4)
    }

    // MARK: - Background

    private var animatedBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.07, blue: 0.25),  // Deep purple
                Color(red: 0.05, green: 0.08, blue: 0.20),  // Midnight blue
                Color(red: 0.04, green: 0.14, blue: 0.18),  // Dark teal
                Color(red: 0.08, green: 0.06, blue: 0.22)   // Deep purple (loop)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .hueRotation(.degrees(gradientPhase))
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8.0)
                .repeatForever(autoreverses: true)
            ) {
                gradientPhase = 30
            }
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
    .preferredColorScheme(.dark)
}
#endif
