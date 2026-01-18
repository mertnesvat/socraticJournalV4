// OnboardingCharacterView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Third onboarding screen introducing the character discovery feature
/// Displays information about personality trait insights unlocked through journaling
public struct OnboardingCharacterView: View {
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
    @State private var traitsOpacity: Double = 0
    @State private var traitsOffset: Double = 20
    @State private var unlockOpacity: Double = 0
    @State private var unlockOffset: Double = 20
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
                    // Icon - person with star representing character
                    Image(systemName: "person.fill")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(.accent)
                        .opacity(iconOpacity)
                        .scaleEffect(iconScale)

                    // Text content
                    VStack(spacing: 16) {
                        // Headline
                        Text("Discover Your Character")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(headlineOpacity)
                            .offset(y: headlineOffset)

                        // Description
                        Text("Over time, your journal entries reveal patterns in your personality. Uncover traits that make you uniquely you.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(descriptionOpacity)
                            .offset(y: descriptionOffset)
                    }
                    .padding(.horizontal, 40)

                    // Big Five traits visual
                    bigFiveTraitsView
                        .opacity(traitsOpacity)
                        .offset(y: traitsOffset)

                    // Unlock progress indicator
                    unlockProgressView
                        .opacity(unlockOpacity)
                        .offset(y: unlockOffset)
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

    /// Visual representation of the Big Five personality traits
    private var bigFiveTraitsView: some View {
        VStack(spacing: 12) {
            // Row of 5 trait icons
            HStack(spacing: 20) {
                traitIcon(symbol: "lightbulb", label: "Open")
                traitIcon(symbol: "checklist", label: "Diligent")
                traitIcon(symbol: "person.2", label: "Social")
                traitIcon(symbol: "heart", label: "Kind")
                traitIcon(symbol: "brain", label: "Calm")
            }

            // Subtitle
            Text("Five dimensions of personality")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 24)
    }

    /// Individual trait icon with label
    private func traitIcon(symbol: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(.accent)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    /// Visual indicator showing the feature unlocks with continued journaling
    private var unlockProgressView: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.open")
                .font(.subheadline)
                .foregroundStyle(.accent)

            Text("Unlocks as you journal")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Progress dots
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index == 0 ? Color.accentColor : Color.accentColor.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
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

        // Big Five traits fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            traitsOpacity = 1
            traitsOffset = 0
        }

        // Unlock progress fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            unlockOpacity = 1
            unlockOffset = 0
        }

        // Button fade
        withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
            buttonOpacity = 1
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingCharacterView(
        onContinue: { print("Continue tapped") },
        onSkip: { print("Skip tapped") }
    )
}
#endif
