// NewOnboardingView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Three-page breath-focused onboarding flow.
/// Pages: Hook -> Science -> Commitment
public struct NewOnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: OnboardingViewModel(
            settingsRepository: settingsRepository,
            analyticsService: analyticsService,
            onDismiss: onDismiss
        ))
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.currentPage) {
                OnboardingHookPage {
                    withAnimation {
                        viewModel.nextPage()
                    }
                }
                .tag(0)

                OnboardingSciencePage {
                    withAnimation {
                        viewModel.nextPage()
                    }
                }
                .tag(1)

                OnboardingCommitPage(
                    isCompleting: viewModel.isCompleting
                ) {
                    Task {
                        await viewModel.completeOnboarding()
                    }
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Custom page indicators
            PageIndicatorView(
                currentPage: viewModel.currentPage,
                totalPages: viewModel.totalPages
            )
            .padding(.bottom, AppSpacing.md)
        }
        .onAppear {
            viewModel.logOnboardingStarted()
        }
    }
}

// MARK: - Page Indicator

/// Custom page dots for the onboarding flow
private struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? .white : .white.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
        }
    }
}

#Preview {
    NewOnboardingView(
        settingsRepository: UserDefaultsSettingsRepository(),
        onDismiss: {}
    )
}
#endif
