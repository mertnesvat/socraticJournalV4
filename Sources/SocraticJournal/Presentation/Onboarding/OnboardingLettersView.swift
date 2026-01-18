// OnboardingLettersView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Fourth/Final onboarding screen - Letters to Future Self & CTA
/// Introduces the time-locked letters feature and provides the final call-to-action
public struct OnboardingLettersView: View {
    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var headlineOpacity: Double = 0
    @State private var descriptionOpacity: Double = 0
    @State private var featureCardsOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    // MARK: - Actions

    /// Called when user taps the skip button to skip and complete onboarding
    public var onSkip: (() -> Void)?

    /// Called when user taps the CTA button to complete onboarding
    public var onComplete: (() -> Void)?

    // MARK: - Init

    public init(
        onSkip: (() -> Void)? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.onSkip = onSkip
        self.onComplete = onComplete
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

                // Prominent CTA button at bottom
                ctaButton
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
            // Icon representing letters/time concept
            lettersIconGroup

            // Text content
            VStack(spacing: 16) {
                // Headline
                Text("Letters to Future Self")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(headlineOpacity)

                // Description
                Text("Write heartfelt letters to your future self. Lock them away with a chosen date, and receive them when you need them most.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(descriptionOpacity)
            }
            .padding(.horizontal, 24)

            // Feature cards explaining the concept
            featureCardsSection
        }
    }

    // MARK: - Letters Icon Group

    private var lettersIconGroup: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 140, height: 140)

            // Main envelope icon
            Image(systemName: "envelope.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor.opacity(0.8))

            // Small clock badge in corner
            Image(systemName: "clock.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.accentColor)
                .background(
                    Circle()
                        .fill(Color(uiColor: .systemBackground))
                        .frame(width: 36, height: 36)
                )
                .offset(x: 40, y: -40)
        }
        .opacity(iconOpacity)
    }

    // MARK: - Feature Cards Section

    private var featureCardsSection: some View {
        VStack(spacing: 12) {
            FeatureCard(
                systemName: "pencil.line",
                title: "Write",
                description: "Capture thoughts and hopes"
            )

            FeatureCard(
                systemName: "lock.fill",
                title: "Lock",
                description: "Choose when to receive it"
            )

            FeatureCard(
                systemName: "gift.fill",
                title: "Receive",
                description: "A gift from your past self"
            )
        }
        .padding(.horizontal, 24)
        .opacity(featureCardsOpacity)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            onComplete?()
        } label: {
            HStack(spacing: 8) {
                Text("Begin Your Journey")
                    .font(.headline)
                Image(systemName: "arrow.right")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
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
            featureCardsOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Feature Card Component

private struct FeatureCard: View {
    let systemName: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Letters Screen") {
    OnboardingLettersView(
        onSkip: { print("Skip tapped") },
        onComplete: { print("Begin Journey tapped") }
    )
}

#Preview("Letters Screen - Dark") {
    OnboardingLettersView(
        onSkip: { print("Skip tapped") },
        onComplete: { print("Begin Journey tapped") }
    )
    .preferredColorScheme(.dark)
}
#endif
