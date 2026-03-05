// NewOnboardingView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// 5-page swipeable onboarding for the Breathe app
public struct NewOnboardingView: View {
    @State private var currentPage: Int = 0
    @State private var breathScale: CGFloat = 0.6
    @State private var breathOpacity: Double = 0.15
    @State private var assessment = OnboardingAssessment()

    private let settingsRepository: SettingsRepositoryProtocol
    private let onDismiss: () -> Void
    private let totalPages = 5

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        onDismiss: @escaping () -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            currentPageBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: currentPage)

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    onboardingPage1.tag(0)
                    onboardingPage2.tag(1)
                    onboardingPage3.tag(2)
                    onboardingPage4.tag(3)
                    onboardingPage5.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(dotColor(for: index))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onChange(of: assessment.experience) { _, newValue in
            // Auto-advance to page 5 after all questions answered
            if newValue != nil && assessment.isComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 4
                    }
                }
            }
        }
    }

    // MARK: - Page Dot Colors

    /// Pages on cream background (0, 1, 3) use teal dots; pages on teal (2, 4) use white dots
    private func dotColor(for index: Int) -> Color {
        let isTealBackground = currentPage == 2 || currentPage == 4
        let isActive = index == currentPage

        if isTealBackground {
            return isActive ? Color.white : Color.white.opacity(0.4)
        } else {
            return isActive ? AppColors.accent : AppColors.border
        }
    }

    private var currentPageBackground: some View {
        Group {
            switch currentPage {
            case 0: AppColors.background
            case 1: AppColors.background
            case 2: AppColors.accent
            case 3: AppColors.background
            case 4: AppColors.accent
            default: AppColors.background
            }
        }
    }

    // MARK: - Page 1: Breathe Better

    private var onboardingPage1: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Text("Breathe Better")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            Text("The most powerful health tool\nyou already have")
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            // Animated breath circle
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(breathOpacity))
                    .frame(width: 180, height: 180)
                    .scaleEffect(breathScale * 1.2)

                Circle()
                    .fill(AppColors.accent.opacity(breathOpacity + 0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(breathScale)

                Circle()
                    .fill(AppColors.accent.opacity(0.5))
                    .frame(width: 60, height: 60)
                    .scaleEffect(breathScale * 0.8)
            }
            .padding(.vertical, AppSpacing.xl)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 5.5)
                    .repeatForever(autoreverses: true)
                ) {
                    breathScale = 1.0
                    breathOpacity = 0.3
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Page 2: Ancient Wisdom, Modern Science

    private var onboardingPage2: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Spacer()

            Text("Ancient Wisdom,\nModern Science")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                techniqueRow("Resonance", "The perfect breath")
                techniqueRow("Box Breathing", "Navy SEAL focus")
                techniqueRow("4-7-8", "Natural tranquilizer")
                techniqueRow("Physiological Sigh", "Stanford's fastest reset")
            }
            .padding(.vertical, AppSpacing.md)

            Text("Each backed by research.\nGuided by a simple visual.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Page 3: Just 5 Minutes

    private var onboardingPage3: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Text("Just 5 Minutes\na Day")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Track your practice. Learn the science.\nBreathe with intention.")
                .font(AppTypography.bodyLarge)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = 3
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Capsule().fill(.white))
            }
            .buttonStyle(.plain)
            .padding(.bottom, AppSpacing.lg)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Page 4: Assessment

    private var onboardingPage4: some View {
        OnboardingAssessmentPage(
            assessment: $assessment,
            onSkip: {
                assessment = .defaults
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage = 4
                }
            }
        )
    }

    // MARK: - Page 5: Recommendation

    private var onboardingPage5: some View {
        OnboardingRecommendationPage(
            assessment: assessment.isComplete ? assessment : .defaults,
            onBeginJourney: {
                completeOnboarding()
            }
        )
    }

    // MARK: - Helpers

    private func techniqueRow(_ name: String, _ subtitle: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Rectangle()
                .fill(AppColors.accent)
                .frame(width: 4)
                .frame(height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private func completeOnboarding() {
        Task {
            do {
                var settings = try await settingsRepository.getSettings()
                settings.hasCompletedOnboarding = true
                try await settingsRepository.saveSettings(settings)
            } catch {
                print("Failed to save onboarding completion: \(error)")
            }
            await MainActor.run {
                onDismiss()
            }
        }
    }
}

#Preview {
    NewOnboardingView(
        settingsRepository: PreviewSettingsRepository(),
        onDismiss: {}
    )
}

private final class PreviewSettingsRepository: SettingsRepositoryProtocol {
    func getSettings() async throws -> UserSettings { .default }
    func saveSettings(_ settings: UserSettings) async throws {}
    func resetSettings() async throws {}
    func clearAllData() async throws {}
}
#endif
