// OnboardingLettersView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Fourth onboarding screen - Letters to Future Self & Get Started
/// Introduces the time-locked letters feature and provides the call-to-action to begin
public struct OnboardingLettersView: View {
    // MARK: - Properties

    let onSkip: () -> Void
    let onComplete: () -> Void

    @State private var isVisible: Bool = false

    // MARK: - Initialization

    public init(onSkip: @escaping () -> Void, onComplete: @escaping () -> Void) {
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
                // Skip button at top-right
                skipButton

                Spacer()

                // Main content - centered
                mainContent

                Spacer()

                // Begin Journey button at bottom
                beginJourneyButton
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
            // Envelope visual
            envelopeVisual

            // Title and description
            VStack(spacing: 16) {
                Text("Letters to Your Future Self")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Write letters to yourself that unlock at a future date. Capture your current thoughts, hopes, and intentions to rediscover later on your journey.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                // Time-locked concept badge
                timeLockedBadge
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }

    // MARK: - Envelope Visual

    private var envelopeVisual: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 160, height: 160)

            // Main envelope icon
            Image(systemName: "envelope.open.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)

            // Clock overlay to indicate time-locked
            Image(systemName: "clock.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.accentColor)
                .background(
                    Circle()
                        .fill(Color(uiColor: .systemBackground))
                        .frame(width: 32, height: 32)
                )
                .offset(x: 36, y: 28)
        }
    }

    // MARK: - Time-Locked Badge

    private var timeLockedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)

            Text("Time-locked until your chosen date")
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

    // MARK: - Begin Journey Button

    private var beginJourneyButton: some View {
        Button {
            onComplete()
        } label: {
            Text("Begin Your Journey")
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
    OnboardingLettersView(
        onSkip: { print("Skip tapped") },
        onComplete: { print("Complete tapped") }
    )
}
#endif
