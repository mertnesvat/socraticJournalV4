// OnboardingWelcomePage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 1: Welcome page introducing the Socratic concept.
/// Bold hero area with gradient and speech bubble icons.
public struct OnboardingWelcomePage: View {
    // MARK: - Animation State

    @State private var bubblesVisible: Bool = false
    @State private var gradientShift: Bool = false

    // MARK: - Body

    public var body: some View {
        OnboardingPageView(
            title: "Your friends have opinions.",
            subtitle: "Socratic drops a controversial question every day. Record your take. Unlock your friends'."
        ) {
            heroArea
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                bubblesVisible = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                gradientShift = true
            }
        }
    }

    // MARK: - Hero Area

    private var heroArea: some View {
        ZStack {
            // Gradient background card
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: gradientShift
                            ? [Color.purple, Color.blue.opacity(0.8)]
                            : [Color.blue.opacity(0.8), Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .padding(.horizontal, 40)

            // Speech bubble icons
            HStack(spacing: 24) {
                speechBubbleIcon(systemName: "bubble.left.fill", delay: 0)
                speechBubbleIcon(systemName: "bubble.middle.bottom.fill", delay: 0.15)
                speechBubbleIcon(systemName: "bubble.right.fill", delay: 0.3)
            }
            .opacity(bubblesVisible ? 1 : 0)
            .scaleEffect(bubblesVisible ? 1 : 0.6)
        }
    }

    // MARK: - Speech Bubble Icon

    private func speechBubbleIcon(systemName: String, delay: Double) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 40, weight: .light))
            .foregroundStyle(.white.opacity(0.9))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingWelcomePage()
    }
}
#endif
