// OnboardingWelcomeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// First onboarding screen introducing the app concept
/// Displays the "Know Thyself" welcome message with Socratic dialogue explanation
public struct OnboardingWelcomeView: View {
    // MARK: - Callbacks

    let onContinue: () -> Void
    let onSkip: () -> Void

    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var iconScale: Double = 0.8
    @State private var headlineOpacity: Double = 0
    @State private var headlineOffset: Double = 20
    @State private var taglineOpacity: Double = 0
    @State private var taglineOffset: Double = 20
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
                    // Icon
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(Color.accentColor)
                        .opacity(iconOpacity)
                        .scaleEffect(iconScale)

                    // Text content
                    VStack(spacing: 16) {
                        // Headline
                        Text("Know Thyself")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(headlineOpacity)
                            .offset(y: headlineOffset)

                        // Tagline
                        Text("Discover deeper self-understanding through the ancient art of Socratic dialogue. Ask questions. Find clarity.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(taglineOpacity)
                            .offset(y: taglineOffset)
                    }
                    .padding(.horizontal, 40)
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

        // Tagline fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            taglineOpacity = 1
            taglineOffset = 0
        }

        // Button fade
        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingWelcomeView(
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    )
}
#endif
