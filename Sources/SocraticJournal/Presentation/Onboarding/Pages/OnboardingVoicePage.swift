// OnboardingVoicePage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 3: "Your voice, not your thumbs" — coral-red accent background, ALL WHITE text.
/// The BOLD statement page. Most striking page in the onboarding.
public struct OnboardingVoicePage: View {
    // MARK: - Body

    public var body: some View {
        ZStack {
            // Bold coral-red background
            AppColors.accent
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                    .frame(height: AppSpacing.heroTopPadding)

                // Massive headline — white on red
                Text("Your voice,\nnot your\nthumbs")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(AppColors.textOnAccent)
                    .lineSpacing(2)

                // Body copy — white on red
                Text("60 seconds. No editing. No overthinking. Just you.")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(AppColors.textOnAccent)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    OnboardingVoicePage()
}
#endif
