// OnboardingCharacterDiscoveryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Third onboarding screen - Discover Your Character
/// Introduces the Big Five personality discovery feature
public struct OnboardingCharacterDiscoveryView: View {
    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var headlineOpacity: Double = 0
    @State private var descriptionOpacity: Double = 0
    @State private var traitsOpacity: Double = 0
    @State private var unlockMessageOpacity: Double = 0
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
            // Icon representing personality/character discovery
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .opacity(iconOpacity)

            // Text content
            VStack(spacing: 16) {
                // Headline
                Text("Discover Your Character")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(headlineOpacity)

                // Description
                Text("As you journal over time, patterns emerge that reveal your unique personality traits and strengths.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(descriptionOpacity)
            }
            .padding(.horizontal, 24)

            // Big Five personality traits icons
            bigFiveTraitsSection

            // Unlock message
            unlockMessageSection
        }
    }

    // MARK: - Big Five Traits Section

    private var bigFiveTraitsSection: some View {
        HStack(spacing: 20) {
            TraitIcon(
                systemName: "lightbulb.fill",
                color: .orange,
                label: "Openness"
            )
            TraitIcon(
                systemName: "checkmark.circle.fill",
                color: .blue,
                label: "Conscientiousness"
            )
            TraitIcon(
                systemName: "person.2.fill",
                color: .green,
                label: "Extraversion"
            )
            TraitIcon(
                systemName: "heart.fill",
                color: .pink,
                label: "Agreeableness"
            )
            TraitIcon(
                systemName: "leaf.fill",
                color: .teal,
                label: "Balance"
            )
        }
        .opacity(traitsOpacity)
    }

    // MARK: - Unlock Message Section

    private var unlockMessageSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.open")
                .font(.title2)
                .foregroundStyle(Color.accentColor)

            Text("Unlocks with continued journaling")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.1))
        )
        .opacity(unlockMessageOpacity)
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
            traitsOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
            unlockMessageOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(1.1)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Trait Icon Component

private struct TraitIcon: View {
    let systemName: String
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) trait")
    }
}

// MARK: - Preview

#Preview("Character Discovery Screen") {
    OnboardingCharacterDiscoveryView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
}

#Preview("Character Discovery Screen - Dark") {
    OnboardingCharacterDiscoveryView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
    .preferredColorScheme(.dark)
}
#endif
