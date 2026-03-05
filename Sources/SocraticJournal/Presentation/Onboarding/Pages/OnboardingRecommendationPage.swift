// OnboardingRecommendationPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 5: "Your Starting Point" — personalized pattern recommendation
struct OnboardingRecommendationPage: View {
    let assessment: OnboardingAssessment
    let onBeginJourney: () -> Void

    private var pattern: BreathPattern {
        assessment.recommendedPattern
    }

    private var minutes: Int {
        assessment.recommendedMinutes
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Text("Your Starting\nPoint")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // Recommendation card
            recommendationCard
                .padding(.horizontal, AppSpacing.xs)

            Spacer()

            // Begin Journey button
            Button(action: onBeginJourney) {
                Text("Begin Your Journey")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Capsule().fill(.white))
            }
            .buttonStyle(.plain)
            .padding(.bottom, AppSpacing.lg)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Recommendation Card

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(pattern.name)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.accent)

            Text(pattern.timing)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.textSecondary)

            Text("Based on your goal: \(assessment.goalLabel)")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.textSecondary)

            Text("Start with \(minutes) minutes")
                .font(.system(size: 12, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        )
    }
}

#Preview {
    ZStack {
        AppColors.accent
            .ignoresSafeArea()

        OnboardingRecommendationPage(
            assessment: OnboardingAssessment(
                breathingStyle: .nose,
                mainGoal: .stress,
                experience: .occasional
            ),
            onBeginJourney: {}
        )
    }
}
#endif
