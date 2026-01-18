// OnboardingWelcomeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// First onboarding screen - Welcome and Value Proposition
/// Introduces users to the core concept of Socratic journaling
public struct OnboardingWelcomeView: View {
    // MARK: - Properties

    let onSkip: () -> Void
    let onContinue: () -> Void

    @State private var isVisible: Bool = false

    // MARK: - Initialization

    public init(onSkip: @escaping () -> Void, onContinue: @escaping () -> Void) {
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
                // Skip button at top-right
                skipButton

                Spacer()

                // Main content - centered
                mainContent

                Spacer()

                // Continue button at bottom
                continueButton
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isVisible = true
            }
        }
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        HStack {
            Spacer()
            Button {
                onSkip()
            } label: {
                Text("Skip")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(isVisible ? 1 : 0)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 32) {
            // Icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
                .symbolRenderingMode(.hierarchical)

            // Title and description
            VStack(spacing: 16) {
                Text("Know Thyself")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Discover deeper self-understanding through the ancient art of Socratic questioning. Each dialogue guides you to examine your thoughts, beliefs, and values.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            onContinue()
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .opacity(isVisible ? 1 : 0)
    }
}

// MARK: - Preview

#Preview {
    OnboardingWelcomeView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
}
#endif
