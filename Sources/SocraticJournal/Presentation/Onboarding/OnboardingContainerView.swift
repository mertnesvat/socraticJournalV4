// OnboardingContainerView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Container view that manages all onboarding screens with paging navigation
/// Provides horizontal swipe navigation between screens with custom page indicators
public struct OnboardingContainerView: View {
    // MARK: - Constants

    private let totalPages = 4

    // MARK: - State

    @State private var currentPage: Int = 0

    // MARK: - Properties

    let onComplete: () -> Void

    // MARK: - Initialization

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Paged TabView for horizontal swiping
            TabView(selection: $currentPage) {
                // Screen 1: Welcome
                OnboardingWelcomeView(
                    onSkip: { completeOnboarding() },
                    onContinue: { advanceToNextPage() }
                )
                .tag(0)

                // Screen 2: Guided Reflection
                OnboardingGuidedReflectionView(
                    onSkip: { completeOnboarding() },
                    onContinue: { advanceToNextPage() }
                )
                .tag(1)

                // Screen 3: Character Discovery
                OnboardingCharacterDiscoveryView(
                    onSkip: { completeOnboarding() },
                    onContinue: { advanceToNextPage() }
                )
                .tag(2)

                // Screen 4: Letters to Future Self (final screen)
                OnboardingLettersView(
                    onSkip: { completeOnboarding() },
                    onComplete: { completeOnboarding() }
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Custom page indicator dots
            pageIndicator
                .padding(.bottom, 100)
        }
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                PageDot(isActive: index == currentPage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    /// Advances to the next page with smooth animation
    private func advanceToNextPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = min(currentPage + 1, totalPages - 1)
        }
    }

    /// Completes onboarding and calls the completion handler
    private func completeOnboarding() {
        onComplete()
    }
}

// MARK: - Page Dot Component

/// Individual page indicator dot that shows active/inactive state
private struct PageDot: View {
    let isActive: Bool

    var body: some View {
        Circle()
            .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.3))
            .frame(width: isActive ? 10 : 8, height: isActive ? 10 : 8)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Preview

#Preview("Onboarding Container") {
    OnboardingContainerView {
        print("Onboarding completed")
    }
}

#Preview("Onboarding Container - Dark Mode") {
    OnboardingContainerView {
        print("Onboarding completed")
    }
    .preferredColorScheme(.dark)
}
#endif
