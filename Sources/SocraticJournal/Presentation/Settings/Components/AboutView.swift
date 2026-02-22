// AboutView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// About section with version and links
struct AboutView: View {
    let version: String
    let onPrivacyPolicy: () -> Void
    let onReplayOnboarding: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Version info
            HStack {
                Text("Version")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text(version)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.md)

            HairlineDivider()

            // Replay onboarding
            Button(action: onReplayOnboarding) {
                HStack {
                    Text("Replay Onboarding")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.vertical, AppSpacing.md)
            }
            .buttonStyle(.plain)

            HairlineDivider()

            // Privacy policy link
            Button(action: onPrivacyPolicy) {
                HStack {
                    Text("Privacy Policy")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.vertical, AppSpacing.md)
            }
            .buttonStyle(.plain)
        }
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }
}

#Preview {
    AboutView(
        version: "1.0.0",
        onPrivacyPolicy: {},
        onReplayOnboarding: {}
    )
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
