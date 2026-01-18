// OnboardingGuidedReflectionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Second onboarding screen explaining the guided reflection feature
/// Displays how thoughtful questions guide the journaling experience
public struct OnboardingGuidedReflectionView: View {
    // MARK: - Callbacks

    let onContinue: () -> Void
    let onSkip: () -> Void

    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var iconScale: Double = 0.8
    @State private var headlineOpacity: Double = 0
    @State private var headlineOffset: Double = 20
    @State private var descriptionOpacity: Double = 0
    @State private var descriptionOffset: Double = 20
    @State private var dialogueOpacity: Double = 0
    @State private var dialogueOffset: Double = 20
    @State private var clarityOpacity: Double = 0
    @State private var clarityOffset: Double = 20
    @State private var buttonOpacity: Double = 0

    // MARK: - Init

    public init(onContinue: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.onContinue = onContinue
        self.onSkip = onSkip
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button in top-right
                HStack {
                    Spacer()
                    Button("Skip") {
                        onSkip()
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .opacity(buttonOpacity)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Main content - centered
                VStack(spacing: 32) {
                    // Icon - dialogue bubbles
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(.accent)
                        .opacity(iconOpacity)
                        .scaleEffect(iconScale)

                    // Text content
                    VStack(spacing: 16) {
                        // Headline
                        Text("Thoughtful Questions")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(headlineOpacity)
                            .offset(y: headlineOffset)

                        // Description
                        Text("Each session guides you with meaningful questions designed to spark deeper reflection and self-discovery.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(descriptionOpacity)
                            .offset(y: descriptionOffset)
                    }
                    .padding(.horizontal, 40)

                    // Dialogue flow visual
                    dialogueFlowView
                        .opacity(dialogueOpacity)
                        .offset(y: dialogueOffset)

                    // Clarity Score mention
                    clarityScoreView
                        .opacity(clarityOpacity)
                        .offset(y: clarityOffset)
                }

                Spacer()

                // Continue button
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
                .padding(.bottom, 32)
                .opacity(buttonOpacity)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Subviews

    /// Visual representation of the question/answer dialogue flow
    private var dialogueFlowView: some View {
        VStack(spacing: 12) {
            // Question bubble (left-aligned)
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.accent)
                    Text("What matters most to you today?")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }

            // Answer bubble (right-aligned)
            HStack {
                Spacer()

                HStack(spacing: 8) {
                    Text("I want to find more balance...")
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Image(systemName: "pencil.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 40)
    }

    /// Brief mention of the Clarity Score feature
    private var clarityScoreView: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.subheadline)
                .foregroundStyle(.accent)
            Text("Your Clarity Score tracks reflection depth")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Animation

    private func startAnimations() {
        // Icon fade and scale
        withAnimation(.easeOut(duration: 0.6)) {
            iconOpacity = 1
            iconScale = 1
        }

        // Headline fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            headlineOpacity = 1
            headlineOffset = 0
        }

        // Description fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            descriptionOpacity = 1
            descriptionOffset = 0
        }

        // Dialogue flow fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            dialogueOpacity = 1
            dialogueOffset = 0
        }

        // Clarity score fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            clarityOpacity = 1
            clarityOffset = 0
        }

        // Button fade
        withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingGuidedReflectionView(
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    )
}
#endif
