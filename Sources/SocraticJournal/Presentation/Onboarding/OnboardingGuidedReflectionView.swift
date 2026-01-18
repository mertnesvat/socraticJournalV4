// OnboardingGuidedReflectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Second onboarding screen - Guided Reflection Feature
/// Explains how the app uses thoughtful questions to guide reflection
public struct OnboardingGuidedReflectionView: View {
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
            // Visual representation of dialogue/question flow
            dialogueVisual

            // Title and description
            VStack(spacing: 16) {
                Text("Thoughtful Questions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Meaningful questions guide your reflection, helping you explore thoughts you might otherwise overlook. Each dialogue adapts to uncover deeper insights.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                // Clarity Score mention
                clarityScoreBadge
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }

    // MARK: - Dialogue Visual

    private var dialogueVisual: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 160, height: 160)

            // Stacked chat bubbles representing dialogue
            VStack(spacing: 12) {
                // Question bubble (from app)
                HStack {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentColor)
                        .symbolRenderingMode(.hierarchical)
                    Spacer()
                }
                .frame(width: 100)

                // Answer bubble (from user)
                HStack {
                    Spacer()
                    Image(systemName: "bubble.right.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary.opacity(0.6))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: 100)

                // Follow-up question with sparkle
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.accentColor)
                            .symbolRenderingMode(.hierarchical)

                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.accentColor)
                            .offset(x: 8, y: -8)
                    }
                    Spacer()
                }
                .frame(width: 100)
            }
        }
    }

    // MARK: - Clarity Score Badge

    private var clarityScoreBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)

            Text("Track your reflection depth with Clarity Score")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.accentColor.opacity(0.1))
        )
        .padding(.top, 8)
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
    OnboardingGuidedReflectionView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
}
#endif
