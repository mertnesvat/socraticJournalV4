// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main onboarding container with 4 swipeable pages.
/// Each page has its own contrasting background color.
/// Features custom page dots, skip button, and navigation controls.
public struct NewOnboardingView: View {
    // MARK: - State

    @State private var currentPage: Int = 0

    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let onDismiss: () -> Void

    // MARK: - Constants

    private let totalPages = 4

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.analyticsService = analyticsService
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Dynamic background that matches the current page
            currentPageBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: currentPage)

            VStack(spacing: 0) {
                // Top bar with Skip button
                topBar

                // Page content
                TabView(selection: $currentPage) {
                    OnboardingWelcomePage()
                        .tag(0)

                    OnboardingUnlockPage()
                        .tag(1)

                    OnboardingVoicePage()
                        .tag(2)

                    OnboardingFriendsPage(
                        onFindFriends: { handleFindFriends() },
                        onSkipForNow: { completeOnboarding() }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Bottom controls
                bottomControls
            }
        }
        .onAppear {
            analyticsService.logEvent(.onboardingStarted, parameters: nil)
        }
    }

    // MARK: - Dynamic Background

    private var currentPageBackground: some View {
        Group {
            switch currentPage {
            case 0: AppColors.background
            case 1: AppColors.cardTeal
            case 2: AppColors.accent
            case 3: AppColors.cardYellow
            default: AppColors.background
            }
        }
    }

    /// Whether the current page has a dark/vivid background requiring light text
    private var useLightControls: Bool {
        currentPage == 2 // Only the accent (coral-red) page needs white controls
    }

    /// The color for control text (dots, skip) that adapts to the page background
    private var controlTextColor: Color {
        useLightControls ? AppColors.textOnAccent : AppColors.textPrimary
    }

    /// The color for secondary control text (skip, inactive dots)
    private var controlSecondaryColor: Color {
        useLightControls ? AppColors.textOnAccent.opacity(0.5) : AppColors.border
    }

    /// The color for the skip button text
    private var skipButtonColor: Color {
        useLightControls ? AppColors.textOnAccent.opacity(0.7) : AppColors.textSecondary
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                completeOnboarding()
            } label: {
                Text("Skip")
                    .font(AppTypography.body)
                    .foregroundStyle(skipButtonColor)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: AppSpacing.md) {
            // Custom page dots
            pageDots

            if currentPage == totalPages - 1 {
                // Last page: Get Started button
                lastPageButtons
            } else {
                // Other pages: Next button
                nextButton
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.bottom, 40)
    }

    // MARK: - Page Dots

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? controlTextColor : controlSecondaryColor)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.bottom, AppSpacing.xs)
    }

    // MARK: - Next Button

    private var nextButton: some View {
        AccentPillButton("Next") {
            advanceToNextPage()
        }
    }

    // MARK: - Last Page Buttons

    private var lastPageButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            AccentPillButton("Get Started") {
                completeOnboarding()
            }
        }
    }

    // MARK: - Actions

    private func advanceToNextPage() {
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }

    private func handleFindFriends() {
        // For now, complete onboarding. Friends feature will be connected later.
        analyticsService.logEvent(.contactsImportStarted, parameters: nil)
        completeOnboarding()
    }

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
                analyticsService.logEvent(.onboardingCompleted, parameters: [
                    AnalyticsParameter.onboardingStep.rawValue: currentPage
                ])
            } catch {
                // Log error but still dismiss so user is not stuck
                print("Failed to save onboarding completion: \(error)")
            }
            await MainActor.run {
                onDismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewOnboardingView(
        settingsRepository: PreviewSettingsRepository(),
        onDismiss: { print("Onboarding dismissed") }
    )
}

// MARK: - Preview Helper

private final class PreviewSettingsRepository: SettingsRepositoryProtocol {
    func getSettings() async throws -> UserSettings {
        UserSettings.default
    }

    func saveSettings(_ settings: UserSettings) async throws {
        // No-op for preview
    }

    func resetSettings() async throws {
        // No-op for preview
    }

    func clearAllData() async throws {
        // No-op for preview
    }
}
#endif
