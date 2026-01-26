// OnboardingSelfDiscoveryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Onboarding screen introducing the Self-Discovery tab with Character Quiz
/// Displays information about personality quizzes and character matching features
public struct OnboardingSelfDiscoveryView: View {
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
    @State private var featuresOpacity: Double = 0
    @State private var featuresOffset: Double = 20
    @State private var quizHighlightOpacity: Double = 0
    @State private var quizHighlightOffset: Double = 20
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
                    // Icon - self discovery
                    Image(systemName: "person.fill.viewfinder")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(Color.accentColor)
                        .opacity(iconOpacity)
                        .scaleEffect(iconScale)

                    // Text content
                    VStack(spacing: 16) {
                        // Headline
                        Text("Discover Yourself")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(headlineOpacity)
                            .offset(y: headlineOffset)

                        // Description
                        Text("Explore the Self-Discovery tab to learn more about yourself through quizzes, character matching, and letters to your future self.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(descriptionOpacity)
                            .offset(y: descriptionOffset)
                    }
                    .padding(.horizontal, 40)

                    // Features visual
                    featuresView
                        .opacity(featuresOpacity)
                        .offset(y: featuresOffset)

                    // Character Quiz highlight
                    characterQuizHighlightView
                        .opacity(quizHighlightOpacity)
                        .offset(y: quizHighlightOffset)
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

    /// Visual representation of Self-Discovery features
    private var featuresView: some View {
        VStack(spacing: 12) {
            // Row of feature icons
            HStack(spacing: 24) {
                featureIcon(symbol: "theatermasks.fill", label: "Quiz")
                featureIcon(symbol: "person.crop.rectangle.stack", label: "Characters")
                featureIcon(symbol: "envelope.fill", label: "Letters")
            }

            // Subtitle
            Text("New ways to understand yourself")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 24)
    }

    /// Individual feature icon with label
    private func featureIcon(symbol: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 52, height: 52)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    /// Highlight for the Character Quiz feature
    private var characterQuizHighlightView: some View {
        HStack(spacing: 10) {
            Image(systemName: "theatermasks.fill")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)

            Text("Which fictional character matches your personality?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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

        // Features fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            featuresOpacity = 1
            featuresOffset = 0
        }

        // Quiz highlight fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            quizHighlightOpacity = 1
            quizHighlightOffset = 0
        }

        // Button fade
        withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingSelfDiscoveryView(
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    )
}
#endif
