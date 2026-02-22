// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main onboarding container with 4 swipeable pages.
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
            // Dark background
            Color.black
                .ignoresSafeArea()

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
        .preferredColorScheme(.dark)
        .onAppear {
            analyticsService.logEvent(.onboardingStarted, parameters: nil)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                completeOnboarding()
            } label: {
                Text("Skip")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Custom page dots
            pageDots

            if currentPage == totalPages - 1 {
                // Last page: Find Friends + Skip for now
                lastPageButtons
            } else {
                // Other pages: Next button
                nextButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Page Dots

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.gray.opacity(0.4))
                    .frame(
                        width: index == currentPage ? 10 : 8,
                        height: index == currentPage ? 10 : 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button {
            advanceToNextPage()
        } label: {
            Text("Next")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Last Page Buttons

    private var lastPageButtons: some View {
        VStack(spacing: 12) {
            Button {
                handleFindFriends()
            } label: {
                Text("Find Friends")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                completeOnboarding()
            } label: {
                Text("Skip for now")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.gray)
            }
            .padding(.bottom, 8)
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
