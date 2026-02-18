// OnboardingView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Multi-screen onboarding experience introducing the Circle concept.
/// Uses a horizontal TabView with page-style dots indicator.
public struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Background
            CircleTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button row
                skipButtonRow
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Paged content
                TabView(selection: $viewModel.currentPage) {
                    OnboardingPageView(page: .theProblem)
                        .tag(0)

                    OnboardingPageView(page: .theSolution)
                        .tag(1)

                    OnboardingPageView(page: .howItWorks)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)

                // Bottom controls
                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onChange(of: viewModel.currentPage) { _, newValue in
            viewModel.screenViewed(index: newValue)
        }
        .onAppear {
            viewModel.screenViewed(index: 0)
        }
    }

    // MARK: - Skip Button

    @ViewBuilder
    private var skipButtonRow: some View {
        HStack {
            Spacer()
            if viewModel.showsSkipButton {
                Button("Skip") {
                    viewModel.skipOnboarding()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown.opacity(0.6))
            }
        }
        .frame(height: 44)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Page dots
            pageDots

            // Action button
            actionButton
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPage
                        ? CircleTheme.warmAmber
                        : CircleTheme.warmBrown.opacity(0.2))
                    .frame(
                        width: index == viewModel.currentPage ? 24 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button {
            viewModel.advanceOrComplete()
        } label: {
            Text(viewModel.isLastPage ? "Get Started" : "Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(.white)
                .background(CircleTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: CircleTheme.warmAmber.opacity(0.3),
                    radius: 12, x: 0, y: 6
                )
        }
    }
}

// MARK: - Onboarding Page Data

/// Describes the content for each onboarding screen.
enum OnboardingPage {
    case theProblem
    case theSolution
    case howItWorks
}

// MARK: - Onboarding Page View

/// Individual onboarding page with icon, headline, and subtext.
private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            switch page {
            case .theProblem:
                problemContent
            case .theSolution:
                solutionContent
            case .howItWorks:
                howItWorksContent
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Screen 1: The Problem

    private var problemContent: some View {
        VStack(spacing: 24) {
            // Fading people illustration
            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.cream)
                    .frame(width: 140, height: 140)

                HStack(spacing: -8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(CircleTheme.warmBrown.opacity(0.25))

                    Image(systemName: "person.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(CircleTheme.warmBrown.opacity(0.45))

                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(CircleTheme.warmBrown.opacity(0.25))
                }
            }

            VStack(spacing: 12) {
                Text("Your closest people are one\nscroll away, but somehow\nunreachable")
                    .font(.title2.bold())
                    .foregroundStyle(CircleTheme.warmBrown)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text("You text them memes. You heart their stories.\nBut when did you last really hear their voice?")
                    .font(.body)
                    .foregroundStyle(CircleTheme.warmBrown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Screen 2: The Solution

    private var solutionContent: some View {
        VStack(spacing: 24) {
            // Waveform illustration
            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.cream)
                    .frame(width: 140, height: 140)

                WaveformView(
                    amplitudes: OnboardingPageView.sampleAmplitudes,
                    isLive: false,
                    activeColor: CircleTheme.warmAmber,
                    inactiveColor: CircleTheme.warmAmber.opacity(0.3),
                    barCount: 20,
                    barSpacing: 3
                )
                .frame(width: 100, height: 50)
            }

            VStack(spacing: 12) {
                Text("One question. Their voice.\nEvery day.")
                    .font(.title2.bold())
                    .foregroundStyle(CircleTheme.warmBrown)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text("Circle sends your group a daily prompt.\nEveryone responds with a short voice note.\n5 minutes to feel connected.")
                    .font(.body)
                    .foregroundStyle(CircleTheme.warmBrown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Screen 3: How It Works

    private var howItWorksContent: some View {
        VStack(spacing: 32) {
            Text("How it works")
                .font(.title2.bold())
                .foregroundStyle(CircleTheme.warmBrown)

            VStack(spacing: 24) {
                howItWorksStep(
                    icon: "bell.fill",
                    title: "A prompt arrives",
                    subtitle: "\"What made you smile today?\"",
                    step: 1
                )

                howItWorksStep(
                    icon: "mic.fill",
                    title: "You record",
                    subtitle: "A short voice note, in your own words",
                    step: 2
                )

                howItWorksStep(
                    icon: "play.fill",
                    title: "You listen",
                    subtitle: "Hear the people who matter most",
                    step: 3
                )
            }
        }
    }

    private func howItWorksStep(
        icon: String,
        title: String,
        subtitle: String,
        step: Int
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.warmAmber.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(CircleTheme.warmAmber)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(CircleTheme.warmBrown)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CircleTheme.warmBrown.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Sample Data

    /// Sample waveform amplitudes for the solution screen illustration.
    static let sampleAmplitudes: [Float] = [
        0.2, 0.4, 0.6, 0.8, 0.5, 0.9, 0.7, 0.3, 0.6, 0.8,
        0.4, 0.7, 0.9, 0.5, 0.3, 0.6, 0.8, 0.4, 0.5, 0.3
    ]
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView(
        viewModel: OnboardingViewModel(
            settingsRepository: UserDefaultsSettingsRepository(),
            analyticsService: ConsoleAnalyticsService()
        )
    )
}
#endif
