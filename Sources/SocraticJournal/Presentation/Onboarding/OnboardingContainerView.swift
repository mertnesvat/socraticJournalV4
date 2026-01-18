// OnboardingContainerView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Container view that manages all onboarding screens with paging navigation
/// Handles page transitions, progress indicators, and navigation between screens
public struct OnboardingContainerView: View {
    // MARK: - Constants

    private enum Constants {
        static let totalPages = 4
        static let dotSize: CGFloat = 8
        static let dotSpacing: CGFloat = 8
        static let activeDotScale: CGFloat = 1.0
        static let inactiveDotScale: CGFloat = 0.7
    }

    // MARK: - State

    @State private var currentPage: Int = 0

    // MARK: - Actions

    /// Called when onboarding is completed (either by finishing or skipping)
    public var onComplete: () -> Void

    // MARK: - Init

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background that adapts to light/dark mode
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main paging content
                pageContent

                // Page indicator dots
                pageIndicator
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Page Content

    private var pageContent: some View {
        TabView(selection: $currentPage) {
            // Page 0: Welcome
            OnboardingWelcomeView(
                onSkip: handleSkip,
                onContinue: { advanceToPage(1) }
            )
            .tag(0)

            // Page 1: Guided Reflection
            OnboardingGuidedReflectionView(
                onSkip: handleSkip,
                onContinue: { advanceToPage(2) }
            )
            .tag(1)

            // Page 2: Character Discovery
            OnboardingCharacterDiscoveryView(
                onSkip: handleSkip,
                onContinue: { advanceToPage(3) }
            )
            .tag(2)

            // Page 3: Letters (Final)
            OnboardingLettersView(
                onSkip: nil,  // No skip on last page - user should tap "Begin Your Journey"
                onComplete: handleComplete
            )
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: Constants.dotSpacing) {
            ForEach(0..<Constants.totalPages, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(
                        width: Constants.dotSize,
                        height: Constants.dotSize
                    )
                    .scaleEffect(dotScale(for: index))
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(Constants.totalPages)")
    }

    // MARK: - Dot Styling

    private func dotColor(for index: Int) -> Color {
        index == currentPage
            ? Color.accentColor
            : Color.secondary.opacity(0.3)
    }

    private func dotScale(for index: Int) -> CGFloat {
        index == currentPage
            ? Constants.activeDotScale
            : Constants.inactiveDotScale
    }

    // MARK: - Navigation Actions

    private func advanceToPage(_ page: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = min(page, Constants.totalPages - 1)
        }
    }

    private func handleSkip() {
        onComplete()
    }

    private func handleComplete() {
        onComplete()
    }
}

// MARK: - Preview

#Preview("Onboarding Container") {
    OnboardingContainerView(
        onComplete: { print("Onboarding completed") }
    )
}

#Preview("Onboarding Container - Dark") {
    OnboardingContainerView(
        onComplete: { print("Onboarding completed") }
    )
    .preferredColorScheme(.dark)
}
#endif
