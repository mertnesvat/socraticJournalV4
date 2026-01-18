// OnboardingGuidedReflectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Second onboarding screen - Guided Reflection Feature
/// Explains the dialogue session feature and Clarity Score
public struct OnboardingGuidedReflectionView: View {
    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var headlineOpacity: Double = 0
    @State private var descriptionOpacity: Double = 0
    @State private var clarityScoreOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    // MARK: - Actions

    /// Called when user taps the skip button to skip all onboarding
    public var onSkip: (() -> Void)?

    /// Called when user taps continue or swipes to proceed to next screen
    public var onContinue: (() -> Void)?

    // MARK: - Init

    public init(
        onSkip: (() -> Void)? = nil,
        onContinue: (() -> Void)? = nil
    ) {
        self.onSkip = onSkip
        self.onContinue = onContinue
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button in top-right
                skipButton

                Spacer()

                // Main content centered
                mainContent

                Spacer()

                // Continue button at bottom
                continueButton
            }
            .padding()
        }
        .onAppear {
            animateContent()
        }
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        HStack {
            Spacer()

            Button {
                onSkip?()
            } label: {
                Text("Skip")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .opacity(buttonOpacity)
        }
        .padding(.top, 8)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 32) {
            // Icon representing dialogue/conversation
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .opacity(iconOpacity)

            // Text content
            VStack(spacing: 16) {
                // Headline
                Text("Thoughtful Questions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(headlineOpacity)

                // Description
                Text("Through Socratic questioning, the app guides your reflection with meaningful prompts that help you explore your thoughts more deeply.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(descriptionOpacity)
            }
            .padding(.horizontal, 24)

            // Clarity Score mention
            clarityScoreSection
        }
    }

    // MARK: - Clarity Score Section

    private var clarityScoreSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color.accentColor)

            Text("Your Clarity Score measures reflection depth")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.1))
        )
        .opacity(clarityScoreOpacity)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            onContinue?()
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .opacity(buttonOpacity)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Animation

    private func animateContent() {
        // Staggered fade-in animation
        withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
            iconOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            headlineOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            descriptionOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
            clarityScoreOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Preview

#Preview("Guided Reflection Screen") {
    OnboardingGuidedReflectionView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
}

#Preview("Guided Reflection Screen - Dark") {
    OnboardingGuidedReflectionView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
    .preferredColorScheme(.dark)
}
#endif
