// OnboardingLettersView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Final onboarding screen introducing Letters to Future Self feature
/// Displays the time-locked letters concept and call-to-action to begin the journey
public struct OnboardingLettersView: View {
    // MARK: - Callbacks

    let onComplete: () -> Void
    let onSkip: () -> Void

    // MARK: - Animation State

    @State private var iconOpacity: Double = 0
    @State private var iconScale: Double = 0.8
    @State private var headlineOpacity: Double = 0
    @State private var headlineOffset: Double = 20
    @State private var descriptionOpacity: Double = 0
    @State private var descriptionOffset: Double = 20
    @State private var timelineOpacity: Double = 0
    @State private var timelineOffset: Double = 20
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: Double = 1.0

    // MARK: - Init

    public init(onComplete: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.onComplete = onComplete
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
                    // Icon - envelope with time element
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(.accent)
                        .opacity(iconOpacity)
                        .scaleEffect(iconScale)

                    // Text content
                    VStack(spacing: 16) {
                        // Headline
                        Text("Letters to Future Self")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(headlineOpacity)
                            .offset(y: headlineOffset)

                        // Description
                        Text("Capture your thoughts today and lock them for the future. Open your time-locked letters weeks or months from now to see how far you have come.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(descriptionOpacity)
                            .offset(y: descriptionOffset)
                    }
                    .padding(.horizontal, 40)

                    // Time-locked visual
                    timeLockedVisualView
                        .opacity(timelineOpacity)
                        .offset(y: timelineOffset)
                }

                Spacer()

                // CTA button - more prominent than Continue
                VStack(spacing: 16) {
                    Button {
                        onComplete()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Begin Your Journey")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .scaleEffect(buttonScale)
                    .opacity(buttonOpacity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Subviews

    /// Visual representation of time-locked letter concept
    private var timeLockedVisualView: some View {
        VStack(spacing: 16) {
            // Timeline visualization
            HStack(spacing: 0) {
                // Today
                VStack(spacing: 6) {
                    Image(systemName: "pencil.and.outline")
                        .font(.title3)
                        .foregroundStyle(.accent)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Circle())

                    Text("Write")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Connecting line
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(height: 2)
                    .frame(maxWidth: 60)

                // Lock
                VStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundStyle(.accent)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Circle())

                    Text("Lock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Connecting line
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(height: 2)
                    .frame(maxWidth: 60)

                // Future
                VStack(spacing: 6) {
                    Image(systemName: "envelope.open.fill")
                        .font(.title3)
                        .foregroundStyle(.accent)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Circle())

                    Text("Unlock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Subtitle
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundStyle(.accent)
                Text("1 week to 1 year")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 24)
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

        // Timeline visual fade and slide up
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            timelineOpacity = 1
            timelineOffset = 0
        }

        // Button fade
        withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
            buttonOpacity = 1
        }

        // Subtle pulse animation on button to draw attention
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
            .delay(1.2)
        ) {
            buttonScale = 1.03
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingLettersView(
        onComplete: { print("Complete tapped") },
        onSkip: { print("Skip tapped") }
    )
}
#endif
