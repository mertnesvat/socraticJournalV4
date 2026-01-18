// OnboardingWelcomeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// First onboarding screen - Welcome & Value Proposition
/// Introduces users to the core concept of Socratic journaling
public struct OnboardingWelcomeView: View {
    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var headlineOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
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
            // Icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .opacity(iconOpacity)

            // Text content
            VStack(spacing: 16) {
                // Headline
                Text("Know Thyself")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(headlineOpacity)

                // Tagline
                Text("Discover yourself through guided Socratic dialogue")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(taglineOpacity)
            }
            .padding(.horizontal, 24)
        }
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
            taglineOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Preview

#Preview("Welcome Screen") {
    OnboardingWelcomeView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
}

#Preview("Welcome Screen - Dark") {
    OnboardingWelcomeView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
    .preferredColorScheme(.dark)
}
#endif
