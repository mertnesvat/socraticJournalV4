// OnboardingCharacterDiscoveryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Third onboarding screen - Character Discovery Feature
/// Introduces the personality discovery feature based on the Big Five model
public struct OnboardingCharacterDiscoveryView: View {
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
            // Big Five trait icons visual
            traitIconsVisual

            // Title and description
            VStack(spacing: 16) {
                Text("Discover Your Character")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("As you journal, your unique personality traits emerge. Through your reflections, discover the patterns that define who you are.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                // Unlock badge
                unlockBadge
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }

    // MARK: - Trait Icons Visual

    private var traitIconsVisual: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(Color.accentColor.opacity(0.08))
                .frame(width: 180, height: 180)

            // Five trait icons in a circular arrangement
            ZStack {
                // Center icon - the self
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)

                // Surrounding trait icons
                ForEach(Array(traitIcons.enumerated()), id: \.offset) { index, icon in
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accentColor.opacity(0.7))
                        .symbolRenderingMode(.hierarchical)
                        .offset(traitOffset(for: index))
                }
            }
        }
    }

    /// The five trait icons representing Big Five personality dimensions
    private var traitIcons: [String] {
        [
            "heart.fill",       // Agreeableness
            "lightbulb.fill",   // Openness
            "leaf.fill",        // Conscientiousness
            "sparkles",         // Extraversion
            "brain.fill"        // Neuroticism (emotional range)
        ]
    }

    /// Calculate offset for each trait icon in circular arrangement
    private func traitOffset(for index: Int) -> CGSize {
        let radius: CGFloat = 60
        let angle = CGFloat((Double(index) * (360.0 / 5.0) - 90) * .pi / 180)
        return CGSize(
            width: Foundation.cos(angle) * radius,
            height: Foundation.sin(angle) * radius
        )
    }

    // MARK: - Unlock Badge

    private var unlockBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.open.fill")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)

            Text("Unlocks as you journal")
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
    OnboardingCharacterDiscoveryView(
        onSkip: { print("Skip tapped") },
        onContinue: { print("Continue tapped") }
    )
}
#endif
