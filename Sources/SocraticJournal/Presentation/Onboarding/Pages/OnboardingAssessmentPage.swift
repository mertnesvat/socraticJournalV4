// OnboardingAssessmentPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 4: "How Do You Breathe?" quick assessment with 3 sequential questions
struct OnboardingAssessmentPage: View {
    @Binding var assessment: OnboardingAssessment
    let onSkip: () -> Void

    // Track which questions are visible for sequential reveal
    @State private var showQuestion2 = false
    @State private var showQuestion3 = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Spacer()
                    .frame(height: AppSpacing.xl)

                Text("How do you\nbreathe?")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)

                // Q1: Breathing style
                questionSection(title: "Your usual breathing:") {
                    breathingStyleOptions
                }

                // Q2: Main goal (appears after Q1 answered)
                if showQuestion2 {
                    questionSection(title: "Your main goal:") {
                        goalOptions
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Q3: Experience (appears after Q2 answered)
                if showQuestion3 {
                    questionSection(title: "Your experience:") {
                        experienceOptions
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                    .frame(height: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            skipButton
        }
    }

    // MARK: - Question Sections

    @ViewBuilder
    private func questionSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.textSecondary)

            content()
        }
    }

    // MARK: - Q1: Breathing Style

    private var breathingStyleOptions: some View {
        VStack(spacing: AppSpacing.xs) {
            optionCard(
                label: "Through my nose",
                icon: "nose",
                borderColor: AppColors.accent,
                isSelected: assessment.breathingStyle == .nose
            ) {
                assessment.breathingStyle = .nose
                revealQuestion2()
            }

            optionCard(
                label: "Through my mouth",
                icon: "mouth",
                borderColor: AppColors.accent2,
                isSelected: assessment.breathingStyle == .mouth
            ) {
                assessment.breathingStyle = .mouth
                revealQuestion2()
            }

            optionCard(
                label: "I'm not sure",
                icon: "questionmark.circle",
                borderColor: Color(hex: "7A6030"),
                isSelected: assessment.breathingStyle == .unsure
            ) {
                assessment.breathingStyle = .unsure
                revealQuestion2()
            }
        }
    }

    // MARK: - Q2: Goal

    private var goalOptions: some View {
        VStack(spacing: AppSpacing.xs) {
            optionCard(
                label: "Less stress",
                icon: "heart",
                borderColor: AppColors.accent2,
                isSelected: assessment.mainGoal == .stress
            ) {
                assessment.mainGoal = .stress
                revealQuestion3()
            }

            optionCard(
                label: "Better sleep",
                icon: "moon.stars",
                borderColor: AppColors.tagSleep,
                isSelected: assessment.mainGoal == .sleep
            ) {
                assessment.mainGoal = .sleep
                revealQuestion3()
            }

            optionCard(
                label: "General wellness",
                icon: "leaf",
                borderColor: AppColors.accent,
                isSelected: assessment.mainGoal == .wellness
            ) {
                assessment.mainGoal = .wellness
                revealQuestion3()
            }

            optionCard(
                label: "Focus & performance",
                icon: "brain.head.profile",
                borderColor: Color(hex: "7A6030"),
                isSelected: assessment.mainGoal == .focus
            ) {
                assessment.mainGoal = .focus
                revealQuestion3()
            }
        }
    }

    // MARK: - Q3: Experience

    private var experienceOptions: some View {
        VStack(spacing: AppSpacing.xs) {
            optionCard(
                label: "Practice regularly",
                icon: "checkmark.circle",
                borderColor: AppColors.accent,
                isSelected: assessment.experience == .regular
            ) {
                assessment.experience = .regular
            }

            optionCard(
                label: "Tried a few times",
                icon: "hand.raised",
                borderColor: Color(hex: "7A6030"),
                isSelected: assessment.experience == .occasional
            ) {
                assessment.experience = .occasional
            }

            optionCard(
                label: "Complete beginner",
                icon: "sparkles",
                borderColor: Color(hex: "7A6030"),
                isSelected: assessment.experience == .beginner
            ) {
                assessment.experience = .beginner
            }
        }
    }

    // MARK: - Option Card

    private func optionCard(
        label: String,
        icon: String,
        borderColor: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                    .frame(width: 24)

                Text(label)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? AppColors.accent.opacity(0.08) : AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.clear, lineWidth: 0)
            )
            .overlay(alignment: .leading) {
                // Left border accent
                UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(isSelected ? AppColors.accent : borderColor)
                .frame(width: 4)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        Button(action: onSkip) {
            Text("Skip")
                .font(.system(size: 11, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.textTertiary)
        }
        .buttonStyle(.plain)
        .padding(.bottom, AppSpacing.md)
    }

    // MARK: - Animation Helpers

    private func revealQuestion2() {
        guard !showQuestion2 else { return }
        withAnimation(.easeOut(duration: 0.4)) {
            showQuestion2 = true
        }
    }

    private func revealQuestion3() {
        guard !showQuestion3 else { return }
        withAnimation(.easeOut(duration: 0.4)) {
            showQuestion3 = true
        }
    }
}

#Preview {
    OnboardingAssessmentPage(
        assessment: .constant(OnboardingAssessment()),
        onSkip: {}
    )
}
#endif
